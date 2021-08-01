import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/MainView.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: MainView());
  }
}
