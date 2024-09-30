import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:memri/constants/app_logger.dart';
import 'package:memri/cvu/controllers/view_context_controller.dart';
import 'package:memri/providers/ui_state_provider.dart';
import 'package:memri/screens/account/login_developer_screen.dart';
import 'package:memri/screens/account/login_screen.dart';
import 'package:memri/screens/account/save_keys_screen.dart';
import 'package:memri/screens/all_item_types_screen.dart';
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

var _indexViewContextController;

var indexHandler = Handler(
    handlerFunc: (_, __) {
      if (_indexViewContextController == null) {
        _indexViewContextController ??= ViewContextController.fromParams();
        GetIt.I<UIStateProvider>().navigateToContext(_indexViewContextController);
      }

      return AllItemTypesScreen(viewContextController: _indexViewContextController);
    }
);