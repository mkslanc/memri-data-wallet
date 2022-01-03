import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/Components/HtmlView/HtmlView.dart';

import 'shared.dart';
export 'shared.dart';

class AceEditor extends StatelessWidget {
  final AceEditorController controller;

  AceEditor(this.controller);

  @override
  Widget build(BuildContext context) {
    return HtmlView(src: "assets/cvuAceEditorDist/index.html");
  }
}
