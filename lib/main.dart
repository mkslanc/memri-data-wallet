import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/MainView.dart';

import 'MemriApp/Controllers/SceneController.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var sceneController = SceneController();
    sceneController.init();

    return MaterialApp(
      title: 'Memri',
      home: Scaffold(
        body: MainView(sceneController: sceneController),
      ),
    );
  }
}
