import 'package:flutter/material.dart';
import 'package:memri/app.dart';
import 'package:memri/constants/app_themes.dart';
import 'configs/configure_none_web.dart' if (dart.library.html) 'configs/configure_web.dart';

void main() {
  configureApp();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      onGenerateRoute: (route) {
        var key;
        if (route.name!.contains(RegExp(r"\/\?key=[\w]+$"))) {
          key = route.name!.split("/\?key=")[1];
        }
        return MaterialPageRoute(builder: (_) => Scaffold(body: App(key)));
      },
      title: "Memri",
      home: Scaffold(body: App()),
      theme: lightTheme));
}
