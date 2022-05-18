import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:memri/constants/app_logger.dart';
import 'package:memri/screens/account/onboarding_screen.dart';
import 'package:memri/screens/account/login_developer_screen.dart';
import 'package:memri/screens/account/login_screen.dart';
import 'package:memri/screens/account/save_keys_screen.dart';
import 'package:memri/screens/not_found_screen.dart';
import 'package:memri/screens/splash_screen.dart';
import 'package:memri/screens/workspace/apps_screen.dart';
import 'package:memri/screens/workspace/data_screen.dart';
import 'package:memri/screens/workspace/inbox_screen.dart';
import 'package:memri/screens/workspace/plugin/whatsapp/whatsapp_connect_screen.dart';
import 'package:memri/screens/workspace/plugin/whatsapp/whatsapp_screen.dart';
import 'package:memri/screens/workspace/workspace_screen.dart';

var notFoundHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
  AppLogger.err('ROUTE WAS NOT FOUND !!!');
  return NotFoundScreen();
});

var splashScreenHandler = Handler(handlerFunc: (_, __) => SplashScreen());

var onboardingScreenHandler = Handler(handlerFunc: (_, __) => OnboardingScreen());

var loginScreenHandler = Handler(handlerFunc: (_, __) => LoginScreen());

var loginDeveloperScreenHandler = Handler(handlerFunc: (_, __) => LoginDeveloperScreen());

var saveKeysScreenHandler = Handler(handlerFunc: (_, __) => SaveKeysScreen());

var workspaceScreenHandler = Handler(handlerFunc: (_, __) => WorkspaceScreen());

var dataScreenHandler = Handler(handlerFunc: (_, __) => DataScreen());

var whatsappScreenHandler = Handler(handlerFunc: (_, __) => WhatsappScreen());

var whatsappConnectScreenHandler = Handler(handlerFunc: (_, __) => WhatsappConnectScreen());

var appsScreenHandler = Handler(handlerFunc: (_, __) => AppsScreen());

var inboxScreenHandler = Handler(handlerFunc: (_, __) => InboxScreen());

// var introScreenHandler = Handler(
//     handlerFunc: (BuildContext context, Map<String, List<String>> params) {
//   return IntroScreen();
// });

// var homeScreenHandler = Handler(
//     handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
//   return HomeScreen();
// });
//
// var profileScreenHandler = Handler(
//     handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
//   return ProfileScreen();
// });

// var settingsScreenHandler = Handler(
//     handlerFunc: (BuildContext context, Map<String, List<String>> params) {
//   return SettingsScreen();
// });

// var storeScreenHandler = Handler(
//     handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
//   String placeId = params['placeId']?.first ?? '';
//   String tableId = params['tableId']?.first ?? '';
//   String shortId = params['shortId']?.first ?? '';
//   return StoreScreen(placeId: placeId, tableId: tableId, shortId: shortId);
// });
//
// var storeAdminScreenHandler = Handler(
//     handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
//   String placeId = params['placeId']?.first ?? '';
//   return StoreAdminScreen(placeId: placeId);
// });
//
// var storeCreationScreenHandler = Handler(
//     handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
//   return CreateStoreScreen();
// });
//
// var storeFindScreenHandler = Handler(
//     handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
//   return FindStoreScreen();
// });
//
// var faqScreenHandler = Handler(
//     handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
//   return FAQScreen();
// });
//
// var privacyPolicyScreenHandler = Handler(
//     handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
//   return PrivacyPolicyScreen();
// });
//
// var termsConditionScreenHandler = Handler(
//     handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
//   return TermsOfUseScreen();
// });
//
// var aboutUsScreenHandler = Handler(
//     handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
//   return AboutUsScreen();
// });
