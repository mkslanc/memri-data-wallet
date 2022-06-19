import 'package:logger/logger.dart';

class AppSettings {
  AppSettings();

  final String defaultPodURL = "https://dev.pod.memri.io";
  final String defaultDevPodURL = "http://localhost:3030";

  final bool showDeveloperButton = true;

  /// Database
  final String defaultDatabase = "dev_database";
  final int syncControllerIntervalSecs = 3;
  final int checkPodExistenceTimeoutSecs = 3;

  /// Logger
  final Level loggerLevel = Level.debug;
  final bool loggerColorEnabled = true;
  final bool loggerPrintTime = true;
}
