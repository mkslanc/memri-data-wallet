import 'package:flutter/material.dart';

class AceEditorController {
  String? _content;
  String get content => _content!;

  final VoidCallback onResultReceived;

  AceEditorController(this.onResultReceived);

  updateEditorContent(String? newcontent) {
    print("Error: not implemented now");
  }

  requestEditorData() {
    print("Error: not implemented now");
  }
}
