
import 'package:provider/provider.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'spi_inspector_model.dart';

export 'spi_inspector_model.dart';
import 'package:google_fonts/google_fonts.dart';
class SpiInspectorWidget extends StatefulWidget {
  const SpiInspectorWidget({super.key});

  @override
  State<SpiInspectorWidget> createState() => _SpiInspectorWidgetState();
}

class _SpiInspectorWidgetState extends State<SpiInspectorWidget> {
  late SpiInspectorModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SpiInspectorModel());
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
          elevation: 0, 
          title: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                'SPI_INSPECTOR> ',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontFamily: 'Roboto Condensed', // Monospaced font
                      color: const Color.fromARGB(255, 255, 255, 255), // Classic terminal green
                      fontSize: 20.0,
                      letterSpacing: 1.0,
                    ),
              ),
              Switch.adaptive(
                value: FFAppState().OScopeState[4],
                onChanged: (newValue) async {
                  FFAppState().OScopeState[4] = newValue;
                  setState(() {});
                  if (FFAppState().device != null && FFAppState().OScopeState[4]==true) {
                    safeSetState(() => FFAppState().OScopeState[4] = newValue);
                    FFAppState().appState = 5;
                    FFAppState().controller.sendFuncType(FFAppState().appState, FFAppState().device);
                    await FFAppState().controller.recieveData(FFAppState().appState, FFAppState().device);
                  }
                  else if (FFAppState().OScopeState[4]==false){
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
                  color: Colors.green,
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
                // Header row
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'TIME          CS|MISO|MOSI|SCLK',
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
                    itemCount: FFAppState().SPIData.length,
                    itemBuilder: (context, index) {
                      final row = FFAppState().SPIData[index];
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