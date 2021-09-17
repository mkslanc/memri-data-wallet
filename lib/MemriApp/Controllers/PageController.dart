import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUViewArguments.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/SceneContentView.dart';
import 'package:memri/MemriApp/UI/UIHelpers/NavigationHolder.dart';
import 'package:memri/MemriApp/UI/ViewContextController.dart';

import 'AppController.dart';
import 'Database/NavigationStack.dart';

class PageController extends ChangeNotifier {
  AppController appController = AppController.shared;
  ViewContextController? topMostContext;
  MemriUINavigationController navigationController = MemriUINavigationController();

  init() async {
    //TODO:
    /*var navStack = await NavigationStack.fetchOne(appController.databaseController);
    if (navStack != null && navStack.state.length > 0) {
      _navigationStack = navStack;
      var topView = navStack.state.last;
      var context = makeContext(topView);
      topMostContext = context;
      navigationController
          .setViewControllers(SceneContentView(sceneController: this, viewContext: context));
    } else {
      var viewName = "onboarding";
      var viewContext = await CVUActionOpenViewByName(viewName: viewName)
          .getViewContext(CVUContext(viewName: viewName, rendererName: "custom"));
      if (viewContext != null) {
        topMostContext = viewContext;
        navigationController
            .setViewControllers(SceneContentView(sceneController: this, viewContext: viewContext));
      } else {
        navigationController.setViewControllers(Center(
          child: Text("Welcome to Memri"),
        ));
      }
    }*/
  }

  ValueNotifier<bool> isInEditMode = ValueNotifier(false);

  toggleEditMode() {
    var topConfigHolder = topMostContext?.configHolder;
    if (topConfigHolder == null) {
      return;
    }
    var viewArgs = topConfigHolder.config.viewArguments;
    viewArgs ??= CVUViewArguments();

    isInEditMode.value = !isInEditMode.value;

    if (!isInEditMode.value) {
      // Clear selection when ending edit mode
      topMostContext?.selectedItems = [];
    }

    var currentArgs = viewArgs.args;
    currentArgs["readOnly"] = CVUValueConstant(CVUConstantBool(!isInEditMode.value));
    var newArgs = CVUViewArguments(
        args: currentArgs,
        argumentItem: viewArgs.argumentItem,
        parentArguments: viewArgs.parentArguments);
    topConfigHolder.config.viewArguments = newArgs;
  }

  NavigationStack _navigationStack = NavigationStack();

  NavigationStack get navigationStack => _navigationStack;

  set navigationStack(NavigationStack newValue) {
    _navigationStack = newValue;
    notifyListeners();
    _navigationStack.save();
  }

  bool get canNavigateBack => navigationStack.state.length > 1;

  navigateBack() {
    var navStack = navigationStack;
    if (navStack.state.length <= 1) {
      return;
    }
    var newTopConfig = navStack.state[navStack.state.length - 2];
    navStack.state.removeLast();

    var context = SceneController.sceneController.makeContext(newTopConfig); //TODO: is this right?
    topMostContext = context;

    navigationStack = navStack;

    var vc = SceneContentView(
        sceneController: SceneController.sceneController,
        viewContext: context); //TODO: is this right?
    navigationController.setViewControllers(vc); //TODO this is not right
  }

  void scheduleUIUpdate([bool updateWithAnimation = false]) {
    topMostContext?.update();
    notifyListeners();
  }
}
