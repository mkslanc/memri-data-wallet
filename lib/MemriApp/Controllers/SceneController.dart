//
//  SceneController.swift
//  MemriDatabase
//
//  Created by T Brennan on 14/12/20.
//

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/CVU/resolving/CVULookupController.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUViewArguments.dart';
import 'package:memri/MemriApp/UI/ViewContext.dart';
import 'package:memri/MemriApp/UI/ViewContextController.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';

import 'AppController.dart';
import 'Database/DatabaseQuery.dart';
import 'Database/ItemRecord.dart';

/// The scene controller is specific to a particular `window` of the app. On the iPhone there is usually only one. There may be multiple eg. if multitasking on iPad or multiple windows on mac
class SceneController {
  AppController appController = AppController.shared;

  ViewContextController? topMostContext;

  // MemriUINavigationController navigationController = MemriUINavigationController();

  init() {
    // setupObservations();
    //
    // var oldState = appController.databaseController.read {
    // try NavigationStack.fetchOne($0)
    // }
    // if let navStack = oldState, let topView = navStack.state.last {
    // navigationStack = navStack
    // let context = makeContext(forConfig: topView)
    // topMostContext = context
    // navigationController.viewControllers = [UIHostingController(rootView: SceneContentView(context: context))]
    // } else {
    // navigationController.viewControllers = [UIHostingController(rootView: Text("Welcome to Memri"))]
    // }
  }

  // @Published
  bool isContentFullscreen = false;

  // @Published
  bool isInEditMode = false;

  // @Published
  bool navigationIsVisible = false;

  String? get navigationFilterText => _navigationQuery.searchString;

  set(String? newValue) => _navigationQuery.searchString = newValue?.nilIfBlank;

  // @Published
  bool filterPanelIsVisible = false;

  DatabaseQueryConfig _navigationQuery =
      DatabaseQueryConfig(itemTypes: ["NavigationItem"], sortProperty: "");

  List<NavigationElement> get navigationItems {
    return _navigationItemRecords.map<NavigationElement>((item) {
      String? title;
      switch (item.propertyValue("itemType")?.asString()) {
        case "heading":
          title = item.propertyValue("title")?.asString();
          if (title != null) {
            return null;
          }
          return NavigationElement.heading(title);
        case "line":
          return NavigationElement.line();
        default:
          title = item.propertyValue("title")?.asString();
          var targetViewName = item.propertyValue("sessionName")?.asString();
          if (title == null || targetViewName == null) {
            return null;
          }
          return NavigationElement.item(NavigationElement.Item(title, targetViewName));
      }
    }).toList();
  }

  // @Published
  List<ItemRecord> _navigationItemRecords = <ItemRecord>[];

  // _queryObservation: AnyCancellable?
  /// Sets up a database observation
  _setupObservations() {
    /// Remove old observation
    // queryObservation?.cancel()
    // queryObservation = nil

    /// Note that the request must remain constant within the observation, hence constructed outside of the tracking (if changed, start a observation)
    var config = _navigationQuery;
    // var observation = ValueObservation
    //     .tracking {
    //   db in
    //   try
    //   config.executeRequest(db: db)
    // }

    /// Subscribe to changes in the value, with the first result being reported immediately
    // queryObservation = observation.publisher(
    // in: appController.databaseController.databasePool,
    // scheduling: .immediate)
    //     .sink(
    //     receiveCompletion: { completion in},
    //     receiveValue: { result in
    //       self.navigationItemRecords = result
    //     })
  }

  NavigationStack _navigationStack;

  /* = NavigationStack() {
  willSet {
  if newValue != navigationStack {
  objectWillChange.send()
  }
  }
  didSet {
  if navigationStack != oldValue {
  try? appController.databaseController.writeSync {
  try navigationStack.save($0)
  }
  }
  }
  }*/

  ViewContextController makeContext(ViewContextHolder config) {
    return ViewContextController(
        config: config,
        databaseController: appController.databaseController,
        cvuController: appController.cvuController);
  }

  bool get canNavigateBack => _navigationStack.state.count > 1;

  navigateBack() {
    if (_navigationStack.state.length <= 1) {
      return;
    }
    var newTopConfig = _navigationStack.state[_navigationStack.state.endIndex - 2];
    _navigationStack.state.pop();

    var context = makeContext(newTopConfig);
    topMostContext = context;

    // var vc = UIHostingController(SceneContentView(context));
    // navigationController.viewControllers.insert(vc, at: navigationController.viewControllers.endIndex - 1);
    // navigationController.popToViewController(vc, animated: true);
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
    ;

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
    var sortProperty = await datasourceResolver?.string("sortProperty");
    if (sortProperty != null) {
      queryConfig.sortProperty = sortProperty;
    }
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
      navigationStack.state = [holder];
    } else {
      navigationStack.state.append(holder);
    }
    navigationController.setViewControllers(
        [UIHostingController(rootView: SceneContentView(context: newViewContextController))],
        animated: animated);
  }
}
