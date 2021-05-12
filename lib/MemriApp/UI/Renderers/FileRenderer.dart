import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import '../ViewContextController.dart';

/// The file viewer renderer
/// This presents the data items in a file viewer, that can page horizontally between files
/// The CVU for ItemType > FileViewer {...} must define a `file` expression pointing to a `File` item
/// Optionally the CVU for ItemType > FileViewer {...} can define an `itemTitle` expression
class FileRendererView extends StatelessWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  FileRendererView({required this.sceneController, required this.viewContext});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Text("FileRendererView"));
  }
}
