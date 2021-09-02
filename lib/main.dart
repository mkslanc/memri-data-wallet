import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUFont.dart';
import 'package:memri/MemriApp/UI/MainView.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: "Memri",
      home: Memri(),
      theme: ThemeData(
          fontFamily: 'WorkSans',
          backgroundColor: Color(0xffE5E5E5),
          textTheme: const TextTheme(
            headline1: CVUFont.headline1,
            headline2: CVUFont.headline2,
            headline3: CVUFont.headline3,
            headline4: CVUFont.headline4,
            bodyText1: CVUFont.bodyText1,
            bodyText2: CVUFont.bodyText2,
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: MainView());
  }
}
