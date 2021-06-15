import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/MainView.dart';

import 'MemriApp/Controllers/AppController.dart';
import 'MemriApp/Controllers/SceneController.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: "Memri",
    home: Memri(),
  ));
}

class Memri extends StatefulWidget {
  @override
  _MemriState createState() => _MemriState();
}

class _MemriState extends State<Memri> {
  final SceneController sceneController = SceneController.sceneController;

  late Future _init;

  @override
  void initState() {
    super.initState();
    _init = init();
  }

  Future init() async {
    await sceneController.init();
    await AppController.shared.onLaunch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: _init,
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
