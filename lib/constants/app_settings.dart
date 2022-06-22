import 'package:logger/logger.dart';

class AppSettings {
  AppSettings._();

  static const String defaultPodURL = "https://dev.pod.memri.io";
  static const String defaultDevPodURL = "http://localhost:3030";

  static const bool showDeveloperButton = true;
  static const bool maintenanceInProgress = false;

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

  /// Plugins
  static const int minimalRequiredData = 1;

  /// CVU constants
  static const colabLink =
      "https://colab.research.google.com/drive/189JJ2gLHAtxlmzc5XI3HhB9_VE3fT6DT";
}
