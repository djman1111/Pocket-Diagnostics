/* UART asynchronous example, that uses separate RX and TX tasks

   This example code is in the Public Domain (or CC0 licensed, at your option.)

   Unless required by applicable law or agreed to in writing, this
   software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
   CONDITIONS OF ANY KIND, either express or implied.
*/
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_log.h"
#include "driver/uart.h"
#include "string.h"
#include "driver/gpio.h"
#include "driver/i2c_master.h"

static const int RX_BUF_SIZE = 1024;

#define TXD_PIN (GPIO_NUM_4)
#define RXD_PIN (GPIO_NUM_5)
#define GPIO_SDA (GPIO_NUM_18)
#define GPIO_SCL (GPIO_NUM_19)

#define I2C_MASTER_SCL_IO    22    // SCL pin
#define I2C_MASTER_SDA_IO    21    // SDA pin
#define I2C_MASTER_NUM       I2C_NUM_0
#define I2C_MASTER_FREQ_HZ   100000
#define I2C_SLAVE_ADDR       0x23  // Slave address

int Logic_function(uint8_t device_address, uint16_t *data, size_t data_length);
QueueHandle_t i2c_data_queue;
int cmd = 0;
static const char *TAG = "MAIN";


void init(void)
{
    const uart_config_t uart_config = {
        .baud_rate = 115200,
        .data_bits = UART_DATA_8_BITS,
        .parity = UART_PARITY_DISABLE,
        .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE,
        .source_clk = UART_SCLK_DEFAULT,
    };
    // We won't use a buffer for sending data.
    uart_driver_install(UART_NUM_1, RX_BUF_SIZE * 2, 0, 0, NULL, 0);
    uart_param_config(UART_NUM_1, &uart_config);
    uart_set_pin(UART_NUM_1, TXD_PIN, RXD_PIN, UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE);
}

int sendData(const char* logName, const char* data)
{
    const int len = strlen(data);
    const int txBytes = uart_write_bytes(UART_NUM_1, data, len);
    ESP_LOGI(logName, "Wrote %d bytes", txBytes);
    return txBytes;
}

static void tx_task(void *arg)
{
    static const char *TX_TASK_TAG = "TX_TASK";
    esp_log_level_set(TX_TASK_TAG, ESP_LOG_INFO);
    while (1) {
        char msg[32];
        switch (cmd) {
            case 1:
            //Grab logic data
            uint16_t data_send = 0;
            int len = 0;
            len = Logic_function(I2C_SLAVE_ADDR, &data_send, sizeof(data_send));
            snprintf(msg, sizeof(msg), "Logic: %04X\n", data_send);
            sendData(TX_TASK_TAG, msg);

            break;
            case 2:
            //Grab i2c data 
            uint32_t i2c_data = 0;
            if(xQueueReceive(i2c_data_queue, &i2c_data, pdMS_TO_TICKS(100)) == pdTRUE) {
                snprintf(msg, sizeof(msg), "I2C: %08lX\n", (unsigned long)i2c_data);
                sendData(TX_TASK_TAG, msg);

            }
            break;
            default:
                printf("Invalid command received.\n");
            break;
        }
        vTaskDelay(2000 / portTICK_PERIOD_MS);
    }
}

static void rx_task(void *arg)
{
    static const char *RX_TASK_TAG = "RX_TASK";
    esp_log_level_set(RX_TASK_TAG, ESP_LOG_INFO);
    uint8_t* data = (uint8_t*) malloc(RX_BUF_SIZE + 1);
    while (1) {
        const int rxBytes = uart_read_bytes(UART_NUM_1, data, RX_BUF_SIZE, 1000 / portTICK_PERIOD_MS);
        if (rxBytes > 0) {
            data[rxBytes] = 0;
            ESP_LOGI(RX_TASK_TAG, "Read %d bytes: '%.*s'", rxBytes, rxBytes, data);

        for (int i = 0; i < rxBytes; i++) {
            ESP_LOGI(RX_TASK_TAG, "Byte %d: 0x%02X (%d)", i, data[i], data[i]);
        }

            cmd = atoi((char *)data);
        }
    }
    free(data);
}


// My code 
//SPI
int SDA = 0;
int SCL = 0; 
uint8_t bits_collected = 0;
uint16_t SDA_buffer = 0;
uint16_t SCL_buffer = 0;
volatile uint32_t DATA_send = 0;

void IRAM_ATTR I2C_sniffer_isr(void *arg) {
    SDA = gpio_get_level(GPIO_SDA);  // Read MOSI
    SCL = gpio_get_level(GPIO_SCL);  // Read MISO

    SDA_buffer = (SDA_buffer << 1) | (SDA & 0x01);
    SCL_buffer = (SCL_buffer << 1) | (SCL & 0x01);
    bits_collected++;

    if(bits_collected == 16){
        DATA_send = ((uint32_t)SDA_buffer << 16) | SCL_buffer;
        bits_collected = 0;
        xQueueSendFromISR(i2c_data_queue, &DATA_send, NULL);
        DATA_send = 0;
    }

    // Print captured bit values
}
void setup_I2C_sniffer() {
    // Configure SCLK (SPI Clock) as input with interrupt on rising edge
    gpio_config_t io_conf = {
        .pin_bit_mask = (1ULL << GPIO_SCL),
        .mode = GPIO_MODE_INPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_ANYEDGE  // Interrupt on rising edge
    };
    gpio_config(&io_conf);

    // Configure MOSI, MISO, and CS as inputs
    gpio_config_t io_conf_data = {
        .pin_bit_mask = (1ULL << GPIO_SDA),
        .mode = GPIO_MODE_INPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE
    };
    gpio_config(&io_conf_data);

    // Install ISR service
    gpio_install_isr_service(0);
    gpio_isr_handler_add(GPIO_SCL, I2C_sniffer_isr, NULL);

    ESP_LOGI(TAG, "SPI Sniffer initialized on SDA: %d, SCL: %d", 
             GPIO_SDA, GPIO_SCL);
}


int Logic_function(uint8_t device_address, uint16_t *data, size_t data_length) {
    static i2c_master_bus_handle_t bus_handle = NULL;  // Make bus handle persistent

    if (bus_handle == NULL) {  // Initialize bus only if not already initialized
        i2c_master_bus_config_t bus_cfg = {
            .i2c_port = I2C_NUM_0,
            .scl_io_num = I2C_MASTER_SCL_IO,
            .sda_io_num = I2C_MASTER_SDA_IO,
            .clk_source = I2C_CLK_SRC_DEFAULT,
            .glitch_ignore_cnt = 7,
            .flags.enable_internal_pullup = true
        };

        ESP_ERROR_CHECK(i2c_new_master_bus(&bus_cfg, &bus_handle));
    }

    i2c_device_config_t dev_cfg = {
        .dev_addr_length = I2C_ADDR_BIT_LEN_7,
        .device_address = device_address,  // Use function parameter
        .scl_speed_hz = I2C_MASTER_FREQ_HZ
    };
    i2c_master_dev_handle_t dev_handle;
    uint8_t input_data[2];
    uint8_t config_all_input[2] = {0xFF, 0xFF}; // All 16 bits as input
    uint8_t reg_addr0 = 0x00;
    uint8_t reg_addr1 = 0x01;
    ESP_ERROR_CHECK(i2c_master_bus_add_device(bus_handle, &dev_cfg, &dev_handle));
    ESP_ERROR_CHECK(i2c_master_transmit(dev_handle, (uint8_t[]){0x06, config_all_input[0]}, 2, -1));  // Port 0
    ESP_ERROR_CHECK(i2c_master_transmit(dev_handle, (uint8_t[]){0x07, config_all_input[1]}, 2, -1));  // Port 1
    ESP_ERROR_CHECK(i2c_master_transmit_receive(dev_handle, &reg_addr0, 1, &input_data[0], 1, -1));
    ESP_ERROR_CHECK(i2c_master_transmit_receive(dev_handle, &reg_addr1, 1, &input_data[1], 1, -1));


    uint8_t port0 = input_data[0];  // Pins 0-7
    uint8_t port1 = input_data[1];  // Pins 8-15
    printf("Data: %d, %d", port0, port1);
    *data = ((uint16_t)port1 << 8) | port0;
    i2c_master_bus_rm_device(dev_handle); // Remove device after communication

    return data_length;
}


void app_main(void)
{
    init();
    i2c_data_queue = xQueueCreate(10, sizeof(uint32_t));
    setup_I2C_sniffer();
    xTaskCreate(rx_task, "uart_rx_task", 1024 * 2, NULL, configMAX_PRIORITIES - 1, NULL);
    xTaskCreate(tx_task, "uart_tx_task", 4096, NULL, 1, NULL);

}
