import 'package:flutter/material.dart';
import 'package:pocket_diagnostics/flutter_flow/BleControls.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }


  List<double> _OscopeTime = [];
  List<double> get OscopeTime => _OscopeTime;
  set OscopeTime(List<double> value) {
    _OscopeTime = value;
  }

  void addToOscopeTime(double value) {
    OscopeTime.add(value);
  }

  void removeFromOscopeTime(double value) {
    OscopeTime.remove(value);
  }

  void removeAtIndexFromOscopeTime(int index) {
    OscopeTime.removeAt(index);
  }

  void updateOscopeTimeAtIndex(
    int index,
    double Function(double) updateFn,
  ) {
    OscopeTime[index] = updateFn(_OscopeTime[index]);
  }

  void insertAtIndexInOscopeTime(int index, double value) {
    OscopeTime.insert(index, value);
  }

  List<double> _OscopeVoltage = [];
  List<double> get OscopeVoltage => _OscopeVoltage;
  set OscopeVoltage(List<double> value) {
    _OscopeVoltage = value;
  }

  void addToOscopeVoltage(double value) {
    OscopeVoltage.add(value);
  }

  void removeFromOscopeVoltage(double value) {
    OscopeVoltage.remove(value);
  }

  void removeAtIndexFromOscopeVoltage(int index) {
    OscopeVoltage.removeAt(index);
  }

  void updateOscopeVoltageAtIndex(
    int index,
    double Function(double) updateFn,
  ) {
    OscopeVoltage[index] = updateFn(_OscopeVoltage[index]);
  }

  void insertAtIndexInOscopeVoltage(int index, double value) {
    OscopeVoltage.insert(index, value);
  }

  

  List<Map<String, String>> _I2CData = [];
List<Map<String, String>> get I2CData => _I2CData;
set I2CData(List<Map<String, String>> value) {
  _I2CData = value;
}

void addToI2CData(Map<String, String> value) {
  I2CData.add(value);
}

void removeFromI2CData(Map<String, String> value) {
  I2CData.remove(value);
}

void removeAtIndexFromI2CData(int index) {
  I2CData.removeAt(index);
}

void updateI2CDataAtIndex(
  int index,
  Map<String, String> Function(Map<String, String>) updateFn,
) {
  I2CData[index] = updateFn(_I2CData[index]);
}

void insertAtIndexInI2CData(int index, Map<String, String> value) {
  I2CData.insert(index, value);
}

  List<Map<String, String>> _serialData = [];
List<Map<String, String>> get serialData => _serialData;
set serialData(List<Map<String, String>> value) {
  _serialData = value;
}

void addToserialData(Map<String, String> value) {
  serialData.add(value);
}

void removeFromserialData(Map<String, String> value) {
  serialData.remove(value);
}

void removeAtIndexFromserialData(int index) {
  serialData.removeAt(index);
}

void updateserialDataAtIndex(
  int index,
  Map<String, String> Function(Map<String, String>) updateFn,
) {
  serialData[index] = updateFn(_serialData[index]);
}

void insertAtIndexInserialData(int index, Map<String, String> value) {
  serialData.insert(index, value);
}

  List<Map<String, String>> _SPIData = [];
List<Map<String, String>> get SPIData => _SPIData;
set SPIData(List<Map<String, String>> value) {
  _SPIData = value;
}

void addToSPIData(Map<String, String> value) {
  SPIData.add(value);
}

void removeFromSPIData(Map<String, String> value) {
  SPIData.remove(value);
}

void removeAtIndexFromSPIData(int index) {
  SPIData.removeAt(index);
}

void updateSPIDataAtIndex(
  int index,
  Map<String, String> Function(Map<String, String>) updateFn,
) {
  SPIData[index] = updateFn(_SPIData[index]);
}

void insertAtIndexInSPIData(int index, Map<String, String> value) {
  SPIData.insert(index, value);
}

List<List<int>> _LogicData = List.generate(16, (_) => []); // 16 nested lists
List<List<int>> get LogicData => _LogicData;
set LogicData(List<List<int>> value) {
  _LogicData = value;
}

// Add a value to a specific inner list
void addToLogicData(int listIndex, int value) {
  if (listIndex >= 0 && listIndex < 16) {
    _LogicData[listIndex].add(value);
  }
}

// Remove a value from a specific inner list
void removeFromLogicData(int listIndex, int value) {
  if (listIndex >= 0 && listIndex < 16) {
    _LogicData[listIndex].remove(value);
  }
}

// Remove a value at a specific index from a specific inner list
void removeAtIndexFromLogicData(int listIndex, int index) {
  if (listIndex >= 0 && listIndex < 16 && index < _LogicData[listIndex].length) {
    _LogicData[listIndex].removeAt(index);
  }
}

// Update a value at a specific index inside a specific inner list
void updateLogicDataAtIndex(int listIndex, int index, int Function(int) updateFn) {
  if (listIndex >= 0 && listIndex < 16 && index < _LogicData[listIndex].length) {
    _LogicData[listIndex][index] = updateFn(_LogicData[listIndex][index]);
  }
}

// Insert a value at a specific index in a specific inner list
void insertAtIndexInLogicData(int listIndex, int index, int value) {
  if (listIndex >= 0 && listIndex < 16 && index <= _LogicData[listIndex].length) {
    _LogicData[listIndex].insert(index, value);
  }
}

 List<double> _LogicTime = [];
  List<double> get LogicTime => _LogicTime;
  set LogicTime(List<double> value) {
    _LogicTime = value;
  }

  void addToLogicTime(double value) {
    LogicTime.add(value);
  }

  void removeFromLogicTime(double value) {
    LogicTime.remove(value);
  }

  void removeAtIndexFromLogicTime(int index) {
    LogicTime.removeAt(index);
  }

  void updateLogicTimeAtIndex(
    int index,
    double Function(double) updateFn,
  ) {
    LogicTime[index] = updateFn(_LogicTime[index]);
  }

  void insertAtIndexInLogicTime(int index, double value) {
    LogicTime.insert(index, value);
  }

  int _logicIndex = 0;
  int get logicIndex => _logicIndex;
  set logicIndex(int value) {
    _logicIndex = value;
  }


  

  int _SampleTime = 0;
  int get SampleTime => _SampleTime;
  set SampleTime(int value) {
    _SampleTime = value;
  }


  List<bool> _OScopeState = [false, false, false, false, false];
  List<bool> get OScopeState => _OScopeState;
  set OScopeState (List<bool> value){
    _OScopeState = value;
  }
  int _ClockBaude = 0;
  int get ClockBaude => _ClockBaude;
  set ClockBaude(int value) {
    _ClockBaude = value;
  }
  int _OscopeIndex = 0;
  int get OscopeIndex => _OscopeIndex;
  set OscopeIndex(int value) {
    _OscopeIndex = value;
  }

  int _BatteryPerc = 0;
  int get BatteryPerc => _BatteryPerc;
  set BatteryPerc(int value) {
    _BatteryPerc = value;
  }




  int _appState = 0;
  int get appState => _appState;
  set appState(int value) {
    _appState = value;
  }

  late BluetoothCharacteristic _serviceUUID;
  BluetoothCharacteristic get serviceUUID => _serviceUUID;
  set serviceUUID(BluetoothCharacteristic value) {
    _serviceUUID = value;
  }





  late BleController controller = Get.find<BleController>();
  BluetoothDevice? device;

  late String serialProtocol = 'RS-232';
}

  