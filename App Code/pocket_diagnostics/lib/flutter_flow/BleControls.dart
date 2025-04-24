//import 'dart:ffi';

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

import 'package:pocket_diagnostics/app_state.dart';
import 'package:pocket_diagnostics/ic_inspector/ic_inspector_widget.dart';
//import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleController extends GetxController{
  FlutterBlue flutterBlue = FlutterBlue.instance;


  Future scanDevices() async{
    if (await Permission.bluetoothScan.request().isGranted){
      if (await Permission.bluetoothConnect.request().isGranted){


        // Start scanning for devices
        flutterBlue.startScan(timeout: const Duration(seconds: 5));

        flutterBlue.stopScan();
      }
    }
  }

  Future<void> connectToDevice(BluetoothDevice device)async {
    await device.connect(timeout: const Duration(seconds: 1));
    device.state.listen((isConnected) async {
      if(isConnected == BluetoothDeviceState.connecting){
        print("Device connecting to: ${device.name}");
      }else if(isConnected == BluetoothDeviceState.connected){
        print("Device connected: ${device.name}");
        FFAppState().device = device;
        if (Platform.isAndroid) {
          try {
            Future<void> mtu = device.requestMtu(512);
            print("Negotiated MTU: $mtu bytes");
          } catch (e) {
            print("MTU request failed: $e");
          }
      }
      
        
      }
      else{
        print("Device Disconnected");
      }
    });
  }
  Future<void> reconnectDevice() async {
    BluetoothDevice? currentDevice = FFAppState().device;
    if (currentDevice == null) {
      print("No device currently connected to reconnect");
      return;
    }

    try {
      // Step 1: Disconnect the device
      print("Disconnecting from ${currentDevice.name}...");
      await currentDevice.disconnect();
      
      // Step 2: Wait briefly to ensure disconnection completes
      await Future.delayed(const Duration(milliseconds: 500));

      // Step 3: Reconnect to the same device
      print("Reconnecting to ${currentDevice.name}...");
      await connectToDevice(currentDevice);

      // Optional: Wait for connection confirmation
      await for (BluetoothDeviceState state in currentDevice.state) {
        if (state == BluetoothDeviceState.connected) {
          print("Reconnection successful: ${currentDevice.name}");
          break;
        } else if (state == BluetoothDeviceState.disconnected) {
          print("Reconnection failed: Device disconnected");
          break;
        }
      }
    } catch (e) {
      print("Error during reconnect: $e");
    }
  }
  Future<void> sendFuncType(int appState, BluetoothDevice? device) async {
    if (device !=null){
      List <BluetoothService> services =await device.discoverServices();
      for (BluetoothService service in services ){
        for (BluetoothCharacteristic c in service.characteristics){
          if (c.properties.write){
            if (appState==1){ //Oscilloscope state
              //List<int > signalType = utf8.encode('O');
              //int largeNumb = (SampleTime >> 8) & 0xFF;
              //int smallNumb = SampleTime & 0xFF;
              List<int> signal = [79]; //Format: encoded signalType, integer divided sampleTime, remainder sample time
              print(signal);
              c.write(signal, withoutResponse:true);
              print("signal sent");
            }
            else if (appState==2){ //i^2 C inspector
              //List<int> signalType = [73];
              List<int> signal = [73]; //Format: encoded signalType, integer divided sampleTime, remainder sample time
              await c.write(signal, withoutResponse:true);
            }
            else if (appState==3){ //logic analyzer
              List<int> signalType = utf8.encode('L');
              List<int> signal = [signalType[0]]; //Format: encoded signalType, integer divided sampleTime, remainder sample time
              await c.write(signal, withoutResponse:false);
            }
            else if (appState == 4){ //Serial Port sniffer
              List<int> signalType = [];
              signalType.add(83);
              if (FFAppState().serialProtocol == 'RS-232'){
                signalType.add(2);
              }
              else if (FFAppState().serialProtocol == 'RS-485'){
                signalType.add(3);
              }
              else if (FFAppState().serialProtocol== 'TTL'){
                signalType.add(1);
              }
              List<int> signal = [signalType[0], signalType[1], FFAppState().ClockBaude]; //Format: encoded signalType, integer divided sampleTime, remainder sample time
              print(signal);
              await c.write(signal, withoutResponse:false);
            }
            else if (appState==5){ //SPI inspector
              //List<int> signalType = utf8.encode('P');
              List<int> signal = [80]; //Format: encoded signalType, integer divided sampleTime, remainder sample time
              await c.write(signal, withoutResponse:false);
            }
            else if (appState==6){ //Battery Indicator
              List<int> signal = [11]; 
              await c.write(signal, withoutResponse:false);
            }
            else if (appState==0){ //Stop send
              List<int> signal = [0]; //Format: encoded signalType, integer divided sampleTime, remainder sample time
              await c.write(signal, withoutResponse:false);
            }





            else { 
              print("No clear data type was indicated");
            }
          }
        }
      }
    }
    else {
      print("No device is connected");
    }
    return;
  }
  
  Future<void> recieveData(int appState, BluetoothDevice? device, [int sampleTime = 0]) async { //Incomplete
    if (device!=null){
      BluetoothCharacteristic? characteristic=null;
      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services){
        for (BluetoothCharacteristic characteristics in service.characteristics){
          if (characteristics.properties.notify==true){
            print("Notify characteristic found");
            characteristic = characteristics;
            
          }
        }
      }

      if (characteristic!=null){
        StreamSubscription<List<int>>? subscription;
        characteristic.setNotifyValue(true); //Opening stream for listening
        characteristic.setNotifyValue(true).timeout(Duration(seconds: 5));
      
        if (appState==1){   //Oscilloscope
          FFAppState().OscopeVoltage.clear();
          FFAppState().OscopeTime.clear(); 
          FFAppState().OscopeIndex=0;
          subscription = characteristic.value.listen((data){
            print(data);
            int value;
            for (int i=0; i <data.length; i+=2){
              if (data.length>2){
                value = (data[i]<<8 | data[i+1]);
                value = value >> 4;
                if (value & 0x800 != 0) { // Sign-extend if negative
                  value = value - 0x1000; // Convert to negative (-2048 to -1)
                }
                // Convert to voltage: -2048 maps to -3.3V, +2047 maps to +3.3V
                double voltage = (value / 2047.0) * 3.3;
                if (FFAppState().OscopeIndex * 1000 / 3300 > FFAppState().SampleTime && FFAppState().OscopeTime.isNotEmpty) {
                  // Update existing index if time exceeds sampleTime
                  return;
                } 
                else {
                  // Add new data point
                  FFAppState().addToOscopeVoltage(voltage);
                  FFAppState().addToOscopeTime(FFAppState().OscopeIndex * 1000 / 3300);
                }
                FFAppState().OscopeIndex += 1;
              }
            }
            FFAppState().update(() {
              FFAppState().OscopeVoltage; // Example custom logic
              FFAppState().OscopeTime;
              FFAppState().controller.notifyChildrens();
            });
            if (FFAppState().appState == 0){
              characteristic?.setNotifyValue(false);
            }
            }, onError: (error) {
              print("Error receiving data: $error");
              characteristic?.setNotifyValue(false);
              subscription?.cancel();
            },
            onDone: () {
              print("Data stream completed.");
              characteristic?.setNotifyValue(false);
              subscription?.cancel();
            },
          );

        }
        else if (appState==2){   //I2C
          FFAppState().I2CData.clear();
          subscription = characteristic.value.listen((data){
            print(data);

            for (int i = 0; i <data.length; i+=4){
              if (data.length >= i + 4){
                int value = (data[i] | (data[i + 1] << 8) | (data[i + 2] << 16) | (data[i + 3] << 24));
                String binary = value.toRadixString(2).padLeft(32, '0');
                String valueString = "${binary.substring(0, 8)}|${binary.substring(8, 16)}|${binary.substring(16, 24)}|${binary.substring(24, 32)}";
                FFAppState().addToI2CData({
                  'time': '${DateTime.now().millisecondsSinceEpoch % 10000}ms',
                  'data': valueString, // Store as 32-bit binary string
                });
              }
            }
            FFAppState().update((){
              FFAppState().I2CData;
            });
            if (FFAppState().appState == 0){
              characteristic?.setNotifyValue(false);
            }
            }, 
            onError: (error) {
              print("Error receiving data: $error");
              characteristic?.setNotifyValue(false);
              subscription?.cancel();
            },
            onDone: () {
              print("Data stream completed.");
              characteristic?.setNotifyValue(false);
              subscription?.cancel();
            },
          );
        }
        else if (appState==3){   //Logic Analyzer
          FFAppState().LogicData.clear();
          FFAppState().LogicTime.clear();
          FFAppState().logicIndex=0;
          StreamSubscription<List<int>>? _subscription;
                if (FFAppState().LogicData.isEmpty || FFAppState().LogicData.length < 16) {
                  FFAppState().LogicData = List.generate(16, (_) => <int>[]);
                } else {
                  for (int j = 0; j < 16; j++) {
                    FFAppState().LogicData[j].clear(); // Clear each channel
                  }
                }
                FFAppState().LogicTime.clear();
                _subscription = characteristic.value.listen((data){
                  
                  print('Received Data: $data'); // Debugging output
                  if (FFAppState().appState == 0) {  // Stop when appState changes
                    print("Stopping data collection for appState 3.");
                    characteristic?.setNotifyValue(false);
                    _subscription?.cancel();
                    return;
                  }
                  for (int i = 0; i <= data.length - 4; i += 4) {
                    if (data.length >= i + 4) {
                      // First 16-bit value
                      int value1 = (data[i] | (data[i + 1] << 8));
                      String dataString1 = value1.toRadixString(2).padLeft(16, '0');
                      for (int j = 0; j < 16; j++) {
                        FFAppState().LogicData[j].add(int.parse(dataString1[j]));
                        FFAppState().LogicData[j].add(int.parse(dataString1[j]));
                      }
                      FFAppState().LogicTime.add(FFAppState().LogicTime.isEmpty ? 0 : FFAppState().LogicTime.last);
                      FFAppState().LogicTime.add(FFAppState().LogicTime.last + (1000 / FFAppState().ClockBaude));
                      print("Value1: $value1, binary: $dataString1");

                      // Second 16-bit value
                      int value2 = (data[i + 2] | (data[i + 3] << 8));
                      String dataString2 = value2.toRadixString(2).padLeft(16, '0');
                      for (int j = 0; j < 16; j++) {
                        FFAppState().LogicData[j].add(int.parse(dataString2[j]));
                        FFAppState().LogicData[j].add(int.parse(dataString2[j]));
                      }
                      FFAppState().LogicTime.add(FFAppState().LogicTime.last);
                      FFAppState().LogicTime.add(FFAppState().LogicTime.last + (1000 / FFAppState().ClockBaude));
                      print("Value2: $value2, binary: $dataString2");
                    }
                    print("LogicData: ${FFAppState().LogicData[0]}");
                  }
                  // Ensure LogicTime matches LogicData length

                  FFAppState().update(() {
                    FFAppState().LogicData; // Notify listeners
                    FFAppState().LogicTime;
                  });
                  
                }, onError: (error) {
                  print("Error receiving data: $error");
                  //characteristic?.setNotifyValue(false);
                  characteristic?.setNotifyValue(false);
                  _subscription?.cancel();
                },
                  onDone: () {
                    print("Data stream completed.");
                    characteristic?.setNotifyValue(false);
                    _subscription?.cancel();
                  },
                );
                device.state.listen((state) {
                  if (state == BluetoothDeviceState.disconnected) {
                    print("Device disconnected. Stopping data stream.");
                    characteristic?.setNotifyValue(false);
                    _subscription?.cancel();
                  }
                });
          
        }
        else if (appState==4){   //Serial Port Sniffer
          FFAppState().serialData.clear();

          subscription = characteristic.value.listen((data){
            print(data);

            for (int i = 0; i <data.length-3; i+=4){
              int value = (data[i] | (data[i + 1] << 8) | (data[i + 2] << 16) | (data[i + 3] << 24));
              String binary = value.toRadixString(2).padLeft(32, '0');
              String valueString = "${binary.substring(0, 8)}|${binary.substring(8, 16)}|${binary.substring(16, 24)}|${binary.substring(24, 32)}";
              FFAppState().addToserialData({
                'time': '${DateTime.now().millisecondsSinceEpoch % 10000}ms',
                'data': valueString, // Store as 32-bit binary string
              });
            }
            FFAppState().update((){
              FFAppState().serialData;
            });
            if (FFAppState().appState == 0){
              characteristic?.setNotifyValue(false);
            }
            },
            onError: (error) {
              print("Error receiving data: $error");
              characteristic?.setNotifyValue(false);
              subscription?.cancel();
            },
            onDone: () {
              print("Data stream completed.");
              characteristic?.setNotifyValue(false);
              subscription?.cancel();
            },
          );
          print("Serial Done");
        }
        else if (appState==5){  //SPI
          FFAppState().SPIData.clear();
          
          subscription = characteristic.value.listen((data){
            print(data);

            for (int i = 0; i <data.length-3; i+=4){
              if (data.length >= i + 4){
                int value = (data[i] | (data[i + 1] << 8) | (data[i + 2] << 16) | (data[i + 3] << 24));
                String binary = value.toRadixString(2).padLeft(32, '0');
                String valueString = "${binary.substring(0, 8)}|${binary.substring(8, 16)}|${binary.substring(16, 24)}|${binary.substring(24, 32)}";
                FFAppState().addToSPIData({
                  'time': '${DateTime.now().millisecondsSinceEpoch % 10000}ms',
                  'data': valueString, // Store as 32-bit binary string
                });
              }
            }
            FFAppState().update((){
              FFAppState().SPIData;
            });
            if (FFAppState().appState == 0){
              characteristic?.setNotifyValue(false);
            }
            },
            onError: (error) {
              print("Error receiving data: $error");
              characteristic?.setNotifyValue(false);
              subscription?.cancel();
            },
            onDone: () {
              print("Data stream completed.");
              characteristic?.setNotifyValue(false);
              subscription?.cancel();
            },
          );
          print("SPI Done");
        }
        else if (appState==6){  //Battery Indicator
          FFAppState().BatteryPerc = 0;
          subscription = characteristic.value.listen((data){
            print(data);
            FFAppState().BatteryPerc = data[0];
            FFAppState().update((){
              FFAppState().BatteryPerc;
            });
            if (FFAppState()==0){
              characteristic?.setNotifyValue(false);
              subscription?.cancel();
            }
          },
          onError: (error) {
            print("Error receiving data: $error");
            characteristic?.setNotifyValue(false);
            subscription?.cancel();
          },
          onDone: () {
            print("Data stream completed.");
            characteristic?.setNotifyValue(false);
            subscription?.cancel();
          });
        }
      }
      else {
        print("No notification characteristic available");
      }
    }
    return;
    
  }
  Stream<List<ScanResult>> get scanResults => flutterBlue.scanResults;
}


