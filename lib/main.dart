import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memri/locator.dart' as locator;
import 'package:memri/memri.dart';
import 'configs/configure_none_web.dart'
    if (dart.library.html) 'configs/configure_web.dart';

void main() {
  configureApp();
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await locator.setup();
    // await MixpanelAnalyticsService().init(); // TODO: Move to the app provider
    runApp(Memri());
  }, (error, stackTrace) async {
    /*MixpanelAnalyticsService()
        .logError(error.toString(), stackTrace.toString());*/
    throw error;
  });
}
