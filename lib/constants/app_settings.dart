import 'package:logger/logger.dart';

class AppSettings {
  AppSettings();

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

  /// Plugins
  final int minimalRequiredData = 1;

  /// CVU constants
  final String colabLink =
      "https://colab.research.google.com/drive/189JJ2gLHAtxlmzc5XI3HhB9_VE3fT6DT";
}
