import 'package:logger/logger.dart';

class AppSettings {
  static final AppSettings _settings = AppSettings._internal();

  factory AppSettings() => _settings;

  AppSettings._internal();

  final String defaultPodURL = "https://dev.pod.memri.io";
  final String defaultDevPodURL = "http://localhost:3030";

  final bool showDeveloperButton = true;
  final bool maintenanceInProgress = false;

  /// Database
  final String defaultDatabase = "dev_database";
  final int syncControllerIntervalSecs = 3;
  final int checkPodExistenceTimeoutSecs = 3;

  /// Logger
  final Level loggerLevel = Level.debug;
  final bool loggerColorEnabled = true;
  final bool loggerPrintTime = true;

  /// MixPanel
  final String mixPanelToken = "2480710466ca60df2a6dc2905a9fdccc";
}
