import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:memri/constants/app_logger.dart';
import 'package:memri/screens/account/login_developer_screen.dart';
import 'package:memri/screens/account/login_screen.dart';
import 'package:memri/screens/account/onboarding_screen.dart';
import 'package:memri/screens/account/save_keys_screen.dart';
import 'package:memri/screens/cvu_screen.dart';
import 'package:memri/screens/not_found_screen.dart';
import 'package:memri/screens/workspace/apps/apps_configure_screen.dart';
import 'package:memri/screens/workspace/apps/apps_inbox_screen.dart';
import 'package:memri/screens/workspace/apps_screen.dart';
import 'package:memri/screens/workspace/data/importers/importer_connect_screen.dart';
import 'package:memri/screens/workspace/data/importers/importer_create_screen.dart';
import 'package:memri/screens/workspace/data/importers/importer_downloading_screen.dart';
import 'package:memri/screens/workspace/data/importers/importer_error_screen.dart';
import 'package:memri/screens/workspace/data/importers/importer_screen.dart';
import 'package:memri/screens/workspace/data_screen.dart';
import 'package:memri/screens/workspace/error_screen.dart';
import 'package:memri/screens/workspace/projects/projects_app_create_screen.dart';
import 'package:memri/screens/workspace/projects/projects_app_deploy_screen.dart';
import 'package:memri/screens/workspace/projects/projects_app_summary_screen.dart';
import 'package:memri/screens/workspace/projects/projects_create_screen.dart';
import 'package:memri/screens/workspace/projects/projects_label_data_screen.dart';
import 'package:memri/screens/workspace/projects/projects_setup_data_screen.dart';
import 'package:memri/screens/workspace/projects/projects_setup_label_editor.dart';
import 'package:memri/screens/workspace/projects_screen.dart';
import 'package:memri/screens/workspace/projects/projects_summary_screen.dart';
import 'package:memri/screens/workspace/workspace_screen.dart';

var notFoundHandler =
    Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
  AppLogger.err('ROUTE WAS NOT FOUND !!!');
  return NotFoundScreen();
});

///
/// Account
///
var onboardingScreenHandler =
    Handler(handlerFunc: (_, __) => OnboardingScreen());

var errorScreenHandler = Handler(handlerFunc: (_, __) => ErrorScreen());

var loginScreenHandler = Handler(handlerFunc: (_, __) => LoginScreen());

var loginDeveloperScreenHandler =
    Handler(handlerFunc: (_, __) => LoginDeveloperScreen());

var saveKeysScreenHandler = Handler(handlerFunc: (_, __) => SaveKeysScreen());

///
/// Workspace
///
var workspaceScreenHandler = Handler(handlerFunc: (_, __) => WorkspaceScreen());

///
/// Data
///
var dataScreenHandler = Handler(handlerFunc: (_, __) => DataScreen());

///
/// Importers
///
var importerScreenHandler = Handler(handlerFunc: (_, __) => ImporterScreen());

var importerCreateScreenHandler =
    Handler(handlerFunc: (_, __) => ImporterCreateScreen());

var importerConnectScreenHandler =
    Handler(handlerFunc: (_, __) => ImporterConnectScreen());

var importerDownloadingScreenHandler = Handler(
    handlerFunc: (_, Map<String, List<String>> params) =>
        ImporterDownloadingScreen(id: params["id"]?.first ?? ""));

var importerErrorScreenHandler =
    Handler(handlerFunc: (_, __) => ImporterErrorScreen());

///
/// Apps
///
var appsScreenHandler = Handler(handlerFunc: (_, __) => AppsScreen());

var appsConfigureScreenHandler =
    Handler(handlerFunc: (_, __) => AppsConfigureScreen());

var appsInboxScreenHandler = Handler(
    handlerFunc: (_, Map<String, List<String>> params) =>
        AppsInboxScreen(importer: params['importer']?.first ?? ''));

///
/// Projects
///
var projectsScreenHandler = Handler(handlerFunc: (_, __) => ProjectsScreen());

var projectsCreateScreenHandler =
    Handler(handlerFunc: (_, __) => ProjectsCreateScreen());

var projectsLabelDataScreenHandler =
    Handler(handlerFunc: (_, __) => ProjectsLabelDataScreen());

var projectsSummaryScreenHandler =
    Handler(handlerFunc: (_, __) => ProjectsSummaryScreen());

var projectsAppCreateScreenHandler =
    Handler(handlerFunc: (_, __) => ProjectsAppCreateScreen());

var projectsAppDeployScreenHandler =
    Handler(handlerFunc: (_, __) => ProjectsAppDeployScreen());

var projectsAppSummaryScreenHandler =
    Handler(handlerFunc: (_, __) => ProjectsAppSummaryScreen());

var projectsSetupDataScreenHandler =
    Handler(handlerFunc: (_, __) => ProjectsSetupDataScreen());

var projectsSetupLabelEditorHandler =
    Handler(handlerFunc: (_, __) => ProjectsSetupLabelEditorScreen());

var cvuHandler = Handler(handlerFunc: (_, __) => CVUScreen());
