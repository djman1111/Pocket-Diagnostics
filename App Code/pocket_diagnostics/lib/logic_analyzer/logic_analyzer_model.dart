import '/flutter_flow/flutter_flow_util.dart';
import 'logic_analyzer_widget.dart' show LogicAnalyzerWidget;
import 'package:flutter/material.dart';

class LogicAnalyzerModel extends FlutterFlowModel<LogicAnalyzerWidget> {
  late TextEditingController textControllerLSamp;
  late FocusNode textFieldFocusNodeLSamp;

  late TextEditingController textControllerLChan;
  late FocusNode textFieldFocusNodeLChan;

  late TextEditingController textControllerLClock;
  late FocusNode textFieldFocusNodeLClock;

  @override
  void initState(BuildContext context) {
    textControllerLSamp = TextEditingController();
    textFieldFocusNodeLSamp = FocusNode();

    textControllerLChan = TextEditingController();
    textFieldFocusNodeLChan = FocusNode();

    textControllerLClock = TextEditingController();
    textFieldFocusNodeLClock = FocusNode();
  }

  @override
  void dispose() {
    textControllerLSamp.dispose();
    textFieldFocusNodeLSamp.dispose();

    textControllerLChan.dispose();
    textFieldFocusNodeLChan.dispose();

    textControllerLClock.dispose();
    textFieldFocusNodeLClock.dispose();
  }
  

}
