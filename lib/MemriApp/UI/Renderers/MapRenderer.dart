import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import '../ViewContextController.dart';

/// The map renderer
/// This presents the data items on a map
/// - for an item to be shown the CVU for ItemType > map {...} must define an expression resolving to either a `Location` or `Address` item
/// - you can provide a `label` property in the CVU for ItemType > map {...}
class MapRendererView extends StatelessWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  MapRendererView({required this.sceneController, required this.viewContext});

  @override
  Widget build(BuildContext context) {
    return Text("MapRendererView");
  }
}
