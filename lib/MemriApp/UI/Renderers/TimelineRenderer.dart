import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import '../ViewContextController.dart';

/// The timeline renderer
/// This presents the data in chronological order in a vertically scrolling `timeline`
class TimelineRendererView extends StatelessWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  TimelineRendererView({required this.sceneController, required this.viewContext});

  @override
  Widget build(BuildContext context) {
    return Text("TimelineRendererView");
  }
}
