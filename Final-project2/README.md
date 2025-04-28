This Project is created in ESP-IDF in vscode. 
The Project is a BLE server host that offers different functions under the same characteristic,
the functions are:
O-Scope when recieving the number 79:
which runs a function that grabs data from a perfieral device via I2C and sends them to the Client as a buffer of size 2U.
Logic Function when recieving the number 76:
which runs a function that grabs data from 16 GPIO pins via an I2C perfieral device
I2C passive listener when recieving the number 73:
which runs GPIO interupts on a perfieral deivce(esp32) that grabs the data on the I2C serial lines
SPI passive listner recieving the number 80:
which runs GPIO interupts that returns the data on the serial lines for SPI
Serial decoder for Rs-232,485 and TTL when recieving 83:
runs the selected serial port and sends the client a UART buffer of the data collected
Battery percetange is returned when the number 11 is recieved
