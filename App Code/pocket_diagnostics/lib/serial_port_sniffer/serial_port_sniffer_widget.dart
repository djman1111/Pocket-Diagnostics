import 'package:provider/provider.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'serial_port_sniffer_model.dart';
export 'serial_port_sniffer_model.dart';

class SerialPortSnifferWidget extends StatefulWidget {
  const SerialPortSnifferWidget({super.key});

  @override
  State<SerialPortSnifferWidget> createState() => _SerialPortSnifferWidgetState();
}

class _SerialPortSnifferWidgetState extends State<SerialPortSnifferWidget> {
  late SerialPortSnifferModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SerialPortSnifferModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.black, // Terminal black background
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0, // Flat terminal look
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                'SERIAL_SNIFFER> ',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Roboto Condensed', // Monospaced font
                  color: const Color.fromARGB(255, 255, 255, 255), // Terminal green
                  fontSize: 20.0,
                  letterSpacing: 1.0,
                ),
              ),
              Switch.adaptive(
                value: FFAppState().OScopeState[3],
                onChanged: (newValue) async {
                  safeSetState(() => FFAppState().OScopeState[3] = newValue);
                  if (FFAppState().device != null && FFAppState().OScopeState[3]==true) {
                    FFAppState().appState = 4;
                    FFAppState().controller.sendFuncType(FFAppState().appState, FFAppState().device);
                    await FFAppState().controller.recieveData(FFAppState().appState, FFAppState().device);
                  }
                  if (FFAppState().OScopeState[3]==false){
                    FFAppState().appState = 0;
                    FFAppState().controller.sendFuncType(FFAppState().appState, FFAppState().device);
                    FFAppState().controller.reconnectDevice();
                  }
                },
                activeColor: const Color.fromARGB(255, 255, 255, 255),
                activeTrackColor: Colors.grey[800],
                inactiveTrackColor: Colors.grey[900],
                inactiveThumbColor: Colors.grey[700],
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 20.0, 0.0),
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () async {
                  context.pushNamed('HomePage');
                },
                child: Icon(
                  Icons.keyboard_return,
                  color: const Color.fromARGB(255, 65, 223, 59),
                  size: 24.0,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: true,
          child: Container(
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input controls (Clockrate and Protocol)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 150.0,
                        child: TextFormField(
                          key: ValueKey(valueOrDefault<String>(
                            FFAppState().ClockBaude.toString(),
                            '1',
                          )),
                          controller: _model.textController,
                          focusNode: _model.textFieldFocusNode,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'CLOCKRATE (MAX 50MS/s)',
                            hintStyle: TextStyle(
                              fontFamily: 'Roboto Condensed',
                              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.7),
                              fontSize: 14.0,
                              letterSpacing: 1.0,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: const Color.fromARGB(255, 255, 255, 255)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: const Color.fromARGB(255, 255, 255, 255)),
                            ),
                          ),
                          style: TextStyle(
                            fontFamily: 'Roboto Condensed',
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontSize: 14.0,
                            letterSpacing: 1.0,
                          ),
                          maxLength: 8,
                          cursorColor: const Color.fromARGB(255, 255, 255, 255),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            int clockBaude = int.tryParse(value) ?? 1;
                            if (clockBaude < 1) {
                              clockBaude = 1;
                            } else if (clockBaude > 50000000) {
                              clockBaude = 50000000;
                            }
                            FFAppState().ClockBaude = clockBaude;
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      DropdownButton<String>(
                        value: FFAppState().serialProtocol,
                        onChanged: (String? newValue) {
                          setState(() {
                            FFAppState().serialProtocol = newValue!;
                            print(FFAppState().serialProtocol);
                          });
                        },
                        items: <String>['RS-232', 'RS-485', 'TTL']
                            .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    fontFamily: 'Roboto Condensed',
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 14.0,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        style: TextStyle(
                          fontFamily: 'Roboto Condensed',
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 14.0,
                          letterSpacing: 1.0,
                        ),
                        dropdownColor: Colors.black,
                        iconEnabledColor: const Color.fromARGB(255, 255, 255, 255),
                        underline: Container(
                          height: 1,
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'TIME          DATA',
                    style: TextStyle(
                      fontFamily: 'Roboto Condensed',
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                // Data output
                Expanded(
                  child: ListView.builder(
                    itemCount: FFAppState().serialData.length,
                    itemBuilder: (context, index) {
                      final row = FFAppState().serialData[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                        child: Text(
                          '${row['time']!.padRight(14)}${row['data']!}',
                          style: TextStyle(
                            fontFamily: 'Roboto Condensed',
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontSize: 14.0,
                            letterSpacing: 1.0,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}