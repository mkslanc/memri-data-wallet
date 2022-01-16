import 'package:flutter/material.dart';

class AceEditorController {
  String? _content;
  String get content => _content!;

  final VoidCallback onResultReceived;
  final Future<List<Map<String, dynamic>>> Function(String)? validate;

  AceEditorController(this.onResultReceived, {this.validate});

  updateEditorContent(String? newContent) {
    print("Error: not implemented now");
  }

  requestEditorData() {
    print("Error: not implemented now");
  }
}
