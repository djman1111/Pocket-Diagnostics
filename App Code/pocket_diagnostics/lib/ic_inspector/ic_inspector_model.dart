import '/flutter_flow/flutter_flow_util.dart';
import 'ic_inspector_widget.dart' show IcInspectorWidget;
import 'package:flutter/material.dart';

class IcInspectorModel extends FlutterFlowModel<IcInspectorWidget> {

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
