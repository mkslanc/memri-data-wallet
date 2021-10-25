import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/MainView.dart';
import 'MemriApp/UI/style/light.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(title: "Memri", home: Memri(), theme: lightTheme),
  );
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
