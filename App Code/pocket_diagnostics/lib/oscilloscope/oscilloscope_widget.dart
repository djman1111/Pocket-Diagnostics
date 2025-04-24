import 'dart:math';
import 'package:pocket_diagnostics/flutter_flow/flutter_flow_charts.dart';
import 'package:provider/provider.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'oscilloscope_model.dart';
export 'oscilloscope_model.dart';

class OscilloscopeWidget extends StatefulWidget {
  const OscilloscopeWidget({super.key});

  @override
  State<OscilloscopeWidget> createState() => _OscilloscopeWidgetState();
}

class _OscilloscopeWidgetState extends State<OscilloscopeWidget> {
  late OscilloscopeModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OscilloscopeModel());
    // Initialize controller with current SampleTime
    _model.textController?.text = FFAppState().SampleTime.toString();
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
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                'OSCILLOSCOPE> ',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Roboto Condensed',
                  color: Colors.white,
                  fontSize: 20.0,
                  letterSpacing: 1.0,
                ),
              ),
              Switch.adaptive(
                value: FFAppState().OScopeState[0],
                onChanged: (newValue) async {
                   safeSetState(() => FFAppState().OScopeState[0] = newValue);
                  if (FFAppState().device != null) {
                    safeSetState(() => FFAppState().OScopeState[0] = newValue);
                    if (FFAppState().OScopeState[0] == true) {
                      print("Oscilloscope is running");
                      FFAppState().appState = 1;
                      print("Sending Oscilloscope data");
                      FFAppState().controller.sendFuncType(FFAppState().appState, FFAppState().device);
                      await FFAppState().controller.recieveData(FFAppState().appState, FFAppState().device, FFAppState().SampleTime);
                    }
                    if (FFAppState().OScopeState[0] == false) {
                      FFAppState().appState = 0;
                      print(FFAppState().OscopeVoltage);
                      FFAppState().controller.sendFuncType(FFAppState().appState, FFAppState().device);
                      FFAppState().controller.reconnectDevice();
                      print("end of Oscilloscope");
                    }
                  }
                },
                activeColor: Colors.white,
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
                  color: Colors.white,
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
                // Sample Time Input
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 200.0,
                    child: TextFormField(
                      controller: _model.textController,
                      focusNode: _model.textFieldFocusNode,
                      autofocus: false,
                      obscureText: false,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'SAMPLE TIME (MAX 9999ms)',
                        hintStyle: TextStyle(
                          fontFamily: 'Roboto Condensed',
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14.0,
                          letterSpacing: 1.0,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: 'Roboto Condensed',
                        color: Colors.white,
                        fontSize: 14.0,
                        letterSpacing: 1.0,
                      ),
                      maxLength: 4,
                      cursorColor: Colors.white,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        int sampleTime = int.tryParse(value) ?? 1;
                        if (sampleTime < 1) {
                          sampleTime = 1;
                        }
                        FFAppState().SampleTime = sampleTime;
                        _model.textController.text = sampleTime.toString();
                      },
                    ),
                  ),
                ),
                // Centered Chart
                Expanded(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.6,
                            child: FlutterFlowLineChart(
                              data: [
                                FFLineChartData(
                                  xData: FFAppState().OscopeTime,
                                  yData: FFAppState().OscopeVoltage,
                                  settings: LineChartBarData(
                                    color: Colors.white,
                                    barWidth: 1.0, // Thin line
                                    isCurved: false, // Straight lines, no interpolation
                                    dotData: const FlDotData(show: false), // No dots
                                    belowBarData: BarAreaData(show: true), // No fill
                                  ),
                                )
                              ],
                              chartStylingInfo: ChartStylingInfo(
                                backgroundColor: const Color.fromARGB(255, 40, 5, 197),
                                borderColor: Colors.white,
                                borderWidth: 1.0,
                              ),
                              axisBounds: AxisBounds(
                                minX: 0,
                                minY: -3.3,
                                maxX: FFAppState().SampleTime > 0 ? FFAppState().SampleTime.toDouble() : 1000.0,
                                maxY: 3.3,
                              ),
                              xAxisLabelInfo: AxisLabelInfo(
                                title: 'TIME',
                                titleTextStyle: TextStyle(
                                  fontFamily: 'Roboto Condensed',
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  letterSpacing: 1.0,
                                ),
                                showLabels: true,
                                labelTextStyle: TextStyle(
                                  fontFamily: 'Roboto Condensed',
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                ),
                                labelInterval: 2000.0,
                                labelFormatter: LabelFormatter(
                                  numberFormat: (val) => val.toStringAsFixed(0),
                                ),
                                reservedSize: 40.0,
                              ),
                              yAxisLabelInfo: AxisLabelInfo(
                                title: 'Voltage',
                                titleTextStyle: TextStyle(
                                  fontFamily: 'Roboto Condensed',
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  letterSpacing: 1.0,
                                ),
                                showLabels: true,
                                labelInterval: 0.5,
                                labelFormatter: LabelFormatter(
                                  numberFormat: (val) => formatNumber(
                                    val,
                                    formatType: FormatType.decimal,
                                    decimalType: DecimalType.periodDecimal,
                                  ),
                                ),
                                reservedSize: 40.0,
                              ),
                            ),
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