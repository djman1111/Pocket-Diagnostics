/*
 * SPDX-FileCopyrightText: 2021-2024 Espressif Systems (Shanghai) CO LTD
 *
 * SPDX-License-Identifier: Unlicense OR CC0-1.0
 */

/****************************************************************************
*
* This demo showcases BLE GATT server. It can send adv data, be connected by client.
* Run the gatt_client demo, the client demo will automatically connect to the gatt_server demo.
* Client demo will enable gatt_server's notify after connection. The two devices will then exchange
* data.
*
****************************************************************************/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/event_groups.h"
#include "esp_system.h"
#include "esp_log.h"
#include "nvs_flash.h"
#include "esp_bt.h"
#include "esp_mac.h"

#include "esp_gap_ble_api.h"
#include "esp_gatts_api.h"
#include "esp_bt_defs.h"
#include "esp_bt_main.h"
#include "esp_bt_device.h"
#include "esp_gatt_common_api.h"

#include "driver/gpio.h"
#include "driver/uart.h"

#include "sdkconfig.h"

#include "driver/spi_master.h"
#include "driver/spi_slave.h"

#include "driver/i2c_master.h"


#define GATTS_TAG "Pocket_Diagnostics"

static const char *TAG = "SPI_MASTER_RECEIVER";

///Declare the static function
static void gatts_profile_a_event_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param);


int o_scope_function(uint8_t device_address, uint8_t *data, size_t data_length);
void log_uart_data_as_hex(uint8_t *data, size_t len);
void i2c_master_READEVENT(void);
int receive_spi_data(uint8_t function_id);
uint16_t battery_life();
//O-SCOPE defines
#define TXD1_PIN (GPIO_NUM_35)
#define RXD1_PIN (GPIO_NUM_13)
#define TXD2_PIN (GPIO_NUM_34)
#define RXD2_PIN (GPIO_NUM_27)
#define TXD3_PIN (GPIO_NUM_4)
#define RXD3_PIN (GPIO_NUM_5)
//SPI GPIO
#ifdef CONFIG_IDF_TARGET_ESP32
#define RCV_HOST    HSPI_HOST
#else
#define RCV_HOST    SPI2_HOST
#endif

#define GPIO_HANDSHAKE      2
#define GPIO_MOSI           22
#define GPIO_MISO           19
#define GPIO_SCLK           18
#define GPIO_CS             21
spi_device_handle_t spi;


#define I2C_MASTER_SCL_IO    25    // SCL pin
#define I2C_MASTER_SDA_IO    26    // SDA pin
#define I2C_MASTER_NUM       I2C_NUM_0
#define I2C_MASTER_FREQ_HZ   100000
#define I2C_SLAVE_ADDR       0x08  // Slave address


#define GATTS_SERVICE_UUID_TEST_A   0x00FF
#define GATTS_CHAR_UUID_TEST_A      0xFF01
#define GATTS_MYCHAR_UUID           0xFF02
#define GATTS_DESCR_UUID_TEST_A     0x3333
#define GATTS_NUM_HANDLE_TEST_A     4
#define ESP_GATT_UUID_CCCD  0x2902



#define TEST_DEVICE_NAME           "Pocket_Diagnostics"
#define TEST_MANUFACTURER_DATA_LEN  17

#define GATTS_DEMO_CHAR_VAL_LEN_MAX 0x40

#define PREPARE_BUF_MAX_SIZE 1024
#define MAX_ALLOWED_TIME 60000 // 60 secs

//Global vars
volatile int ASCII_VALUE = 0;
bool stop_data = false;
#define stop_CMD 0
static uint16_t GATTS_IF = 0;
static uint16_t CONN_ID = 0;
static uint16_t ATTR_HANDLE = 0;
int current_cmd = stop_CMD; //*********************************** set as 4
int Serial_Type = 99;
int Baud_rate = 99;
TaskHandle_t data_task_handle = NULL;
QueueHandle_t spi_data_queue;
static i2c_master_bus_handle_t bus_handle = NULL;

static uint8_t data[] = {0x11,0x22,0x33};
static esp_gatt_char_prop_t a_property = 0;
static esp_attr_value_t gatts_demo_char1_val =
{
    .attr_max_len = GATTS_DEMO_CHAR_VAL_LEN_MAX,
    .attr_len     = sizeof(data),
    .attr_value   = data,
};

static uint8_t adv_config_done = 0;
#define adv_config_flag      (1 << 0)
#define scan_rsp_config_flag (1 << 1)

#ifdef CONFIG_SET_RAW_ADV_DATA
static uint8_t raw_adv_data[] = {
        0x02, 0x01, 0x06,                  // Length 2, Data Type 1 (Flags), Data 1 (LE General Discoverable Mode, BR/EDR Not Supported)
        0x02, 0x0a, 0xeb,                  // Length 2, Data Type 10 (TX power level), Data 2 (-21)
        0x03, 0x03, 0xab, 0xcd,            // Length 3, Data Type 3 (Complete 16-bit Service UUIDs), Data 3 (UUID)
};
static uint8_t raw_scan_rsp_data[] = {     // Length 15, Data Type 9 (Complete Local Name), Data 1 (ESP_GATTS_DEMO)
        0x0f, 0x09, 0x45, 0x53, 0x50, 0x5f, 0x47, 0x41, 0x54, 0x54, 0x53, 0x5f, 0x44,
        0x45, 0x4d, 0x4f
};
#else

static uint8_t adv_service_uuid128[32] = {
    /* LSB <--------------------------------------------------------------------------------> MSB */
    //first uuid, 16bit, [12],[13] is the value
    0xfb, 0x34, 0x9b, 0x5f, 0x80, 0x00, 0x00, 0x80, 0x00, 0x10, 0x00, 0x00, 0xEE, 0x00, 0x00, 0x00,
    //second uuid, 32bit, [12], [13], [14], [15] is the value
    0xfb, 0x34, 0x9b, 0x5f, 0x80, 0x00, 0x00, 0x80, 0x00, 0x10, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00,
};

// The length of adv data must be less than 31 bytes
//static uint8_t test_manufacturer[TEST_MANUFACTURER_DATA_LEN] =  {0x12, 0x23, 0x45, 0x56};
//adv data
static esp_ble_adv_data_t adv_data = {
    .set_scan_rsp = false,
    .include_name = true,
    .include_txpower = false,
    .min_interval = 0x0006, //slave connection min interval, Time = min_interval * 1.25 msec
    .max_interval = 0x0010, //slave connection max interval, Time = max_interval * 1.25 msec
    .appearance = 0x00,
    .manufacturer_len = 0, //TEST_MANUFACTURER_DATA_LEN,
    .p_manufacturer_data =  NULL, //&test_manufacturer[0],
    .service_data_len = 0,
    .p_service_data = NULL,
    .service_uuid_len = sizeof(adv_service_uuid128),
    .p_service_uuid = adv_service_uuid128,
    .flag = (ESP_BLE_ADV_FLAG_GEN_DISC | ESP_BLE_ADV_FLAG_BREDR_NOT_SPT),
};
// scan response data
static esp_ble_adv_data_t scan_rsp_data = {
    .set_scan_rsp = true,
    .include_name = true,
    .include_txpower = true,
    //.min_interval = 0x0006,
    //.max_interval = 0x0010,
    .appearance = 0x00,
    .manufacturer_len = 0, //TEST_MANUFACTURER_DATA_LEN,
    .p_manufacturer_data =  NULL, //&test_manufacturer[0],
    .service_data_len = 0,
    .p_service_data = NULL,
    .service_uuid_len = sizeof(adv_service_uuid128),
    .p_service_uuid = adv_service_uuid128,
    .flag = (ESP_BLE_ADV_FLAG_GEN_DISC | ESP_BLE_ADV_FLAG_BREDR_NOT_SPT),
};

#endif /* CONFIG_SET_RAW_ADV_DATA */

static esp_ble_adv_params_t adv_params = {
    .adv_int_min        = 0x20,
    .adv_int_max        = 0x40,
    .adv_type           = ADV_TYPE_IND,
    .own_addr_type      = BLE_ADDR_TYPE_PUBLIC,
    //.peer_addr            =
    //.peer_addr_type       =
    .channel_map        = ADV_CHNL_ALL,
    .adv_filter_policy = ADV_FILTER_ALLOW_SCAN_ANY_CON_ANY,
};

#define PROFILE_NUM 1
#define PROFILE_A_APP_ID 0

struct gatts_profile_inst {
    esp_gatts_cb_t gatts_cb;
    uint16_t gatts_if;
    uint16_t app_id;
    uint16_t conn_id;
    uint16_t service_handle;
    esp_gatt_srvc_id_t service_id;
    uint16_t char_handle;
    esp_bt_uuid_t char_uuid;
    esp_gatt_perm_t perm;
    esp_gatt_char_prop_t property;
    uint16_t descr_handle;
    esp_bt_uuid_t descr_uuid;
};

/* One gatt-based profile one app_id and one gatts_if, this array will store the gatts_if returned by ESP_GATTS_REG_EVT */
static struct gatts_profile_inst gl_profile_tab[PROFILE_NUM] = {
    [PROFILE_A_APP_ID] = {
        .gatts_cb = gatts_profile_a_event_handler,
        .gatts_if = ESP_GATT_IF_NONE,       /* Not get the gatt_if, so initial is ESP_GATT_IF_NONE */
    },
};

typedef struct {
    uint8_t                 *prepare_buf;
    int                     prepare_len;
} prepare_type_env_t;

static prepare_type_env_t a_prepare_write_env;

void example_write_event_env(esp_gatt_if_t gatts_if, prepare_type_env_t *prepare_write_env, esp_ble_gatts_cb_param_t *param);
void example_exec_write_event_env(prepare_type_env_t *prepare_write_env, esp_ble_gatts_cb_param_t *param);

static void gap_event_handler(esp_gap_ble_cb_event_t event, esp_ble_gap_cb_param_t *param)
{
    switch (event) {
#ifdef CONFIG_SET_RAW_ADV_DATA
    case ESP_GAP_BLE_ADV_DATA_RAW_SET_COMPLETE_EVT:
        adv_config_done &= (~adv_config_flag);
        if (adv_config_done==0){
            esp_ble_gap_start_advertising(&adv_params);
        }
        break;
    case ESP_GAP_BLE_SCAN_RSP_DATA_RAW_SET_COMPLETE_EVT:
        adv_config_done &= (~scan_rsp_config_flag);
        if (adv_config_done==0){
            esp_ble_gap_start_advertising(&adv_params);
        }
        break;
#else
    case ESP_GAP_BLE_ADV_DATA_SET_COMPLETE_EVT:
        adv_config_done &= (~adv_config_flag);
        if (adv_config_done == 0){
            esp_ble_gap_start_advertising(&adv_params);
        }
        break;
    case ESP_GAP_BLE_SCAN_RSP_DATA_SET_COMPLETE_EVT:
        adv_config_done &= (~scan_rsp_config_flag);
        if (adv_config_done == 0){
            esp_ble_gap_start_advertising(&adv_params);
        }
        break;
#endif
    case ESP_GAP_BLE_ADV_START_COMPLETE_EVT:
        //advertising start complete event to indicate advertising start successfully or failed
        if (param->adv_start_cmpl.status != ESP_BT_STATUS_SUCCESS) {
            ESP_LOGE(GATTS_TAG, "Advertising start failed");
        }
        break;
    case ESP_GAP_BLE_ADV_STOP_COMPLETE_EVT:
        if (param->adv_stop_cmpl.status != ESP_BT_STATUS_SUCCESS) {
            ESP_LOGE(GATTS_TAG, "Advertising stop failed");
        } else {
            ESP_LOGI(GATTS_TAG, "Stop adv successfully");
        }
        break;
    case ESP_GAP_BLE_UPDATE_CONN_PARAMS_EVT:
        current_cmd = stop_CMD;
         ESP_LOGI(GATTS_TAG, "update connection params status = %d, min_int = %d, max_int = %d,conn_int = %d,latency = %d, timeout = %d",
                  param->update_conn_params.status,
                  param->update_conn_params.min_int,
                  param->update_conn_params.max_int,
                  param->update_conn_params.conn_int,
                  param->update_conn_params.latency,
                  param->update_conn_params.timeout);
        break;
    case ESP_GAP_BLE_SET_PKT_LENGTH_COMPLETE_EVT:
        ESP_LOGI(GATTS_TAG, "packet length updated: rx = %d, tx = %d, status = %d",
                  param->pkt_data_length_cmpl.params.rx_len,
                  param->pkt_data_length_cmpl.params.tx_len,
                  param->pkt_data_length_cmpl.status);
        break;
    default:
        break;
    }
}

void example_write_event_env(esp_gatt_if_t gatts_if, prepare_type_env_t *prepare_write_env, esp_ble_gatts_cb_param_t *param){
    esp_gatt_status_t status = ESP_GATT_OK;
    if (param->write.need_rsp){
        if (param->write.is_prep) {
            if (param->write.offset > PREPARE_BUF_MAX_SIZE) {
                status = ESP_GATT_INVALID_OFFSET;
            } else if ((param->write.offset + param->write.len) > PREPARE_BUF_MAX_SIZE) {
                status = ESP_GATT_INVALID_ATTR_LEN;
            }
            if (status == ESP_GATT_OK && prepare_write_env->prepare_buf == NULL) {
                prepare_write_env->prepare_buf = (uint8_t *)malloc(PREPARE_BUF_MAX_SIZE*sizeof(uint8_t));
                prepare_write_env->prepare_len = 0;
                if (prepare_write_env->prepare_buf == NULL) {
                    ESP_LOGE(GATTS_TAG, "Gatt_server prep no mem");
                    status = ESP_GATT_NO_RESOURCES;
                }
            }

            esp_gatt_rsp_t *gatt_rsp = (esp_gatt_rsp_t *)malloc(sizeof(esp_gatt_rsp_t));
            if (gatt_rsp) {
                gatt_rsp->attr_value.len = param->write.len;
                gatt_rsp->attr_value.handle = param->write.handle;
                gatt_rsp->attr_value.offset = param->write.offset;
                gatt_rsp->attr_value.auth_req = ESP_GATT_AUTH_REQ_NONE;
                memcpy(gatt_rsp->attr_value.value, param->write.value, param->write.len);
                esp_err_t response_err = esp_ble_gatts_send_response(gatts_if, param->write.conn_id, param->write.trans_id, status, gatt_rsp);
                if (response_err != ESP_OK){
                    ESP_LOGE(GATTS_TAG, "Send response error\n");
                }
                free(gatt_rsp);
            } else {
                ESP_LOGE(GATTS_TAG, "malloc failed, no resource to send response error\n");
                status = ESP_GATT_NO_RESOURCES;
            }
            if (status != ESP_GATT_OK){
                return;
            }
            memcpy(prepare_write_env->prepare_buf + param->write.offset,
                   param->write.value,
                   param->write.len);
            prepare_write_env->prepare_len += param->write.len;

        }else{
            esp_ble_gatts_send_response(gatts_if, param->write.conn_id, param->write.trans_id, status, NULL);
        }
    }
}

void example_exec_write_event_env(prepare_type_env_t *prepare_write_env, esp_ble_gatts_cb_param_t *param){
    if (param->exec_write.exec_write_flag == ESP_GATT_PREP_WRITE_EXEC){
        esp_log_buffer_hex(GATTS_TAG, prepare_write_env->prepare_buf, prepare_write_env->prepare_len);
    }else{
        ESP_LOGI(GATTS_TAG,"ESP_GATT_PREP_WRITE_CANCEL");
    }
    if (prepare_write_env->prepare_buf) {
        free(prepare_write_env->prepare_buf);
        prepare_write_env->prepare_buf = NULL;
    }
    prepare_write_env->prepare_len = 0;
}

static void gatts_profile_a_event_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param) {
    switch (event) {
    case ESP_GATTS_REG_EVT:
        ESP_LOGI(GATTS_TAG, "REGISTER_APP_EVT, status %d, app_id %d", param->reg.status, param->reg.app_id);
        gl_profile_tab[PROFILE_A_APP_ID].service_id.is_primary = true;
        gl_profile_tab[PROFILE_A_APP_ID].service_id.id.inst_id = 0x00;
        gl_profile_tab[PROFILE_A_APP_ID].service_id.id.uuid.len = ESP_UUID_LEN_16;
        gl_profile_tab[PROFILE_A_APP_ID].service_id.id.uuid.uuid.uuid16 = GATTS_SERVICE_UUID_TEST_A;

        esp_err_t set_dev_name_ret = esp_ble_gap_set_device_name(TEST_DEVICE_NAME);
        if (set_dev_name_ret){
            ESP_LOGE(GATTS_TAG, "set device name failed, error code = %x", set_dev_name_ret);
        }
#ifdef CONFIG_SET_RAW_ADV_DATA
        esp_err_t raw_adv_ret = esp_ble_gap_config_adv_data_raw(raw_adv_data, sizeof(raw_adv_data));
        if (raw_adv_ret){
            ESP_LOGE(GATTS_TAG, "config raw adv data failed, error code = %x ", raw_adv_ret);
        }
        adv_config_done |= adv_config_flag;
        esp_err_t raw_scan_ret = esp_ble_gap_config_scan_rsp_data_raw(raw_scan_rsp_data, sizeof(raw_scan_rsp_data));
        if (raw_scan_ret){
            ESP_LOGE(GATTS_TAG, "config raw scan rsp data failed, error code = %x", raw_scan_ret);
        }
        adv_config_done |= scan_rsp_config_flag;
#else
        //config adv data
        esp_err_t ret = esp_ble_gap_config_adv_data(&adv_data);
        if (ret){
            ESP_LOGE(GATTS_TAG, "config adv data failed, error code = %x", ret);
        }
        adv_config_done |= adv_config_flag;
        //config scan response data
        ret = esp_ble_gap_config_adv_data(&scan_rsp_data);
        if (ret){
            ESP_LOGE(GATTS_TAG, "config scan response data failed, error code = %x", ret);
        }
        adv_config_done |= scan_rsp_config_flag;

#endif
        esp_ble_gatts_create_service(gatts_if, &gl_profile_tab[PROFILE_A_APP_ID].service_id, GATTS_NUM_HANDLE_TEST_A);
        break;
    case ESP_GATTS_READ_EVT: {
        ESP_LOGI(GATTS_TAG, "GATT_READ_EVT, conn_id %d, trans_id %" PRIu32 ", handle %d", param->read.conn_id, param->read.trans_id, param->read.handle);
        // esp_gatt_rsp_t rsp;
        // memset(&rsp, 0, sizeof(esp_gatt_rsp_t));
        // rsp.attr_value.handle = param->read.handle;
        // rsp.attr_value.len = 2;
        // uint16_t soc = battery_life();
        // rsp.attr_value.value[0] = soc & 0xFF;
        // rsp.attr_value.value[1] = (soc >> 8) & 0xFF;
        // esp_ble_gatts_send_response(gatts_if, param->read.conn_id, param->read.trans_id,
        //                             ESP_GATT_OK, &rsp);
        // break;
    }
    case ESP_GATTS_WRITE_EVT: {
        ESP_LOGI(GATTS_TAG, "GATT_WRITE_EVT, conn_id %d, trans_id %" PRIu32 ", handle %d", 
                 param->write.conn_id, param->write.trans_id, param->write.handle);
    
        if (param->write.len > 0) {
            ASCII_VALUE = param->write.value[0]; // Store new value globally
            ESP_LOGE(GATTS_TAG, "Received ASCII Value: %d", ASCII_VALUE);
        }
        else{
            printf("Did not recieve anything");
        }
    
        // static bool o_scope = false; // Keep its value between writes
    
        if(ASCII_VALUE == 0){
            current_cmd = stop_CMD;
            xTaskNotifyGive(data_task_handle);
            printf("STOPPING FUNCTION");
        }
        else if(ASCII_VALUE == 79){
            //OSCOPE FUNCTION
           current_cmd = 1; 
           GATTS_IF = gatts_if;
           CONN_ID = param->write.conn_id;
           ATTR_HANDLE = gl_profile_tab[PROFILE_A_APP_ID].char_handle;
           xTaskNotifyGive(data_task_handle);
        }
        else if(ASCII_VALUE == 76){
            //LOGIC FUNCTION
            current_cmd = 5;
            GATTS_IF = gatts_if;
            CONN_ID = param->write.conn_id;
            ATTR_HANDLE = gl_profile_tab[PROFILE_A_APP_ID].char_handle;
            xTaskNotifyGive(data_task_handle);
        }
        else if(ASCII_VALUE == 73){
            // I2C FUNCTION
            current_cmd = 3;
            GATTS_IF = gatts_if;
            CONN_ID = param->write.conn_id;
            ATTR_HANDLE = gl_profile_tab[PROFILE_A_APP_ID].char_handle;
            xTaskNotifyGive(data_task_handle);
        }
        else if (ASCII_VALUE ==  80){
            //SPI FUNCTION
            current_cmd = 4;
            GATTS_IF = gatts_if;
            CONN_ID = param->write.conn_id;
            ATTR_HANDLE = gl_profile_tab[PROFILE_A_APP_ID].char_handle;
            xTaskNotifyGive(data_task_handle);
        }
        else if (ASCII_VALUE == 83){
            //SERIAL
            current_cmd = 2;
            GATTS_IF = gatts_if;
            CONN_ID = param->write.conn_id;
            ATTR_HANDLE = gl_profile_tab[PROFILE_A_APP_ID].char_handle;
            Serial_Type = param->write.value[1];
            Baud_rate = param->write.value[2];
            xTaskNotifyGive(data_task_handle);
        }
        else if( ASCII_VALUE == 11){
            //Battery life
            uint16_t soc = battery_life();
            printf("Sending bytes: %d" , soc);
            esp_ble_gatts_send_indicate(gatts_if, param->write.conn_id, gl_profile_tab[PROFILE_A_APP_ID].char_handle, 2U, &soc, false);
        }
    

    break;
}


    case ESP_GATTS_EXEC_WRITE_EVT:
        ESP_LOGI(GATTS_TAG,"ESP_GATTS_EXEC_WRITE_EVT");
        esp_ble_gatts_send_response(gatts_if, param->write.conn_id, param->write.trans_id, ESP_GATT_OK, NULL);
        example_exec_write_event_env(&a_prepare_write_env, param);
        break;
    case ESP_GATTS_MTU_EVT:
        ESP_LOGI(GATTS_TAG, "ESP_GATTS_MTU_EVT, MTU %d", param->mtu.mtu);
        break;
    case ESP_GATTS_UNREG_EVT:
        break;
    case ESP_GATTS_CREATE_EVT:
        ESP_LOGI(GATTS_TAG, "CREATE_SERVICE_EVT, status %d,  service_handle %d", param->create.status, param->create.service_handle);
        gl_profile_tab[PROFILE_A_APP_ID].service_handle = param->create.service_handle;
        gl_profile_tab[PROFILE_A_APP_ID].char_uuid.len = ESP_UUID_LEN_16;
        gl_profile_tab[PROFILE_A_APP_ID].char_uuid.uuid.uuid16 = GATTS_CHAR_UUID_TEST_A;

        esp_ble_gatts_start_service(gl_profile_tab[PROFILE_A_APP_ID].service_handle);
        a_property = ESP_GATT_CHAR_PROP_BIT_READ | ESP_GATT_CHAR_PROP_BIT_WRITE | ESP_GATT_CHAR_PROP_BIT_NOTIFY| ESP_GATT_CHAR_PROP_BIT_INDICATE;
        esp_err_t add_char_ret = esp_ble_gatts_add_char(gl_profile_tab[PROFILE_A_APP_ID].service_handle, &gl_profile_tab[PROFILE_A_APP_ID].char_uuid,
                                                        ESP_GATT_PERM_READ | ESP_GATT_PERM_WRITE,
                                                        a_property,
                                                        &gatts_demo_char1_val, NULL);
    case ESP_GATTS_ADD_INCL_SRVC_EVT:
        break;
    case ESP_GATTS_ADD_CHAR_EVT: {
        uint16_t length = 0;
        const uint8_t *prf_char;

        ESP_LOGI(GATTS_TAG, "ADD_CHAR_EVT, status %d,  attr_handle %d, service_handle %d",
                param->add_char.status, param->add_char.attr_handle, param->add_char.service_handle);
        gl_profile_tab[PROFILE_A_APP_ID].char_handle = param->add_char.attr_handle;
        gl_profile_tab[PROFILE_A_APP_ID].descr_uuid.len = ESP_UUID_LEN_16;
        gl_profile_tab[PROFILE_A_APP_ID].descr_uuid.uuid.uuid16 = ESP_GATT_UUID_CHAR_CLIENT_CONFIG;
        esp_err_t get_attr_ret = esp_ble_gatts_get_attr_value(param->add_char.attr_handle,  &length, &prf_char);
        if (get_attr_ret == ESP_FAIL){
            ESP_LOGE(GATTS_TAG, "ILLEGAL HANDLE");
        }

        ESP_LOGI(GATTS_TAG, "the gatts demo char length = %x", length);
        for(int i = 0; i < length; i++){
            ESP_LOGI(GATTS_TAG, "prf_char[%x] =%x",i,prf_char[i]);
        }
        esp_err_t add_descr_ret = esp_ble_gatts_add_char_descr(gl_profile_tab[PROFILE_A_APP_ID].service_handle, &gl_profile_tab[PROFILE_A_APP_ID].descr_uuid,
                                                                ESP_GATT_PERM_READ | ESP_GATT_PERM_WRITE, NULL, NULL);
        if (add_descr_ret){
            ESP_LOGE(GATTS_TAG, "add char descr failed, error code =%x", add_descr_ret);
        }
        break;
    }
    case ESP_GATTS_ADD_CHAR_DESCR_EVT:
        gl_profile_tab[PROFILE_A_APP_ID].descr_handle = param->add_char_descr.attr_handle;
        ESP_LOGI(GATTS_TAG, "ADD_DESCR_EVT, status %d, attr_handle %d, service_handle %d",
                 param->add_char_descr.status, param->add_char_descr.attr_handle, param->add_char_descr.service_handle);
        break;
    case ESP_GATTS_DELETE_EVT:
        break;
    case ESP_GATTS_START_EVT:
        ESP_LOGI(GATTS_TAG, "SERVICE_START_EVT, status %d, service_handle %d",
                 param->start.status, param->start.service_handle);
        break;
    case ESP_GATTS_STOP_EVT:
        break;
    case ESP_GATTS_CONNECT_EVT: {
        current_cmd = stop_CMD;
        esp_ble_conn_update_params_t conn_params = {0};
        memcpy(conn_params.bda, param->connect.remote_bda, sizeof(esp_bd_addr_t));
        /* For the IOS system, please reference the apple official documents about the ble connection parameters restrictions. */
        conn_params.latency = 0;
        conn_params.max_int = 0x20;    // max_int = 0x20*1.25ms = 40ms
        conn_params.min_int = 0x10;    // min_int = 0x10*1.25ms = 20ms
        conn_params.timeout = 400;    // timeout = 400*10ms = 4000ms
        ESP_LOGI(GATTS_TAG, "ESP_GATTS_CONNECT_EVT, conn_id %d, remote %02x:%02x:%02x:%02x:%02x:%02x:",
                 param->connect.conn_id,
                 param->connect.remote_bda[0], param->connect.remote_bda[1], param->connect.remote_bda[2],
                 param->connect.remote_bda[3], param->connect.remote_bda[4], param->connect.remote_bda[5]);
        gl_profile_tab[PROFILE_A_APP_ID].conn_id = param->connect.conn_id;
        //start sent the update connection parameters to the peer device.
        esp_ble_gap_update_conn_params(&conn_params);
        break;
    }
    case ESP_GATTS_DISCONNECT_EVT:
        ESP_LOGI(GATTS_TAG, "ESP_GATTS_DISCONNECT_EVT, disconnect reason 0x%x", param->disconnect.reason);
        current_cmd = stop_CMD;
        esp_ble_gap_start_advertising(&adv_params);
        break;
    case ESP_GATTS_CONF_EVT:
        ESP_LOGI(GATTS_TAG, "ESP_GATTS_CONF_EVT, status %d attr_handle %d", param->conf.status, param->conf.handle);
        if (param->conf.status != ESP_GATT_OK){
            esp_log_buffer_hex(GATTS_TAG, param->conf.value, param->conf.len);
        }
        break;
    case ESP_GATTS_OPEN_EVT:
    case ESP_GATTS_CANCEL_OPEN_EVT:
    case ESP_GATTS_CLOSE_EVT:
    case ESP_GATTS_LISTEN_EVT:
    case ESP_GATTS_CONGEST_EVT:
    default:
        break;
    }
}



static void gatts_event_handler(esp_gatts_cb_event_t event, esp_gatt_if_t gatts_if, esp_ble_gatts_cb_param_t *param)
{
    /* If event is register event, store the gatts_if for each profile */
    if (event == ESP_GATTS_REG_EVT) {
        if (param->reg.status == ESP_GATT_OK) {
            gl_profile_tab[param->reg.app_id].gatts_if = gatts_if;
        } else {
            ESP_LOGI(GATTS_TAG, "Reg app failed, app_id %04x, status %d",
                    param->reg.app_id,
                    param->reg.status);
            return;
        }
    }

    /* If the gatts_if equal to profile A, call profile A cb handler,
     * so here call each profile's callback */
    do {
        int idx;
        for (idx = 0; idx < PROFILE_NUM; idx++) {
            if (gatts_if == ESP_GATT_IF_NONE || /* ESP_GATT_IF_NONE, not specify a certain gatt_if, need to call every profile cb function */
                    gatts_if == gl_profile_tab[idx].gatts_if) {
                if (gl_profile_tab[idx].gatts_cb) {
                    gl_profile_tab[idx].gatts_cb(event, gatts_if, param);
                }
            }
        }
    } while (0);
}

// O-Scope function
int o_scope_function(uint8_t device_address, uint8_t *data, size_t data_length) {
    // static i2c_master_bus_handle_t bus_handle = NULL;  // Make bus handle persistent

    // if (bus_handle == NULL) {  // Initialize bus only if not already initialized
    //     i2c_master_bus_config_t bus_cfg = {
    //         .i2c_port = I2C_NUM_0,
    //         .scl_io_num = I2C_MASTER_SCL_IO,
    //         .sda_io_num = I2C_MASTER_SDA_IO,
    //         .clk_source = I2C_CLK_SRC_DEFAULT,
    //         .glitch_ignore_cnt = 7,
    //         .flags.enable_internal_pullup = true
    //     };

    //     ESP_ERROR_CHECK(i2c_new_master_bus(&bus_cfg, &bus_handle));
    // }

    i2c_device_config_t dev_cfg = {
        .dev_addr_length = I2C_ADDR_BIT_LEN_7,
        .device_address = device_address,  // Use function parameter
        .scl_speed_hz = I2C_MASTER_FREQ_HZ
    };
    i2c_master_dev_handle_t dev_handle;
    uint8_t register_name = 0;
    uint8_t tx_buffer[3];
    tx_buffer[0] = 0x01;      // Register address
    tx_buffer[1] = 0x04;      // Data byte 1
    tx_buffer[2] = 0xE3;      // Data byte 2

    ESP_ERROR_CHECK(i2c_master_bus_add_device(bus_handle, &dev_cfg, &dev_handle));
    ESP_ERROR_CHECK(i2c_master_transmit(dev_handle, tx_buffer, sizeof(tx_buffer), 100));
    ESP_ERROR_CHECK(i2c_master_transmit(dev_handle, &register_name, sizeof(register_name), 100));
    ESP_ERROR_CHECK(i2c_master_receive(dev_handle, data, data_length, 100));
    i2c_master_bus_rm_device(dev_handle); // Remove device after communication

    return data_length;
}

//SPI
int MISO = 0;
int MOSI = 0;
int CS = 0;
int CLK_SPI = 0;
uint8_t bits_collected = 0;
uint8_t MISO_buffer = 0;
uint8_t MOSI_buffer = 0;
uint8_t CS_buffer = 0;
uint8_t SCLK_buffer = 0;
volatile uint32_t DATA_send = 0;

void IRAM_ATTR spi_sniffer_isr(void *arg) {
    MOSI = gpio_get_level(GPIO_MOSI);  // Read MOSI
    MISO = gpio_get_level(GPIO_MISO);  // Read MISO
    CS = gpio_get_level(GPIO_CS);     // Read CS (optional, useful for transaction tracking)
    CLK_SPI = gpio_get_level(GPIO_SCLK);

    MISO_buffer = (MISO_buffer << 1) | (MISO & 0x01);
    MOSI_buffer = (MOSI_buffer << 1) | (MOSI & 0x01);
    CS_buffer = (CS_buffer << 1) | (CS & 0x01);
    SCLK_buffer = (SCLK_buffer << 1) | (CLK_SPI & 0x01);
    bits_collected++;

     if (bits_collected >= 8) {
        // Once 8 bits collected from each line, form the 32-bit word:
        // [SCLK (8 bits) | MOSI (8 bits) | MISO (8 bits) | CS (8 bits)]
        uint32_t packet = 0;
        packet |= ((uint32_t)SCLK_buffer) << 24;
        packet |= ((uint32_t)MOSI_buffer) << 16;
        packet |= ((uint32_t)MISO_buffer) << 8;
        packet |= ((uint32_t)CS_buffer);

        // Send to queue
        xQueueSendFromISR(spi_data_queue, &packet, NULL);

        // Reset for next capture
        MISO_buffer = 0;
        MOSI_buffer = 0;
        CS_buffer = 0;
        SCLK_buffer = 0;
        bits_collected = 0;
    }
}
void setup_spi_sniffer() {
    // Configure SCLK (SPI Clock) as input with interrupt on rising edge
    gpio_config_t io_conf = {
        .pin_bit_mask = (1ULL << GPIO_SCLK),
        .mode = GPIO_MODE_INPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_ANYEDGE  // Interrupt on rising edge
    };
    gpio_config(&io_conf);

    // Configure MOSI, MISO, and CS as inputs
    gpio_config_t io_conf_data = {
        .pin_bit_mask = (1ULL << GPIO_MOSI) | (1ULL << GPIO_MISO) | (1ULL << GPIO_CS),
        .mode = GPIO_MODE_INPUT,
        .pull_up_en = GPIO_PULLUP_DISABLE,
        .pull_down_en = GPIO_PULLDOWN_DISABLE,
        .intr_type = GPIO_INTR_DISABLE
    };
    gpio_config(&io_conf_data);

    // Install ISR service
    gpio_install_isr_service(0);
    gpio_isr_handler_add(GPIO_SCLK, spi_sniffer_isr, NULL);

    ESP_LOGI(TAG, "SPI Sniffer initialized on SCLK: %d, MOSI: %d, MISO: %d, CS: %d", 
             GPIO_SCLK, GPIO_MOSI, GPIO_MISO, GPIO_CS);
}

int Serial_data(uint8_t *data1, uint8_t *data2, size_t data_length, size_t type, size_t rate) {
    int uart_len1 = 0;
    int uart_len2 = 0;
    int baud_rate = (rate == 0) ? 9600 : rate;

    // UART INIT
    uart_config_t uart_config = {
        .baud_rate = baud_rate,
        .data_bits = UART_DATA_8_BITS,
        .parity = UART_PARITY_DISABLE,
        .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE,
    };

    // Check if the UART driver is already installed
    if (!uart_is_driver_installed(UART_NUM_1)) {
        uart_param_config(UART_NUM_1, &uart_config);
        uart_driver_install(UART_NUM_1, 1024, 1024, 10, NULL, 0);
        uart_set_pin(UART_NUM_1, TXD1_PIN, RXD1_PIN, UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE);
    }

    if (!uart_is_driver_installed(UART_NUM_0)) {
        uart_param_config(UART_NUM_0, &uart_config);
        uart_set_pin(UART_NUM_0, TXD2_PIN, RXD2_PIN, UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE);
        uart_driver_install(UART_NUM_0, 1024, 1024, 10, NULL, 0);
    }

    // Flush UART buffers
    esp_err_t ret = uart_flush(UART_NUM_1);
    esp_err_t tret = uart_flush(UART_NUM_0);
    if (ret == ESP_OK && tret == ESP_OK) {
        printf("UART buffers cleared.\n");
    } else {
        printf("Failed to clear UART buffers. Error: %s\n", esp_err_to_name(ret));
    }

    // GPIO configuration (for type)
    if (type != 99) {
        gpio_config_t io_conf_1 = {
            .intr_type = GPIO_INTR_DISABLE,
            .mode = GPIO_MODE_OUTPUT,
            .pin_bit_mask = (1ULL << GPIO_NUM_12),
            .pull_down_en = GPIO_PULLDOWN_DISABLE,
            .pull_up_en = GPIO_PULLUP_DISABLE,
        };
        gpio_config_t io_conf_2 = {
            .intr_type = GPIO_INTR_DISABLE,
            .mode = GPIO_MODE_OUTPUT,
            .pin_bit_mask = (1ULL << GPIO_NUM_14),
            .pull_down_en = GPIO_PULLDOWN_DISABLE,
            .pull_up_en = GPIO_PULLUP_DISABLE,
        };
        gpio_config(&io_conf_1);
        gpio_config(&io_conf_2);

        if (type == 1) {
            gpio_set_level(GPIO_NUM_12, 0); // TTL
            gpio_set_level(GPIO_NUM_14, 1);
        } else if (type == 2) {
            gpio_set_level(GPIO_NUM_12, 0); // MAX
            gpio_set_level(GPIO_NUM_14, 0);
        } else if (type == 3) {
            gpio_set_level(GPIO_NUM_12, 1); // THVD
            gpio_set_level(GPIO_NUM_14, 0);
        } else {
            printf("Wrong serial number\n");
        }
    }

    // Wait for UART data
    printf("Waiting for UART data...\n");
    uart_len1 = uart_read_bytes(UART_NUM_1, data1, data_length, 100 / portTICK_PERIOD_MS);
    uart_len2 = uart_read_bytes(UART_NUM_0, data2, data_length, 100 / portTICK_PERIOD_MS);

    printf("Read %d bytes from UART 1\n", uart_len1);
    printf("Read %d bytes from UART 2\n", uart_len2);

    return uart_len1 + uart_len2;
}



void notification_task(void *arg){
    while(1){
        if(current_cmd != stop_CMD){
            uint8_t data[20] = {0};
            uint8_t oscope_data[2] = {0};
            uint8_t data_serial[20] = {0};
            size_t data_len = sizeof(data);
            uint32_t data_to_send = 0;
            int txBytes = 0;
            int rxBytes = 0;
            uint8_t data_logic[1024] = {0};

            switch (current_cmd) {
                case 1:
                    data_len = o_scope_function(0x48, oscope_data, sizeof(oscope_data));
                    break;
                case 2:
                    Serial_data(data, data_serial, data_len, Serial_Type, Baud_rate);
                    break;
                case 3:
                    //I2C
                    char out_data[] = "2";
                    int len = strlen(out_data);
                    txBytes = uart_write_bytes(UART_NUM_2, out_data, len);
                    rxBytes = uart_read_bytes(UART_NUM_2, data_logic, sizeof(data_logic), 1000 / portTICK_PERIOD_MS);

                    break;
                case 4:
                    //SPI
                    break;
                case 5:
                    //Logic
                    
                        // Send character '1' over UART
                        char out_data1[] = "1";  // now it's a string
                        int len1 = strlen(out_data1);
                        txBytes = uart_write_bytes(UART_NUM_2, out_data1, len1);
                    
                        // Allocate receive buffer (make sure this is done outside if reused)
                         // Ensure data is allocated and zero-initialized
                    
                        // Read bytes from UART
                        rxBytes = uart_read_bytes(UART_NUM_2, data_logic, sizeof(data_logic), 1000 / portTICK_PERIOD_MS);
                    
                    break;
                    
                    
                default:
                    printf("Invalid command received.\n");
                    break;
            }
        
    
        if (current_cmd == 1) {  // Send data only if available
            esp_err_t ret = esp_ble_gatts_send_indicate(
                GATTS_IF, CONN_ID, ATTR_HANDLE, data_len, oscope_data, false  // false = Notification
            );
        
            if (ret == ESP_OK) {
                printf("Notification sent: ");
                for (size_t i = 0; i < data_len; i++) {
                    printf("0x%02X ", oscope_data[i]);  // Print each byte in hexadecimal format
                }
                printf("\n");
            } else {
                printf("Notification failed: %d\n", ret);
            }
            
        } 
        else if(current_cmd == 2){
            esp_ble_gatts_send_indicate(GATTS_IF, CONN_ID, ATTR_HANDLE, sizeof(data), data, false);
            vTaskDelay(50 / portTICK_PERIOD_MS);
            esp_ble_gatts_send_indicate(GATTS_IF, CONN_ID, ATTR_HANDLE, sizeof(data_serial), data_serial, false);
        }
        else if(current_cmd == 4){
            uint32_t spi_data = 0;
            vTaskDelay(50 / portTICK_PERIOD_MS);
            // Wait max 100ms for SPI data from queue
            if(xQueueReceive(spi_data_queue, &spi_data, pdMS_TO_TICKS(100)) == pdTRUE) {
                // printf("SPI Notification sent: 0x%"PRIX32"\n", spi_data);
                esp_ble_gatts_send_indicate(GATTS_IF, CONN_ID, ATTR_HANDLE, sizeof(spi_data), (uint8_t*)&spi_data, false);
                printf("Sending bytes: %02X %02X %02X %02X\n",
                    ((uint8_t*)&spi_data)[0], // CS
                    ((uint8_t*)&spi_data)[1], // miso
                    ((uint8_t*)&spi_data)[2], // mosi
                    ((uint8_t*)&spi_data)[3]); // sclk
            }
        }        
        else if(current_cmd == 5){ // Still needs handled
            esp_ble_gatts_send_indicate(GATTS_IF, CONN_ID, ATTR_HANDLE, rxBytes, data_logic, false);
        }
        else if(current_cmd == 3 ){ // Still needs handled
            esp_ble_gatts_send_indicate(GATTS_IF, CONN_ID, ATTR_HANDLE, rxBytes, data_logic, false);
        }
    }
        xTaskNotifyWait(0, 0, NULL, pdMS_TO_TICKS(500));  // Adjust rate
    }
}

uint16_t battery_life(){
    uint8_t command = 0x2C;
    uint8_t data[2];
    i2c_device_config_t dev_cfg = {
        .dev_addr_length = I2C_ADDR_BIT_LEN_7,
        .device_address = 0x0B,  // Use function parameter
        .scl_speed_hz = I2C_MASTER_FREQ_HZ
    };
    i2c_master_dev_handle_t dev_handle1;
    ESP_ERROR_CHECK(i2c_master_bus_add_device(bus_handle, &dev_cfg, &dev_handle1));
    esp_err_t ret = i2c_master_transmit_receive(dev_handle1, &command, 1U, &data, 2U, -1);
    
    if(ret != ESP_OK){
        ESP_LOGE("BATTERY" , "I2C read failed: %s", esp_err_to_name(ret));
        return 0xFFFF;
    }
    return (uint16_t)(data[0] | (data[1] << 8));
}
void app_main(void)
{
    esp_err_t ret;
    
    uart_config_t uart_config = {
        .baud_rate = 115200,
        .data_bits = UART_DATA_8_BITS,
        .parity = UART_PARITY_DISABLE,
        .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE,
    };
    uart_param_config(UART_NUM_2, &uart_config);
    uart_driver_install(UART_NUM_2, 1024, 1024, 10, NULL, 0);
    uart_set_pin(UART_NUM_2, TXD3_PIN, RXD3_PIN, UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE);

      // Make bus handle persistent
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

    xTaskCreate(notification_task, "Notification Task", 4096, NULL, 1, &data_task_handle);
    setup_spi_sniffer();
    spi_data_queue = xQueueCreate(32, sizeof(uint32_t));
    ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK( ret );

    ESP_ERROR_CHECK(esp_bt_controller_mem_release(ESP_BT_MODE_CLASSIC_BT));

    esp_bt_controller_config_t bt_cfg = BT_CONTROLLER_INIT_CONFIG_DEFAULT();
    ret = esp_bt_controller_init(&bt_cfg);
    if (ret) {
        ESP_LOGE(GATTS_TAG, "%s initialize controller failed: %s", __func__, esp_err_to_name(ret));
        return;
    }

    ret = esp_bt_controller_enable(ESP_BT_MODE_BLE);
    if (ret) {
        ESP_LOGE(GATTS_TAG, "%s enable controller failed: %s", __func__, esp_err_to_name(ret));
        return;
    }

    ret = esp_bluedroid_init();
    if (ret) {
        ESP_LOGE(GATTS_TAG, "%s init bluetooth failed: %s", __func__, esp_err_to_name(ret));
        return;
    }
    ret = esp_bluedroid_enable();
    if (ret) {
        ESP_LOGE(GATTS_TAG, "%s enable bluetooth failed: %s", __func__, esp_err_to_name(ret));
        return;
    }

    ret = esp_ble_gatts_register_callback(gatts_event_handler);
    if (ret){
        ESP_LOGE(GATTS_TAG, "gatts register error, error code = %x", ret);
        return;
    }
    ret = esp_ble_gap_register_callback(gap_event_handler);
    if (ret){
        ESP_LOGE(GATTS_TAG, "gap register error, error code = %x", ret);
        return;
    }
    ret = esp_ble_gatts_app_register(PROFILE_A_APP_ID);
    if (ret){
        ESP_LOGE(GATTS_TAG, "gatts app register error, error code = %x", ret);
        return;
    }
    esp_err_t local_mtu_ret = esp_ble_gatt_set_local_mtu(500);
    if (local_mtu_ret){
        ESP_LOGE(GATTS_TAG, "set local  MTU failed, error code = %x", local_mtu_ret);
    }

    return;
}
