import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/MainView.dart';
import 'MemriApp/Controllers/SceneController.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: "Memri",
      home: Memri(),
      theme: ThemeData(
          fontFamily: 'WorkSans',
          textTheme: const TextTheme(
            headline1: TextStyle(fontSize: 44.0, fontWeight: FontWeight.w300),
            headline2: TextStyle(fontSize: 30.0, fontWeight: FontWeight.w400),
            headline3: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500),
            headline4: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
            bodyText1: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400),
            bodyText2: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w400),
          ),
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                  primary: Color(0xff515151),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.all(10.0))))));
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
