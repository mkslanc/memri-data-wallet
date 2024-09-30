import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_handler.dart';

class Routes {
  static String onboarding = '/onboarding';
  static String error = '/error';

  // static String create = '/account/create';
  static String login = '/login';
  static String loginDev = '/login_dev';

  // static String recoveryPhrase = '/account/recovery_phrase';
  static String saveKeys = '/account/save_keys';

  // static String verifyKeys = '/account/verify_keys';
  // static String forgotPassword = '/account/forgot_password';

  static String data = '/data';
  static String importer = '/data/importer';
  static String importerCreate = '/data/importer/create';
  static String importerConnect = '/data/importer/connect';
  static String importerDownloading = '/data/importer/downloading';
  static String importerError = '/data/importer/error';

  static String cvu = '/cvu';
  static String index = '/';


  static void configureRoutes(FluroRouter router) {
    router.notFoundHandler = notFoundHandler;
    router.define(onboarding, handler: onboardingScreenHandler);
    router.define(login, handler: loginScreenHandler);
    router.define(loginDev, handler: loginDeveloperScreenHandler);
    router.define(saveKeys, handler: saveKeysScreenHandler);
    router.define(index, handler: indexHandler);
  }
}

class RouteNavigator {
  static late FluroRouter router;

  static Future<dynamic> navigateTo({
    required String route,
    required BuildContext context,
    Duration transitionDuration = const Duration(milliseconds: 300),
    TransitionType transition = TransitionType.fadeIn,
    Map<String, dynamic>? param,
    bool replace = false,
    bool clearStack = false,
    RouteTransitionsBuilder? transitionBuilder,
  }) {
    String routePath = route;
    if (param != null) {
      bool isFirst = true;
      param.forEach((key, value) {
        routePath += (isFirst ? '?' : '&') + '$key=$value';
        isFirst = false;
      });
    }
    return router.navigateTo(
      context,
      routePath,
      replace: replace,
      transition: transition,
      clearStack: clearStack,
      transitionDuration: transitionDuration,
      transitionBuilder: transitionBuilder,
    );
  }

  static void navigateBack<T>(BuildContext context, [T? result]) {
    router.pop(context, result);
  }
}
