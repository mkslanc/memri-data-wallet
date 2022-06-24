import 'package:flutter/material.dart';
import 'package:memri/locator.dart';
import 'package:memri/memri.dart';
import 'configs/configure_none_web.dart'
    if (dart.library.html) 'configs/configure_web.dart';

void main() {
  configureApp();
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(Memri());
}
