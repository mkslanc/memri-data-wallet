import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import '../ViewContextController.dart';

/// The GeneralEditorRenderer
/// This presents an editor for a single item
class GeneralEditorRendererView extends StatelessWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  GeneralEditorRendererView({required this.sceneController, required this.viewContext});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Text("GeneralEditorRendererView"));
  }
}
