import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUViewArguments.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
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
  bool isPageActive = true;

  PageController(this.sceneController, this.label);

  init(String viewName,
      {String? rendererName,
      NavigationStack? navStack,
      CVUViewArguments? viewArguments,
      ItemRecord? targetItem}) async {
    navStack ??= await NavigationStack.fetchOne(label, appController.databaseController);
    if (navStack != null) {
      if (navStack.state.length > 0) {
        topMostContext = makeContext(navStack.state.last);
      }
    } else {
      navStack = NavigationStack(pageLabel: label);
      if (viewName.isNotEmpty || rendererName != null) {
        topMostContext = await CVUActionOpenViewByName(viewName: viewName).getViewContext(
            CVUContext(viewName: viewName, rendererName: rendererName, currentItem: targetItem),
            this,
            viewArguments: viewArguments);
        navStack.state = [ViewContextHolder(topMostContext!.config)];
      }
    }

    _navigationStack = navStack;
    var widget = topMostContext != null
        ? SceneContentView(pageController: this, viewContext: topMostContext!)
        : Empty();
    navigationController.setViewControllers(widget);
  }

  reset() {
    isPageActive = false;
    closeStack = [];
    navigationStack = null;
    navigationController = MemriUINavigationController(); //TODO: change when navigation fixed
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

  NavigationStack? _navigationStack;

  NavigationStack get navigationStack => _navigationStack!;

  set navigationStack(NavigationStack? newValue) {
    if (newValue == null) {
      navigationStack.delete();
    } else {
      navigationStack.save();
    }
    _navigationStack = newValue;
    notifyListeners();
  }

  bool get canNavigateBack => navigationStack.state.length > 1;

  navigateBack() {
    navigateTo(navigationStack.state.length - 2);
  }

  navigateTo(index) {
    var navStack = navigationStack;
    if (navStack.state.isEmpty || navStack.state.length <= index) return;

    isInEditMode.value = false;
    navStack.state.removeRange(index + 1, navStack.state.length);

    topMostContext = navStack.state.isNotEmpty ? makeContext(navStack.state.last) : null;
    navigationStack = navStack;
    if (navStack.state.isEmpty) {
      sceneController.removePageController(this);
      return;
    }

    var vc =
        SceneContentView(pageController: this, viewContext: topMostContext!); //TODO: is this right?
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
