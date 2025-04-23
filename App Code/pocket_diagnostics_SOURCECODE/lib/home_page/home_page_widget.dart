import 'dart:async';

import 'package:provider/provider.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'home_page_model.dart';
import '/flutter_flow/BleControls.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
export 'home_page_model.dart';

class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
  void _showConnectionSnackBar(BluetoothDevice? device) {
    if (device != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Device Connected: ${device.name.isNotEmpty ? device.name : "UNKNOWN"}',
            style: TextStyle(
              fontFamily: 'Roboto Condensed',
              color: Colors.white,
              fontSize: 14.0,
              letterSpacing: 1.0,
            ),
          ),
          backgroundColor: Colors.grey[800],
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.black, // Terminal black background
        drawer: Drawer(
          elevation: 0.0,
          backgroundColor: Colors.black,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 0.0, 0.0),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      if (scaffoldKey.currentState!.isDrawerOpen ||
                          scaffoldKey.currentState!.isEndDrawerOpen) {
                        Navigator.pop(context);
                      }
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 24.0,
                        ),
                        Text(
                          'EXIT',
                          style: TextStyle(
                            fontFamily: 'Roboto Condensed',
                            color: Colors.white,
                            fontSize: 16.0,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 0.0, 0.0),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.pushNamed('Oscilloscope');
                    },
                    child: Row(
                      children: [
                        Text(
                          'OSCILLOSCOPE',
                          style: TextStyle(
                            fontFamily: 'Roboto Condensed',
                            color: Colors.white,
                            fontSize: 16.0,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Icon(
                          Icons.waves_outlined,
                          color: Colors.white,
                          size: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 0.0, 0.0),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.pushNamed('SerialPortSniffer');
                    },
                    child: Row(
                      children: [
                        Text(
                          'SERIAL_PORT_SNIFFER',
                          style: TextStyle(
                            fontFamily: 'Roboto Condensed',
                            color: Colors.white,
                            fontSize: 16.0,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Icon(
                          Icons.waves_outlined,
                          color: Colors.white,
                          size: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 0.0, 0.0),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.pushNamed('IcInspector');
                    },
                    child: Row(
                      children: [
                        Text(
                          'I2C_INSPECTOR',
                          style: TextStyle(
                            fontFamily: 'Roboto Condensed',
                            color: Colors.white,
                            fontSize: 16.0,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Icon(
                          Icons.battery_saver_rounded,
                          color: Colors.white,
                          size: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 0.0, 0.0),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.pushNamed('SpiInspector');
                    },
                    child: Row(
                      children: [
                        Text(
                          'SPI_INSPECTOR',
                          style: TextStyle(
                            fontFamily: 'Roboto Condensed',
                            color: Colors.white,
                            fontSize: 16.0,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Icon(
                          Icons.battery_saver_rounded,
                          color: Colors.white,
                          size: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 0.0, 0.0),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      context.pushNamed('LogicAnalyzer');
                    },
                    child: Row(
                      children: [
                        Text(
                          'LOGIC_ANALYZER',
                          style: TextStyle(
                            fontFamily: 'Roboto Condensed',
                            color: Colors.white,
                            fontSize: 16.0,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Icon(
                          Icons.battery_saver_rounded,
                          color: Colors.white,
                          size: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(

          backgroundColor: Colors.black,
          elevation: 0,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                'HOME', // Added return arrow for terminal feel
                style: TextStyle(
                  fontFamily: 'Roboto Condensed',
                  color: Colors.white,
                  fontSize: 20.0,
                  letterSpacing: 1.0,
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(MediaQuery.of(context).size.width * 0.2, 20.0, 0.0, 0.0),
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    if (FFAppState().device!=null){
                      FFAppState().appState = 6;
                      FFAppState().controller.sendFuncType(FFAppState().appState, FFAppState().device);
                      await FFAppState().controller.recieveData(FFAppState().appState, FFAppState().device);
                      Timer(const Duration(seconds: 1), () {FFAppState().appState = 0;});
                      setState(() {});
                    }
                  }, // Add onTap function
                  child: Text(
                    'Battery Percentage: ${FFAppState().BatteryPerc}%',
                    style: TextStyle(
                      fontFamily: 'Roboto Condensed',
                      color: Colors.white,
                      fontSize: 12.0,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: GetBuilder<BleController>(
          init: BleController(),
          builder: (BleController controller) {
            return Container(
              color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 0.0, 0.0),
                    child: Text(
                      'BLE_DEVICES',
                      style: TextStyle(
                        fontFamily: 'Roboto Condensed',
                        color: Colors.white,
                        fontSize: 16.0,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<ScanResult>>(
                      stream: FFAppState().controller.scanResults,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          return ListView.builder(
                            padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final data = snapshot.data![index];
                              return InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  await FFAppState().controller.connectToDevice(data.device);
                                  BluetoothDevice? currentDevice = FFAppState().device;
                                  if (currentDevice != null) {
                                    print('snackbar');
                                    _showConnectionSnackBar(currentDevice);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${data.device.name.isNotEmpty ? data.device.name : "UNKNOWN"} [${data.device.id.id}]',
                                        style: TextStyle(
                                          fontFamily: 'Roboto Condensed',
                                          color: Colors.white,
                                          fontSize: 14.0,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      Text(
                                        'RSSI: ${data.rssi}',
                                        style: TextStyle(
                                          fontFamily: 'Roboto Condensed',
                                          color: Colors.white,
                                          fontSize: 14.0,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return Center(
                            child: Text(
                              'NO_DEVICES_FOUND',
                              style: TextStyle(
                                fontFamily: 'Roboto Condensed',
                                color: Colors.white,
                                fontSize: 16.0,
                                letterSpacing: 1.0,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.08,
                          height: MediaQuery.of(context).size.width * 0.1,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (FFAppState().device!=null) {
                                FFAppState().controller.reconnectDevice();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Reconnecting Device'),
                                    backgroundColor: Colors.grey[800],
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.fromWidth(double.infinity),
                            ),
                            child: Text(
                              'O',
                              style: TextStyle(
                                fontFamily: 'Roboto Condensed',
                                color: Colors.white,
                                fontSize: 20.0,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.12,
                          height: MediaQuery.of(context).size.width * 0.1,
                          child: ElevatedButton(
                            onPressed: () async {
                              await FFAppState().controller.scanDevices();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Scan started'),
                                  backgroundColor: Colors.grey[800],
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.fromWidth(double.infinity),
                            ),
                            child: Text(
                              'SCAN>',
                              style: TextStyle(
                                fontFamily: 'Roboto Condensed',
                                color: Colors.white,
                                fontSize: 14.0,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.08,
                          height: MediaQuery.of(context).size.width * 0.1,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (FFAppState().device != null) {
                                await FFAppState().device!.disconnect();
                                FFAppState().device = null;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Device Disconnected'),
                                  backgroundColor: Colors.grey[800],
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              setState(() {}); // Refresh UI
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.fromWidth(double.infinity),
                            ),
                            child: Text(
                              'X',
                              style: TextStyle(
                                fontFamily: 'Roboto Condensed',
                                color: Colors.white,
                                fontSize: 20.0,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}