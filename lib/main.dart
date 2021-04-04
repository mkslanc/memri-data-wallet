import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/MainView.dart';
import 'package:moor/ffi.dart';

import 'MemriApp/Controllers/SceneController.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final sceneController = SceneController();

  @override
  Widget build(BuildContext context) {
    assert(() {
      VmDatabase.closeExistingInstances();
      return true;
    }());
    sceneController.init();

    return MaterialApp(
      title: 'Memri',
      home: Scaffold(
        body: MainView(sceneController: sceneController),
      ),
    );
  }
}
