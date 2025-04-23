import '/flutter_flow/flutter_flow_util.dart';
import 'spi_inspector_widget.dart' show SpiInspectorWidget;
import 'package:flutter/material.dart';

class SpiInspectorModel extends FlutterFlowModel<SpiInspectorWidget> {
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
