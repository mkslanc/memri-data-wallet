import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:memri/constants/app_logger.dart';
import 'package:memri/cvu/controllers/view_context_controller.dart';
import 'package:memri/screens/account/login_developer_screen.dart';
import 'package:memri/screens/account/login_screen.dart';
import 'package:memri/screens/account/save_keys_screen.dart';
import 'package:memri/screens/all_item_types_screen.dart';
import 'package:memri/screens/cvu_screen.dart';
import 'package:memri/screens/not_found_screen.dart';

var notFoundHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
  AppLogger.err('ROUTE WAS NOT FOUND !!!');
  return NotFoundScreen();
});

///
/// Account
///
var onboardingScreenHandler = Handler(handlerFunc: (_, __) => LoginDeveloperScreen());//OnboardingScreen

var loginScreenHandler = Handler(handlerFunc: (_, __) => LoginScreen());

var loginDeveloperScreenHandler = Handler(handlerFunc: (_, __) => LoginDeveloperScreen());

var saveKeysScreenHandler = Handler(handlerFunc: (_, __) => SaveKeysScreen());

var cvuHandler = Handler(
    handlerFunc: (_, __) => CVUScreen(
          viewContextController: ViewContextController.fromParams(viewName: "messageChannelView"),
        ));

var indexHandler = Handler(
    handlerFunc: (_, __) => AllItemTypesScreen()
);