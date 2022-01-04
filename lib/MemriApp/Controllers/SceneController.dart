import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/CVU/resolving/CVULookupController.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUViewArguments.dart';
import 'package:memri/MemriApp/UI/Navigation/NavigationPaneView.dart';
import 'package:memri/MemriApp/UI/SceneContentView.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';
import 'package:memri/MemriApp/UI/ViewContext.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';

import 'AppController.dart';
import 'Database/DatabaseQuery.dart';
import 'Database/ItemRecord.dart';
import 'Database/NavigationStack.dart';
import 'PageController.dart' as memri;

/// The scene controller is specific to a particular `window` of the app. On the iPhone there is usually only one. There may be multiple eg. if multitasking on iPad or multiple windows on mac
class SceneController extends ChangeNotifier {
  AppController appController = AppController.shared;
  static late SceneController sceneController;
  SceneController? parentSceneController;
  List<SceneController> subSceneControllers = [];

  List<memri.PageController> pageControllers = [];

  init([List<Map<String, String>>? pages]) async {
    try {
      var navStackList = <String, NavigationStack>{};
      if (pages == null) {
        var savedNavStackList = await NavigationStack.fetchAll(appController.databaseController);
        pages = savedNavStackList.compactMap((navStack) {
          if (navStack.pageLabel.startsWith("main")) {
            navStackList[navStack.pageLabel] = navStack;
            return {"label": navStack.pageLabel};
          }
        });

        if (pages.length > 1) {
          navStackList.forEach((key, value) {
            if (value.state.isNotEmpty) value.state.last.config.cols ??= 5;
          }); //TODO cols part logic is not clear, so just dirty hack for now
        }
      }
      if (pages.isEmpty) {
        pages.add({"label": "main", "viewName": "home"});
      }

      await Future.forEach<Map<String, String>>(pages, (page) async {
        await addPageController(page["label"]!,
            viewName: page["viewName"], navStack: navStackList[page["label"]]);
      });
    } catch (e) {
      throw e;
    }

    setupObservations(); //TODO
  }

  Future<memri.PageController> addPageController(String label,
      {String? viewName, String? rendererName, NavigationStack? navStack}) async {
    var pageController = memri.PageController(this, label);
    await pageController.init(viewName ?? "", rendererName: rendererName, navStack: navStack);
    pageController.addListener(() => notifyListeners());
    pageControllers.add(pageController);
    return pageController;
  }

  removePageController(pageController) {
    pageControllers.removeWhere((element) => element == pageController);
    pageController.reset();
  }

  reset() async {
    navigationIsVisible.value = false;
    pageControllers.forEach((pageController) => pageController.reset());
    pageControllers = [];
    parentSceneController?.subSceneControllers
        .removeWhere((subSceneController) => subSceneController == this);
  }

  bool isBigScreen = true;
  bool isContentFullscreen = false;

  ValueNotifier<bool> navigationIsVisible = ValueNotifier(false);

  String? get navigationFilterText => _navigationQuery.searchString;

  set navigationFilterText(String? newValue) {
    _navigationQuery.searchString = newValue?.nullIfBlank;
    setupObservations();
  }

  ValueNotifier<bool> filterPanelIsVisible = ValueNotifier(false);

  DatabaseQueryConfig _navigationQuery =
      DatabaseQueryConfig(itemTypes: ["NavigationItem"], sortProperty: "");

  Future<List<NavigationElement?>?> get navigationItems async {
    var itemsStream = navigationItemRecords.stream;
    await for (var itemStream in itemsStream) {
      itemStream.sort((a, b) {
        var aRowID = a.rowId;
        var bRowID = b.rowId;
        if (aRowID == null || bRowID == null) {
          return 0;
        }
        return aRowID - bRowID;
      });
      return Future.wait<NavigationElement?>(
          itemStream.compactMap<Future<NavigationElement?>>((item) async {
        String? title;
        switch ((await item.propertyValue("itemType"))?.asString()) {
          case "heading":
            title = (await item.propertyValue("title"))?.asString();
            if (title == null) {
              return null;
            }
            return NavigationElementHeading(title);
          case "line":
            return NavigationElementLine();
          default:
            title = (await item.propertyValue("title"))?.asString();
            var targetViewName = (await item.propertyValue("sessionName"))?.asString();
            var icon = (await item.propertyValue("icon"))?.asString();
            if (title == null || targetViewName == null) {
              return null;
            }
            return NavigationElementItem(
                Item(name: title, targetViewName: targetViewName, icon: icon));
        }
      }));
    }
  }

  StreamController<List<ItemRecord>> navigationItemRecords = StreamController.broadcast();

  StreamSubscription<List<ItemRecord>>? _queryObservation;

  /// Sets up a database observation
  setupObservations() {
    _queryObservation?.cancel();

    /// Note that the request must remain constant within the observation, hence constructed outside of the tracking (if changed, start a observation)
    _queryObservation = _navigationQuery
        .executeRequest(appController.databaseController)
        .asBroadcastStream()
        .listen((records) {
      navigationItemRecords.add(records);
    });
  }

  navigateToNewContext(
      {CVUDefinitionContent? defaultDefinition,
      CVUContext? defaultContext,
      bool clearStack = false,
      bool animated = true,
      String? viewName,
      bool inheritDatasource = false,
      String? overrideRenderer,
      String defaultRenderer = "list",
      ItemRecord? targetItem,
      Set<int>? overrideRowIDs,
      DateTimeRange? dateRange,
      CVUDefinitionContent? customDefinition,
      CVUViewArguments? viewArguments,
      memri.PageController? pageController}) async {
    CVUDefinitionContent viewDefinition = defaultDefinition ??
        appController.cvuController
            .viewDefinitionFor(viewName: viewName ?? "", customDefinition: customDefinition) ??
        CVUDefinitionContent();

    viewArguments ??= CVUViewArguments();
    var pageLabelVal = viewArguments.args["pageLabel"]?.value;
    String pageLabel;
    if (pageLabelVal != null) {
      pageLabel = (pageLabelVal as CVUConstantString).value;
      pageController = pageControllerByLabel(pageLabel);
    }

    pageController ??= pageControllers.first;
    pageLabel = pageController.label;

    viewArguments.args["readOnly"] ??= viewDefinition.properties["readOnly"] ??
        CVUValueConstant(CVUConstantBool(!pageController.isInEditMode.value));
    pageController.isInEditMode.value = !viewArguments.args["readOnly"]!.value.value;

    var cvuContext = CVUContext(
        currentItem: targetItem,
        selector: null,
        viewName: viewName,
        viewDefinition: viewDefinition,
        viewArguments: viewArguments);

    var rendererName = overrideRenderer ??
        await viewDefinition
            .propertyResolver(
                context: cvuContext,
                lookup: CVULookupController(),
                db: appController.databaseController)
            .string("defaultRenderer") ??
        defaultRenderer;

    var datasource = viewDefinition.definitions
        .firstWhereOrNull((definition) => definition.type == CVUDefinitionType.datasource);
    var queryConfig = await DatabaseQueryConfig.queryConfigWith(
        context: cvuContext,
        datasource: datasource,
        inheritQuery: inheritDatasource ? pageController.topMostContext?.config.query : null,
        overrideUIDs: overrideRowIDs,
        targetItem: targetItem,
        dateRange: dateRange);

    var config = ViewContext(
        viewName: viewName,
        rendererName: rendererName,
        viewDefinition: viewDefinition,
        query: queryConfig,
        viewArguments: viewArguments,
        focusedItem: targetItem,
        pageLabel: pageController.label);
    var holder = ViewContextHolder(config);

    var newViewContextController = pageController.makeContext(holder);

    var pageIndex = pageControllers.indexOf(pageController);
    if (pageIndex < pageControllers.length - 1) {
      for (var index = pageIndex + 1; index < pageControllers.length; index++) {
        var secondaryPageController = pageControllers[index];
        secondaryPageController.topMostContext = null; // TODO: ??
        secondaryPageController.navigationController.setViewControllers(Empty());
        secondaryPageController.navigationStack.state = [];
        secondaryPageController.navigationStack = secondaryPageController.navigationStack;
      }
    }

    var navStack = pageController.navigationStack;
    if (clearStack) {
      navStack.state = [holder];
    } else {
      navStack.state.add(holder);
    }
    pageController.topMostContext = newViewContextController;
    pageController.navigationStack = navStack;
    pageController.navigationController.setViewControllers(
        SceneContentView(pageController: pageController, viewContext: newViewContextController));
  }

  memri.PageController? pageControllerByLabel(String label) {
    return pageControllers.firstWhereOrNull((pageController) => pageController.label == label);
  }

  scheduleUIUpdate() {
    pageControllers.forEach((pageController) {
      pageController.scheduleUIUpdate();
    });
  }
}
