import 'package:flutter/material.dart';
import 'package:memri/constants/app_logger.dart';

class AceEditorController {
  String? _content;

  String get content => _content!;

  final VoidCallback onResultReceived;
  final Future<List<Map<String, dynamic>>> Function(String)? validate;

  AceEditorController(this.onResultReceived, {this.validate});

  updateEditorContent(String? newContent) {
    AppLogger.err("Error: not implemented now");
  }

  requestEditorData() {
    AppLogger.err("Error: not implemented now");
  }
}
