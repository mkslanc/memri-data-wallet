import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import '../ViewContextController.dart';

/// The photo viewer renderer
/// This presents the data items in a photo viewer, that can page horizontally between images
/// The CVU for ItemType > map {...} must define a `file` expression pointing to a `File` item
class PhotoViewerRendererView extends StatelessWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  PhotoViewerRendererView({required this.sceneController, required this.viewContext});

  @override
  Widget build(BuildContext context) {
    return Text("PhotoViewerRendererView");
  }
}
