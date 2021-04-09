import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import '../ViewContextController.dart';

/// The chart renderer.
/// This renderer displays the data in a chart (eg. line, bar, pie)
class ChartRendererView extends StatelessWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  ChartRendererView({required this.sceneController, required this.viewContext});

  @override
  Widget build(BuildContext context) {
    return Text("ChartRendererView");
  }
}
