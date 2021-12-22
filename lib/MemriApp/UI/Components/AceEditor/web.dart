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

  updateEditorContent(String? newcontent) {
    _content = newcontent;
    if (!_isEditorLoaded || _content == null) return;
    _postMessage(data: {"content": content}, action: "setData");
  }

  requestEditorData() {
    _postMessage(action: "getData");
  }

  _editorIsLoaded() {
    _isEditorLoaded = true;
    updateEditorContent(_content);
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
