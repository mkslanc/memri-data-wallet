import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUViewArguments.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/SceneContentView.dart';
import 'package:memri/MemriApp/UI/UIHelpers/NavigationHolder.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';
import 'package:memri/MemriApp/UI/ViewContext.dart';
import 'package:memri/MemriApp/UI/ViewContextController.dart';

import 'AppController.dart';
import 'Database/NavigationStack.dart';

class PageController extends ChangeNotifier {
  AppController appController = AppController.shared;
  SceneController sceneController;
  ViewContextController? topMostContext;
  bool showTopBar = true;
  String label;
  MemriUINavigationController navigationController = MemriUINavigationController();

  PageController(this.sceneController, this.label);

  init() async {
    var navStack = await NavigationStack.fetchOne(label, appController.databaseController);
    if (navStack != null) {
      _navigationStack = navStack;
      Widget widget;
      if (navStack.state.length > 0) {
        var topView = navStack.state.last;
        var context = makeContext(topView);
        topMostContext = context;
        widget = SceneContentView(pageController: this, viewContext: context);
      } else {
        widget = Empty();
      }
      navigationController.setViewControllers(widget);
    } else {
      _navigationStack = NavigationStack(pageLabel: label);
      var viewName = "onboarding";
      var viewContext = await CVUActionOpenViewByName(viewName: viewName)
          .getViewContext(CVUContext(viewName: viewName, rendererName: "custom"), this);
      if (viewContext != null) {
        topMostContext = viewContext;
        navigationController
            .setViewControllers(SceneContentView(pageController: this, viewContext: viewContext));
      } else {
        navigationController.setViewControllers(Center(
          child: Text("Welcome to Memri"),
        ));
      }
    }
  }

  ViewContextController makeContext(ViewContextHolder config) {
    return ViewContextController(
        config: config,
        databaseController: appController.databaseController,
        cvuController: appController.cvuController,
        pageController: this);
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

  late NavigationStack _navigationStack;

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

    var context = makeContext(newTopConfig); //TODO: is this right?
    topMostContext = context;

    navigationStack = navStack;

    var vc = SceneContentView(pageController: this, viewContext: context); //TODO: is this right?
    navigationController.setViewControllers(vc); //TODO this is not right
  }

  void scheduleUIUpdate([bool updateWithAnimation = false]) {
    topMostContext?.update();
    notifyListeners();
  }

  late List<BuildContext> closeStack = [];

  addToStack(BuildContext context) {
    //TODO: ??
    closeStack.add(context);
  }

  closeLastInStack() {
    var lastStack = closeStack.removeLast();
    Navigator.of(lastStack).pop();
  }
}
