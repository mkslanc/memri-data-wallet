import 'package:logger/logger.dart';

class AppSettings {
  AppSettings._();

  static const String defaultPodURL = "https://dev.pod.memri.io";
  static const String defaultDevPodURL = "http://localhost:3030";

  static const bool showDeveloperButton = true;

  /// Database
  static const String defaultDatabase = "dev_database";
  static const int syncControllerIntervalSecs = 3;
  static const int checkPodExistenceTimeoutSecs = 3;

  /// Logger
  static const Level loggerLevel = Level.debug;
  static const bool loggerColorEnabled = true;
  static const bool loggerPrintTime = true;

  /// MixPanel
  static const String mixPanelToken = "2480710466ca60df2a6dc2905a9fdccc";
}
