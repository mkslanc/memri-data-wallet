import 'package:flutter/material.dart';
import 'package:memri/widgets/components/html_view/html_view.dart';

import 'shared.dart';

export 'shared.dart';

class AceEditor extends StatelessWidget {
  final AceEditorController controller;

  AceEditor(this.controller);

  @override
  Widget build(BuildContext context) {
    return HtmlView(
      src: "assets/assets/cvuAceEditorDist/index.html",
      reload: false,
    );
  }
}
