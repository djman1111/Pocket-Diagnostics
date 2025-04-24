import '/flutter_flow/flutter_flow_util.dart';
import 'serial_port_sniffer_widget.dart' show SerialPortSnifferWidget;
import 'package:flutter/material.dart';

class SerialPortSnifferModel extends FlutterFlowModel<SerialPortSnifferWidget> {
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
