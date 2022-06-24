import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memri/locator.dart';
import 'package:memri/memri.dart';
import 'configs/configure_none_web.dart' if (dart.library.html) 'configs/configure_web.dart';
import 'core/services/mixpanel_analytics_service.dart';
import 'configs/configure_none_web.dart'
    if (dart.library.html) 'configs/configure_web.dart';

void main() {
  configureApp();
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    setupLocator();
    await MixpanelAnalyticsService().init();
    runApp(Memri());
  }, (error, stackTrace) async {
    MixpanelAnalyticsService().logError(error.toString(), stackTrace.toString());
    throw error;
  });
}
