import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';

class AceEditorController {
  String? _content;
  String get content => _content!;

  final VoidCallback onResultReceived;
  bool _isEditorLoaded = false;

  AceEditorController(this.onResultReceived) {
    _initWindowListeners();
  }

  updateEditorContent(String? newContent) {
    if (newContent == _content) return;
    _content = newContent;
    if (_isEditorLoaded && _content != null) _setEditorContent();
  }

  requestEditorData() {
    _postMessage(action: "getData");
  }

  _setEditorContent() {
    _postMessage(data: {"content": content}, action: "setData");
  }

  _editorIsLoaded() {
    _isEditorLoaded = true;
    if (_content != null) _setEditorContent();
  }

  _postMessage({Map<String, dynamic>? data, String? action}) {
    data ??= {};
    data["action"] ??= action;
    final jsonEncoder = JsonEncoder();
    final json = jsonEncoder.convert(data);
    html.window.postMessage(json, "*");
  }

  _initWindowListeners() {
    html.window.onMessage.listen((event) {
      var data = jsonDecode(event.data);
      switch (data["action"]) {
        case "ready":
          _editorIsLoaded();
          break;
        case "result":
          _content = data["content"];
          onResultReceived.call();
          break;
      }
    });
  }
}
