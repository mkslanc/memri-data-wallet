import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/CVU/resolving/CVULookupController.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUViewArguments.dart';
import 'package:memri/MemriApp/UI/Navigation/NavigationPaneView.dart';
import 'package:memri/MemriApp/UI/SceneContentView.dart';
import 'package:memri/MemriApp/UI/UIHelpers/NavigationHolder.dart';
import 'package:memri/MemriApp/UI/ViewContext.dart';
import 'package:memri/MemriApp/UI/ViewContextController.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';

import 'AppController.dart';
import 'Database/DatabaseQuery.dart';
import 'Database/ItemRecord.dart';
import 'Database/NavigationStack.dart';

/// The scene controller is specific to a particular `window` of the app. On the iPhone there is usually only one. There may be multiple eg. if multitasking on iPad or multiple windows on mac
class SceneController {
  AppController appController = AppController.shared;

  ViewContextController? topMostContext;

  MemriUINavigationController navigationController = MemriUINavigationController();

  init() async {
    // setupObservations();//TODO
    var navStack = await NavigationStack.fetchOne(appController.databaseController);
    if (navStack != null && navStack.state.length > 0) {
      navigationStack = navStack;
      var topView = navStack.state.last;
      var context = makeContext(topView);
      topMostContext = context;
      navigationController
          .setViewControllers(SceneContentView(sceneController: this, viewContext: context));
    } else {
      navigationController.setViewControllers(Text("Welcome to Memri"));
    }
  }

  // @Published
  bool isContentFullscreen = false;

  // @Published
  bool isInEditMode = false;

  ValueNotifier<bool> navigationIsVisible = ValueNotifier(false);
  ValueNotifier<bool> shouldUpdate =
      ValueNotifier(false); //TODO dirty hack, delete as soon as good solution is found @anijanyan

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
            if (title == null || targetViewName == null) {
              return null;
            }
            return NavigationElementItem(Item(title, targetViewName));
        }
      }));
    }
  }

  // @Published
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

  NavigationStack _navigationStack = NavigationStack();
  set navigationStack(NavigationStack newValue) {
    _navigationStack = newValue;
    shouldUpdate.value = !shouldUpdate.value; //TODO dirty hack
  }

  /* = NavigationStack() {
  willSet {
  if newValue != navigationStack {
  objectWillChange.send()
  }
  }
  didSet {
  if navigationStack != oldValue {
  try? appController.databaseController.writeSync {
  try .save($0)
  }navigationStack
  }
  }
  }*/

  ViewContextController makeContext(ViewContextHolder config) {
    return ViewContextController(
        config: config,
        databaseController: appController.databaseController,
        cvuController: appController.cvuController);
  }

  bool get canNavigateBack => _navigationStack.state.length > 1;

  navigateBack() {
    if (_navigationStack.state.length <= 1) {
      return;
    }
    var newTopConfig = _navigationStack.state[_navigationStack.state.length - 1 - 2];
    _navigationStack.state.removeLast();
    navigationStack = _navigationStack; //TODO

    var context = makeContext(newTopConfig);
    topMostContext = context;
    var vc = MaterialPage(child: SceneContentView(sceneController: this, viewContext: context));
    // navigationController.pages.add(vc);
    //navigationController.popToViewController(vc, animated: true); TODO: need to test this
  }

  navigateToNewContext(
      {bool clearStack = false,
      bool animated = true,
      required String viewName,
      bool inheritDatasource = false,
      String? overrideRenderer,
      String defaultRenderer = "list",
      ItemRecord? targetItem,
      Set<String>? overrideUIDs,
      DateTimeRange? dateRange,
      CVUDefinitionContent? customDefinition,
      CVUViewArguments? viewArguments}) async {
    CVUDefinitionContent viewDefinition = appController.cvuController
            .viewDefinitionFor(viewName: viewName, customDefinition: customDefinition) ??
        CVUDefinitionContent();

    var newContext = CVUContext(
        currentItem: null,
        selector: null,
        viewName: viewName,
        viewDefinition: viewDefinition,
        viewArguments: viewArguments);

    var rendererName = overrideRenderer ??
        await viewDefinition
            .propertyResolver(
                context: newContext,
                lookup: CVULookupController(),
                db: appController.databaseController)
            .string("defaultRenderer") ??
        defaultRenderer;

    var datasource = viewDefinition.definitions
        .firstWhereOrNull((definition) => definition.type == CVUDefinitionType.datasource);
    var datasourceResolver = datasource?.parsed.propertyResolver(
        context: newContext, lookup: CVULookupController(), db: appController.databaseController);

    var uidList = overrideUIDs ?? Set.of((await datasourceResolver?.stringArray("uids")) ?? []);

    var filterDef = datasourceResolver?.subdefinition("filter");
    var edgeTargets = filterDef?.subdefinition("edgeTargets");
    var edgeTargetConditions =
        (await Future.wait((edgeTargets?.properties.keys.toList() ?? []).map((key) async {
      var target = await edgeTargets!.string(key);
      if (target == null) {
        return null;
      }
      return DatabaseQueryConditionEdgeHasTarget(EdgeHasTarget(key, target));
    })))
            .whereType<DatabaseQueryConditionEdgeHasTarget>()
            .toList();

    var queryConfig = inheritDatasource
        ? (topMostContext?.config.query ?? DatabaseQueryConfig())
        : DatabaseQueryConfig();
    var itemTypes =
        await datasourceResolver?.stringArray("query") ?? [targetItem?.type].compactMap();
    if (itemTypes.isNotEmpty) {
      queryConfig.itemTypes = itemTypes;
    }
    if (uidList.isNotEmpty) {
      queryConfig.itemUIDs = uidList;
    }
    /*var sortProperty = await datasourceResolver?.string("sortProperty"); TODO
    if (sortProperty != null) {
      queryConfig.sortProperty = sortProperty;
    }*/
    if (dateRange != null) {
      queryConfig.dateModifiedAfter = dateRange.start;
      queryConfig.dateModifiedBefore = dateRange.end;
    }
    if (edgeTargetConditions.isNotEmpty) {
      queryConfig.conditions = edgeTargetConditions;
    }

    var config = ViewContext(
        viewName: viewName,
        rendererName: rendererName,
        viewDefinition: viewDefinition,
        query: queryConfig,
        viewArguments: viewArguments,
        focusedItem: targetItem);
    var holder = ViewContextHolder(config);

    var newViewContextController = makeContext(holder);
    topMostContext = newViewContextController;
    if (clearStack) {
      _navigationStack.state = [holder];
    } else {
      _navigationStack.state.add(holder);
    }
    navigationStack = _navigationStack; //TODO
    navigationController.setViewControllers(
        SceneContentView(sceneController: this, viewContext: newViewContextController));
  }
}
