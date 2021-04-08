import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/MainView.dart';
import 'package:moor/ffi.dart';

import 'MemriApp/Controllers/SceneController.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: "Memri",
    home: Memri(),
  ));
}

class Memri extends StatelessWidget {
  final SceneController sceneController = SceneController();

  @override
  Widget build(BuildContext context) {
    assert(() {
      VmDatabase.closeExistingInstances();
      return true;
    }());

    return Scaffold(
        body: FutureBuilder(
            future: sceneController.init(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return MainView(sceneController: sceneController);
              } else {
                return Center(
                  child: SizedBox(
                    child: CircularProgressIndicator(),
                    width: 60,
                    height: 60,
                  ),
                );
              }
            }));
  }
}
