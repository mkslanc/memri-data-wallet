import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import '../ViewContextController.dart';

/// The Label Annotation renderer
/// This renderer can be used to annotate items with Labels
/// - Set the `labelType` to a unique ID representing the type of labels
/// - Set the `labelOptions` property to an array of Strings (representing the options)
/// - You may also provide a `labelOptionIcons` property with an array of icon names (in matching order with `labelOptions` array)
class LabelAnnotationRendererView extends StatelessWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  LabelAnnotationRendererView({required this.sceneController, required this.viewContext});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Text("LabelAnnotationRendererView"));
  }
}
