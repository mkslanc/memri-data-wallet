import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memri/app.dart';
import 'package:memri/constants/app_themes.dart';
import 'configs/configure_none_web.dart' if (dart.library.html) 'configs/configure_web.dart';
import 'core/services/mixpanel_analytics_service.dart';

void main() {
  configureApp();
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await MixpanelAnalyticsService().init();
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
  }, (error, stackTrace) async {
    MixpanelAnalyticsService().logError(error.toString(), stackTrace.toString());
    throw error;
  });
}
