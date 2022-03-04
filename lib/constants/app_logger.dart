import 'package:logger/logger.dart';
import 'package:memri/constants/app_settings.dart';

class AppLogger {
  static final Logger logger = Logger(
    level: AppSettings.loggerLevel,
    printer: SimplePrinter(
      colors: AppSettings.loggerColorEnabled,
      printTime: AppSettings.loggerPrintTime,
    ),
  );

  static void warn(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.w(message, error, stackTrace);
    recordCrashlyticsError(message, error, stackTrace);
  }

  static void err(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.e(message, error, stackTrace);
    recordCrashlyticsError(message, error, stackTrace);
  }

  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      logger.i(message, error, stackTrace);

  static void recordCrashlyticsError(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    // if (!kIsWeb) {
    //   /// TODO: We should add Firebase plugins
    //   FirebaseCrashlytics.instance.recordError(error ?? message, stackTrace, printDetails: false);
    // } else {
    //   /// TODO: We need a service from server-side to store these logs
    // }
  }
}
