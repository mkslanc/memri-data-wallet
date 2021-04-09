import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import '../ViewContextController.dart';

class SingleItemRendererView extends StatelessWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  SingleItemRendererView({required this.sceneController, required this.viewContext});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Text("SingleItemRendererView"));
  }
}
