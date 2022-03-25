import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/controllers/cvu_lookup_controller.dart';
import 'package:memri/controllers/database_query.dart';
import 'package:memri/controllers/page_controller.dart' as memri;
import 'package:memri/core/cvu/resolving/cvu_context.dart';
import 'package:memri/core/services/database/navigation_stack.dart';
import 'package:memri/models/cvu/cvu_parsed_definition.dart';
import 'package:memri/models/cvu/cvu_value.dart';
import 'package:memri/models/cvu/cvu_value_constant.dart';
import 'package:memri/models/cvu/cvu_view_arguments.dart';
import 'package:memri/models/database/item_record.dart';
import 'package:memri/models/view_context.dart';
import 'package:memri/utils/extensions/collection.dart';
import 'package:memri/utils/extensions/string.dart';
import 'package:memri/widgets/empty.dart';
import 'package:memri/widgets/navigation/navigation_pane_view.dart';
import 'package:memri/widgets/scene_content_view.dart';

/// The scene controller is specific to a particular `window` of the app. On the iPhone there is usually only one. There may be multiple eg. if multitasking on iPad or multiple windows on mac
class SceneController extends ChangeNotifier {
  AppController appController = AppController.shared;
  static late SceneController sceneController;
  SceneController? parentSceneController;
  List<SceneController> subSceneControllers = [];

  List<memri.PageController> pageControllers = [];

  init([List<Map<String, dynamic>>? pages]) async {
    try {
      var navStackList = <String, NavigationStack>{};
      if (pages == null) {
        var savedNavStackList = await NavigationStack.fetchAll(appController.databaseController);
        pages = savedNavStackList.compactMap((navStack) {
          if (navStack.pageLabel.startsWith("main")) {
            navStackList[navStack.pageLabel] = navStack;
            return {"label": navStack.pageLabel};
          }
          return null;
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

      await Future.forEach<Map<String, dynamic>>(pages, (page) async {
        await addPageController(page["label"]!,
            viewName: page["viewName"],
            navStack: navStackList[page["label"]],
            viewArguments: page["viewArguments"],
            targetItem: page["targetItem"]);
      });
    } catch (e) {
      throw e;
    }

    setupObservations(); //TODO
  }

  Future<memri.PageController> addPageController(String label,
      {String? viewName,
      String? rendererName,
      NavigationStack? navStack,
      CVUViewArguments? viewArguments,
      ItemRecord? targetItem}) async {
    var pageController = memri.PageController(this, label);
    await pageController.init(viewName ?? "",
        rendererName: rendererName,
        navStack: navStack,
        viewArguments: viewArguments,
        targetItem: targetItem);
    pageController.addListener(() => notifyListeners());
    pageControllers.add(pageController);
    return pageController;
  }

  removePageController(memri.PageController pageController) {
    pageControllers.removeWhere((element) => element == pageController);
    pageControllers.forEach((element) => element.topMostContext?.config.cols = null);
    pageController.reset();
  }

  reset() {
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
    return null;
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
        bool clearPageControllers = false,
      memri.PageController? pageController}) async {
    CVUDefinitionContent viewDefinition = defaultDefinition ??
        appController.cvuController
            .viewDefinitionFor(viewName: viewName ?? "", customDefinition: customDefinition) ??
        CVUDefinitionContent();
    if (clearPageControllers) {
      removePageControllers();
    }
    var viewArgs = viewDefinition.properties["viewArguments"];
    viewArguments ??= CVUViewArguments();
    viewArguments.argumentItem = targetItem;
    if (viewArgs is CVUValueSubdefinition) {
      viewArguments.args = viewArgs.value.properties;
    }
    var pageLabelVal = viewArguments.args["pageLabel"]?.value;
    String? pageLabel;
    if (pageLabelVal != null) {
      pageLabel = (pageLabelVal as CVUConstantString).value;
      pageController = pageControllerByLabel(pageLabel);
    }

    if (pageController == null && pageLabel != null) {
      var addPageIfMissingVal = viewArguments.args["addPageIfMissing"]?.value;
      if (addPageIfMissingVal != null && (addPageIfMissingVal as CVUConstantBool).value) {
        pageController = await addPageController(pageLabel);
      }
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
        dateRange: dateRange,
        databaseController: appController.databaseController);

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
      var clearSecondary = true;
      var clearSecondaryVal = viewDefinition.properties["clearSecondary"];
      if (clearSecondaryVal is CVUValueConstant && clearSecondaryVal.value is CVUConstantBool) {
        clearSecondary = clearSecondaryVal.value.asBool()!;
      }

      if (clearSecondary) {
        for (var index = pageIndex + 1; index < pageControllers.length; index++) {
          var secondaryPageController = pageControllers[index];
          secondaryPageController.topMostContext = null; // TODO: ??
          secondaryPageController.navigationController.setViewControllers(Empty());
          secondaryPageController.navigationStack.state = [];
          secondaryPageController.navigationStack = secondaryPageController.navigationStack;
        }
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

  exitEditMode() {
    pageControllers.forEach((pageController) => pageController.isInEditMode.value = false);
  }

  scheduleUIUpdate() {
    pageControllers.forEach((pageController) {
      pageController.scheduleUIUpdate();
    });
  }

  removePageControllers() {
    pageControllers.skip(1).toList().forEach((element) {
      removePageController(element);
    });
  }
}
