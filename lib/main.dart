import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/SceneView.dart';
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

    return FutureBuilder(
        future: sceneController.init(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return MaterialApp(
              title: 'Memri',
              home: Scaffold(
                body: SceneView(sceneController: sceneController),
              ),
            );
          } else {
            return SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            );
          }
        });
  }
}
