import 'package:logger/logger.dart';

class AppSettings {
  static final AppSettings _settings = AppSettings._internal();

  factory AppSettings() => _settings;

  AppSettings._internal();

  final String defaultPodUrl = 'https://dev.pod.memri.io';
  final String defaultDevPodUrl = 'http://10.0.2.2:3030';
  final String podVersion = 'v4';

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

  /// DIO
  final int dioConnectTimeout = 10000;
  final int dioReceiveTimeout = 5000;
  final int dioFailureRetries = 3; // Number of retries before a failure
  final bool dioLoggerEnabled = true;
  final bool dioLogInterceptorRequest = true;
  final bool dioLogInterceptorRequestHeader = true;
  final bool dioLogInterceptorRequestBody = true;
  final bool dioLogInterceptorResponseHeader = true;
  final bool dioLogInterceptorResponseBody = true;

  /// Links
  final String guideUrl = 'https://docs.memri.io/overview/quickStart/';
  final String discordUrl = 'https://discord.com/invite/BcRfajJk4k';
}
