import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_handler.dart';

class Routes {
  static String workspace = '/';
  static String onboarding = '/hello';
  static String error = '/error';
  // static String create = '/account/create';
  static String login = '/login';
  static String loginDev = '/login_dev';

  // static String recoveryPhrase = '/account/recovery_phrase';
  static String saveKeys = '/account/save_keys';

  // static String verifyKeys = '/account/verify_keys';
  // static String forgotPassword = '/account/forgot_password';

  static String data = '/data';
  static String importer = '/data/importers';
  static String importerCreate = '/data/importers/create';
  static String importerConnect = '/data/importers/connect';
  static String importerDownloading = '/data/importers/downloading';

  static String projects = '/projects';
  static String projectsCreate = '/projects/create';
  static String projectsSummary = '/projects/summary';
  static String projectsLabelData = '/projects/label_data';
  static String projectsAppCreate = '/projects/new_app/create';
  static String projectsAppDeploy = '/projects/new_app/deploy';
  static String projectsAppSummary = '/projects/new_app/summary';
  static String projectsSetupData = '/projects/new_app/setup_data';
  static String projectsSetupLabelEditor = '/projects/new_app/setup_label_editor';

  static String apps = '/workspace/apps';
  static String inbox = '/workspace/apps/inbox';

  static void configureRoutes(FluroRouter router) {
    router.notFoundHandler = notFoundHandler;
    router.define(workspace, handler: workspaceScreenHandler);
    router.define(onboarding, handler: onboardingScreenHandler);
    router.define(login, handler: loginScreenHandler);
    router.define(loginDev, handler: loginDeveloperScreenHandler);
    router.define(saveKeys, handler: saveKeysScreenHandler);
    router.define(error, handler: errorScreenHandler);

    router.define(data, handler: dataScreenHandler);
    router.define(importer, handler: importerScreenHandler);
    router.define(importerCreate, handler: importerCreateScreenHandler);
    router.define(importerConnect, handler: importerConnectScreenHandler);
    router.define(importerDownloading,
        handler: importerDownloadingScreenHandler);

    router.define(apps, handler: appsScreenHandler);
    router.define(inbox, handler: appsInboxScreenHandler);

    router.define(projects, handler: projectsScreenHandler);
    router.define(projectsCreate, handler: projectsCreateScreenHandler);
    router.define(projectsLabelData, handler: projectsLabelDataScreenHandler);
    router.define(projectsSummary, handler: projectsSummaryScreenHandler);
    router.define(projectsAppCreate, handler: projectsAppCreateScreenHandler);
    router.define(projectsAppDeploy, handler: projectsAppDeployScreenHandler);
    router.define(projectsAppSummary, handler: projectsAppSummaryScreenHandler);
    router.define(projectsSetupData, handler: projectsSetupDataScreenHandler);
    router.define(projectsSetupLabelEditor, handler: projectsSetupLabelEditorHandler);
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
