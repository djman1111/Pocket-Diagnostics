import '/flutter_flow/flutter_flow_util.dart';
import 'oscilloscope_widget.dart' show OscilloscopeWidget;
import 'package:flutter/material.dart';

class OscilloscopeModel extends FlutterFlowModel<OscilloscopeWidget> {

  late TextEditingController textController;
  late FocusNode textFieldFocusNode;

  @override
  void initState(BuildContext context) {
    textController = TextEditingController();
    textFieldFocusNode = FocusNode();
  }

  @override
  void dispose() {
    textController.dispose();
    textFieldFocusNode.dispose();
  }
  

}
