import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_handler.dart';

class Routes {
  static String splash = '/';
  static String onboarding = '/hello';
  static String accountError = '/account/error';
  // static String create = '/account/create';
  static String login = '/account/login';
  static String loginDev = '/account/login_dev';
  // static String recoveryPhrase = '/account/recovery_phrase';
  static String saveKeys = '/account/save_keys';
  // static String verifyKeys = '/account/verify_keys';
  // static String forgotPassword = '/account/forgot_password';

  static String workspace = '/workspace';
  static String data = '/workspace/data';
  static String whatsapp = '/workspace/data/whatsapp';
  static String whatsappConnect = '/workspace/data/whatsapp/connect';

  static String projects = '/workspace/projects';
  static String apps = '/workspace/apps';
  static String inbox = '/workspace/apps/inbox';

  static void configureRoutes(FluroRouter router) {
    router.notFoundHandler = notFoundHandler;
    router.define(splash, handler: splashScreenHandler);
    router.define(onboarding, handler: onboardingScreenHandler);
    router.define(error, handler: accountErrorScreenHandler);
    router.define(login, handler: loginScreenHandler);
    router.define(loginDev, handler: loginDeveloperScreenHandler);
    router.define(saveKeys, handler: saveKeysScreenHandler);

    router.define(workspace, handler: workspaceScreenHandler);
    router.define(data, handler: dataScreenHandler);
    router.define(whatsapp, handler: whatsappScreenHandler);
    router.define(whatsappConnect, handler: whatsappConnectScreenHandler);
    router.define(apps, handler: appsScreenHandler);
    router.define(inbox, handler: inboxScreenHandler);
  }
}

class RouteNavigator {
  static late FluroRouter router;

  static Future<dynamic> navigateToRoute({
    required BuildContext context,
    required String route,
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
