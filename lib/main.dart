import 'package:flutter/material.dart';
import 'package:memri/app.dart';
import 'package:memri/constants/app_themes.dart';
import 'configs/configure_none_web.dart' if (dart.library.html) 'configs/configure_web.dart';

void main() {
  configureApp();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      onGenerateRoute: (route) {
        return MaterialPageRoute(builder: (_) => Scaffold(body: App()));
      },
      onGenerateInitialRoutes: (initialRoute) {
        var key;
        if (initialRoute.contains(RegExp(r"\/\?key=[\w]+$"))) {
          key = initialRoute.split("/\?key=")[1];
        }
        return [MaterialPageRoute(builder: (_) => Scaffold(body: App(key)))];
      },
      title: "Memri",
      theme: lightTheme));
}
