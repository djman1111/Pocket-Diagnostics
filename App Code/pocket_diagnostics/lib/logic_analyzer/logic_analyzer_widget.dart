import 'package:provider/provider.dart';
import '/flutter_flow/flutter_flow_charts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'logic_analyzer_model.dart';
export 'logic_analyzer_model.dart';
import 'dart:math';
class LogicAnalyzerWidget extends StatefulWidget {
  const LogicAnalyzerWidget({super.key});

  @override
  State<LogicAnalyzerWidget> createState() => _LogicAnalyzerWidgetState();
}

class _LogicAnalyzerWidgetState extends State<LogicAnalyzerWidget> {
  late LogicAnalyzerModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late int randomNumber; // RNG state
  final Random _random = Random(); // RNG instance
  void initState() {
    super.initState();
    _model = createModel(context, () => LogicAnalyzerModel());
    randomNumber = _generateRandomNumber(); // Initialize RNG
  }

  // Generates a random number between 0 and 65535
  int _generateRandomNumber() {
    return _random.nextInt(65536); // 0 to 65535 inclusive
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
                'LOGIC_ANALYZER> ',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Roboto Condensed',
                  color: Colors.white,
                  fontSize: 20.0,
                  letterSpacing: 1.0,
                ),
              ),
              Switch.adaptive(
                value: FFAppState().OScopeState[2],
                onChanged: (newValue) async {

                  if (FFAppState().device != null) {
                    safeSetState(() => FFAppState().OScopeState[2] = newValue);
                    if (FFAppState().OScopeState[2] == true) {
                      FFAppState().appState = 3;
                      FFAppState().controller.sendFuncType(FFAppState().appState, FFAppState().device);
                      await FFAppState().controller.recieveData(FFAppState().appState, FFAppState().device, FFAppState().SampleTime);
                    }
                    if (FFAppState().OScopeState[2] == false) {
                      FFAppState().appState = 0;
                      FFAppState().controller.sendFuncType(FFAppState().appState, FFAppState().device);
                      print("end of Logic Analyzer");
                      FFAppState().controller.reconnectDevice();
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
          child: Container(
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input controls (Sample Time and Clock Rate)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 175.0,
                        child: TextFormField(
                          key: ValueKey(valueOrDefault<String>(
                            FFAppState().SampleTime.toString(),
                            '0',
                          )),
                          controller: _model.textControllerLSamp,
                          focusNode: _model.textFieldFocusNodeLSamp,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'SAMPLE TIME (ms)',
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
                            int sampleTime = int.tryParse(value) ?? 0;
                            FFAppState().SampleTime = sampleTime;
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        width: 175.0,
                        child: TextFormField(
                          key: ValueKey(valueOrDefault<String>(
                            FFAppState().ClockBaude.toString(),
                            '0',
                          )),
                          controller: _model.textControllerLClock,
                          focusNode: _model.textFieldFocusNodeLClock,
                          autofocus: false,
                          obscureText: false,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'CLOCK RATE (MAX 50MS/s)',
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
                          maxLength: 8,
                          cursorColor: Colors.white,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            int clockBaude = int.tryParse(value) ?? 1;
                            if (clockBaude > 50000000) {
                              clockBaude = 50000000;
                            }
                            FFAppState().ClockBaude = clockBaude;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Chart Display
                Expanded(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: ListView.builder(
                      itemCount: 16,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: FlutterFlowLineChart(
                              data: [
                                FFLineChartData(
                                  xData: FFAppState().LogicTime,
                                  yData: FFAppState().LogicData[index],
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
                                minX: 0.0,
                                minY: 0,
                                maxX: FFAppState().SampleTime > 0 ? FFAppState().SampleTime.toDouble() : 1000.0,
                                maxY: 1,
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
                                title: 'CH${index + 1}',
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
                        );
                      },
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