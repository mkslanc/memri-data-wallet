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
class SceneController extends ChangeNotifier {
  AppController appController = AppController.shared;
  static SceneController sceneController = SceneController();

  ViewContextController? topMostContext;

  MemriUINavigationController navigationController = MemriUINavigationController();

  init() async {
    await appController.databaseController.init();
    await appController.cvuController.init();

    setupObservations(); //TODO
    var navStack = await NavigationStack.fetchOne(appController.databaseController);
    if (navStack != null && navStack.state.length > 0) {
      _navigationStack = navStack;
      var topView = navStack.state.last;
      var context = makeContext(topView);
      topMostContext = context;
      navigationController
          .setViewControllers(SceneContentView(sceneController: this, viewContext: context));
    } else {
      navigationController.setViewControllers(Center(
        child: Text("Welcome to Memri"),
      ));
    }
  }

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

  bool isBigScreen = false;
  bool isContentFullscreen = false;

  ValueNotifier<bool> isInEditMode = ValueNotifier(false);

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
            if (title == null || targetViewName == null) {
              return null;
            }
            return NavigationElementItem(Item(title, targetViewName));
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

  NavigationStack _navigationStack = NavigationStack();

  NavigationStack get navigationStack => _navigationStack;

  set navigationStack(NavigationStack newValue) {
    _navigationStack = newValue;
    notifyListeners();
    _navigationStack.save();
  }

  ViewContextController makeContext(ViewContextHolder config) {
    return ViewContextController(
        config: config,
        databaseController: appController.databaseController,
        cvuController: appController.cvuController);
  }

  bool get canNavigateBack => navigationStack.state.length > 1;

  navigateBack() {
    var navStack = navigationStack;
    if (navStack.state.length <= 1) {
      return;
    }
    var newTopConfig = navStack.state[navStack.state.length - 2];
    navStack.state.removeLast();

    var context = makeContext(newTopConfig);
    topMostContext = context;

    navigationStack = navStack;

    var vc = SceneContentView(sceneController: this, viewContext: context);
    navigationController.setViewControllers(vc); //TODO this is not right
  }

  navigateToNewContext(
      {bool clearStack = false,
      bool animated = true,
      required String viewName,
      bool inheritDatasource = false,
      String? overrideRenderer,
      String defaultRenderer = "list",
      ItemRecord? targetItem,
      Set<int>? overrideRowIDs,
      DateTimeRange? dateRange,
      CVUDefinitionContent? customDefinition,
      CVUViewArguments? viewArguments}) async {
    CVUDefinitionContent viewDefinition = appController.cvuController
            .viewDefinitionFor(viewName: viewName, customDefinition: customDefinition) ??
        CVUDefinitionContent();

    viewArguments?.args["readOnly"] ??= CVUValueConstant(CVUConstantBool(!isInEditMode.value));

    var newContext = CVUContext(
        currentItem: targetItem,
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

    var rowIdList = overrideRowIDs ?? Set.of((await datasourceResolver?.intArray("uids")) ?? []);

    var filterDef = datasourceResolver?.subdefinition("filter");

    var edgeTargets = filterDef?.subdefinition("edgeTargets");
    var edgeTargetConditions =
        (await Future.wait((edgeTargets?.properties.keys.toList() ?? []).map((key) async {
      var target = await edgeTargets!.integer(key);
      if (target == null) {
        return null;
      }
      return DatabaseQueryConditionEdgeHasTarget(EdgeHasTarget(key, target));
    })))
            .whereType<DatabaseQueryConditionEdgeHasTarget>()
            .toList();

    var edgeSources = filterDef?.subdefinition("edgeSources");
    var edgeSourceConditions =
        (await Future.wait((edgeSources?.properties.keys.toList() ?? []).map((key) async {
      var source = await edgeSources!.integer(key);
      if (source == null) {
        return null;
      }
      return DatabaseQueryConditionEdgeHasSource(EdgeHasSource(key, source));
    })))
            .whereType<DatabaseQueryConditionEdgeHasSource>()
            .toList();

    var properties = filterDef?.subdefinition("properties");
    List<DatabaseQueryConditionPropertyEquals> propertyConditions =
        (await Future.wait<DatabaseQueryConditionPropertyEquals?>(properties?.properties.keys
                    .toList()
                    .map<Future<DatabaseQueryConditionPropertyEquals?>>((key) async {
                  dynamic value = await properties.boolean(key);
                  if (value != null) {
                    return DatabaseQueryConditionPropertyEquals(PropertyEquals(key, value));
                  } else {
                    value = await properties.string(key);
                    if (value != null) {
                      return DatabaseQueryConditionPropertyEquals(PropertyEquals(key, value));
                    }
                  }
                  return null;
                }) ??
                []))
            .whereType<DatabaseQueryConditionPropertyEquals>()
            .toList();

    var queryConfig = inheritDatasource
        ? (topMostContext?.config.query.clone() ?? DatabaseQueryConfig())
        : DatabaseQueryConfig();
    var itemTypes =
        await datasourceResolver?.stringArray("query") ?? [targetItem?.type].compactMap();
    if (itemTypes.isNotEmpty) {
      queryConfig.itemTypes = itemTypes;
    }

    var sortDef = datasourceResolver?.subdefinition("sort");
    if (sortDef != null) {
      queryConfig.sortEdges = await queryConfig.combineSortEdgesQuery(
          sortResolver: sortDef, dbController: appController.databaseController);
    }

    if (rowIdList.isNotEmpty) {
      queryConfig.itemRowIDs = rowIdList;
    }
    var edgeTargetsOperator = datasourceResolver?.properties["edgeTargetsOperator"];
    if (edgeTargetsOperator != null &&
        edgeTargetsOperator is CVUValueConstant &&
        edgeTargetsOperator.value is CVUConstantString) {
      var operator = (edgeTargetsOperator.value as CVUConstantString).value;
      queryConfig.edgeTargetsOperator =
          operator == "OR" ? ConditionOperator.or : ConditionOperator.and;
    }

    var sortProperty = await datasourceResolver?.string("sortProperty");
    if (sortProperty != null) {
      queryConfig.sortProperty = sortProperty;
    }
    var sortAscending = await datasourceResolver?.boolean("sortAscending");
    if (sortAscending != null) {
      queryConfig.sortAscending = sortAscending;
    }

    if (dateRange != null) {
      queryConfig.dateModifiedAfter = dateRange.start;
      queryConfig.dateModifiedBefore = dateRange.end;
    }
    if (edgeTargetConditions.isNotEmpty || propertyConditions.isNotEmpty) {
      queryConfig.conditions = []
        ..addAll(edgeTargetConditions)
        ..addAll(edgeSourceConditions)
        ..addAll(propertyConditions);
    }

    var count = await datasourceResolver?.integer("count");
    if (count != null) {
      queryConfig.count = count;
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
    var navStack = navigationStack;
    if (clearStack) {
      navStack.state = [holder];
    } else {
      navStack.state.add(holder);
    }
    navigationStack = navStack; //TODO
    navigationController.setViewControllers(
        SceneContentView(sceneController: this, viewContext: newViewContextController));
  }

  late List<BuildContext> closeStack = [];

  addToStack(BuildContext context) {
    closeStack.add(context);
  }

  closeLastInStack() {
    var lastStack = closeStack.removeLast();
    Navigator.of(lastStack).pop();
  }

  void scheduleUIUpdate([bool updateWithAnimation = false]) {
    if (topMostContext == null) {
      return;
    }

    topMostContext?.update();
    notifyListeners();
  }
}
