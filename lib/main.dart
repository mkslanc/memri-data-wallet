import 'package:flutter/material.dart';
import 'package:memri/app.dart';
import 'package:memri/constants/app_themes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(title: "Memri", home: Memri(), theme: lightTheme));
}

class Memri extends StatefulWidget {
  @override
  _MemriState createState() => _MemriState();
}

class _MemriState extends State<Memri> {
  @override
  Widget build(BuildContext context) => Scaffold(body: App());
}
