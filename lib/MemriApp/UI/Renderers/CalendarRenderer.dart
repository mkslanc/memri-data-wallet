import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import '../ViewContextController.dart';

/// The calendar renderer
/// This presents the data in a month-style calendar view
/// Dots are used to represent days on which items fall
/// Pressing on a day will show a timeline view focused on that day
class CalendarRendererView extends StatelessWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  CalendarRendererView({required this.sceneController, required this.viewContext});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Text("CalendarRendererView"));
  }
}
