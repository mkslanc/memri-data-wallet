//  Created by T Brennan on 8/1/21.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:memri/constants/app_logger.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/controllers/cvu_controller.dart';
import 'package:memri/controllers/cvu_lookup_controller.dart';
import 'package:memri/controllers/database_controller.dart';
import 'package:memri/controllers/database_query.dart';
import 'package:memri/controllers/page_controller.dart' as memri;
import 'package:memri/controllers/view_context_controller.dart';
import 'package:memri/core/apis/gitlab_api.dart';
import 'package:memri/core/cvu/parsing/cvu_expression_lexer.dart';
import 'package:memri/core/cvu/parsing/cvu_expression_parser.dart';
import 'package:memri/core/cvu/resolving/cvu_context.dart';
import 'package:memri/core/cvu/resolving/cvu_property_resolver.dart';
import 'package:memri/core/services/database/property_database_value.dart';
import 'package:memri/core/services/database/schema.dart';
import 'package:memri/core/services/plugin_handler.dart';
import 'package:memri/models/cvu/cvu_parsed_definition.dart';
import 'package:memri/models/cvu/cvu_value.dart';
import 'package:memri/models/cvu/cvu_value_constant.dart';
import 'package:memri/models/cvu/cvu_view_arguments.dart';
import 'package:memri/models/database/item_edge_record.dart';
import 'package:memri/models/database/item_property_record.dart';
import 'package:memri/models/database/item_record.dart';
import 'package:memri/models/view_context.dart';
import 'package:memri/utils/extensions/collection.dart';
import 'package:memri/utils/mock_generator.dart';
import 'package:moor/moor.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../models/plugin_config_json.dart';

abstract class CVUAction {
  execute(memri.PageController pageController, CVUContext context);

  Map<String, CVUValue> get defaultVars {
    return {};
  }

  late Map<String, CVUValue> vars;

  Future<String?> getString(String key, CVUContext context) async {
    var cvuValue = vars[key] ?? defaultVars[key];
    if (cvuValue is CVUValueConstant) {
      var cvuConstant = cvuValue.value;
      if (cvuConstant is CVUConstantString) {
        return cvuConstant.value;
      }
    }

    return null;
  }
}

/// Used to look up the concrete type matching a CVU action name
CVUAction Function({Map<String, CVUValue>? vars})? cvuAction(String named) {
  //TODO fix this when when Dart fixes passing constructors as callables https://github.com/dart-lang/language/issues/216
  switch (named.toLowerCase()) {
    case "back":
      return ({Map? vars}) => CVUActionNavigateBack(vars: vars);
    case "additem":
      return ({Map? vars}) => CVUActionAddItem(vars: vars);
    case "openview":
      return ({Map? vars}) => CVUActionOpenView(vars: vars);
    case "opencvueditor":
      return ({Map<String, CVUValue>? vars}) => CVUActionOpenCVUEditor(vars: vars);
    case "openlink":
      return ({Map? vars}) => CVUActionOpenLink(vars: vars);
    case "openviewbyname":
      return ({Map? vars}) => CVUActionOpenViewByName(vars: vars);
    case "toggleeditmode":
      return ({Map? vars}) => CVUActionToggleEditMode(vars: vars);
    case "togglefilterpanel":
      return ({Map? vars}) => CVUActionToggleFilterPanel(vars: vars);
    case "star":
      return ({Map? vars}) => CVUActionStar(vars: vars);
    case "showstarred":
      return ({Map? vars}) => CVUActionShowStarred(vars: vars);
    case "filter":
      return ({Map? vars}) => CVUActionFilter(vars: vars);
    case "showcontextpane":
      return ({Map? vars}) => CVUActionShowContextPane(vars: vars);
    case "shownavigation":
      return ({Map? vars}) => CVUActionShowNavigation(vars: vars);
    case "duplicate":
      return ({Map? vars}) => CVUActionDuplicate(vars: vars);
    case "schedule":
      return ({Map? vars}) => CVUActionSchedule(vars: vars);
    case "delete":
      return ({Map? vars}) => CVUActionDelete(vars: vars);
    case "showsessionswitcher":
      return ({Map? vars}) => CVUActionShowSessionSwitcher(vars: vars);
    case "forward":
      return ({Map? vars}) => CVUActionNavigateBack(vars: vars);
    case "forwardtofront":
      return ({Map? vars}) => CVUActionForwardToFront(vars: vars);
    case "backassession":
      return ({Map? vars}) => CVUActionBackAsSession(vars: vars);
    case "opensession":
      return ({Map? vars}) => CVUActionOpenSession(vars: vars);
    case "opensessionbyname":
      return ({Map? vars}) => CVUActionOpenSessionByName(vars: vars);
    case "closepopup":
      return ({Map? vars}) => CVUActionClosePopup(vars: vars);
    case "link":
      return ({Map? vars}) => CVUActionLink(vars: vars);
    case "unlink":
      return ({Map? vars}) => CVUActionUnlink(vars: vars);
    case "multiaction":
      return ({Map? vars}) => CVUActionMultiAction(vars: vars);
    case "runindexer":
      return ({Map? vars}) => CVUActionRunIndexer(vars: vars);
    case "pluginrun":
      return ({Map? vars}) => CVUActionPluginRun(vars: vars);
    case "openplugin":
      return ({Map? vars}) => CVUActionOpenPlugin(vars: vars);
    case "setproperty":
      return ({Map? vars}) => CVUActionSetProperty(vars: vars);
    case "setsetting":
      return ({Map? vars}) => CVUActionSetSetting(vars: vars);
    case "copytoclipboard":
      return ({Map? vars}) => CVUActionCopyToClipboard(vars: vars);
    case "noop":
      return ({Map? vars}) => CVUActionNoop(vars: vars);
    case "togglenavigation":
      return ({Map? vars}) => CVUActionToggleNavigation(vars: vars);
    case "togglefullscreen":
      return ({Map? vars}) => CVUActionToggleFullScreen(vars: vars);
    case "selectall":
      return ({Map? vars}) => CVUActionSelectAll(vars: vars);
    case "sync":
      return ({Map? vars}) => CVUActionSync(vars: vars);
    case "deselectall":
      return ({Map? vars}) => CVUActionDeselectAll(vars: vars);
    case "tonextitem":
      return ({Map? vars}) => CVUActionToNextItem(vars: vars);
    case "topreviousitem":
      return ({Map? vars}) => CVUActionToPreviousItem(vars: vars);
    case "requestcontacts":
      return ({Map? vars}) => CVUActionRequestContactsPermission(vars: vars);
    case "requestlocation":
      return ({Map? vars}) => CVUActionRequestLocationPermission(vars: vars);
    case "requeststorage":
      return ({Map? vars}) => CVUActionRequestStoragePermission(vars: vars);
    case "openpopup":
      return ({Map? vars}) => CVUActionOpenPopup(vars: vars);
    case "validate":
      return ({Map? vars}) => CVUActionValidate(vars: vars);
    case "wait":
      return ({Map? vars}) => CVUActionWait(vars: vars);
    case "block":
      return ({Map? vars}) => CVUActionBlock(vars: vars);
    case "createlabellingtask":
      return ({Map? vars}) => CVUActionCreateLabellingTask(vars: vars);
    case "parseplugin":
      return ({Map? vars}) => CVUActionParsePluginItem(vars: vars);
    case "generateplugincvu":
      return ({Map? vars}) => CVUActionGeneratePluginCvu(vars: vars);
    default:
      return null;
  }
}

class CVUActionShowStarred extends CVUAction {
  Map<String, CVUValue> vars;

  Map<String, CVUValue> get defaultVars {
    return {"icon": CVUValueConstant(CVUConstantString("star.fill"))};
  }

  CVUActionShowStarred({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    Map<String, CVUValue> newVars = {"inheritDatasource": CVUValueConstant(CVUConstantBool(true))};
    await CVUActionOpenView(
            vars: newVars,
            viewName: "filter-starred",
            renderer: context.rendererName,
            viewDefinition: context.viewDefinition)
        .execute(pageController, context);
  }
}

class CVUActionFilter extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionFilter({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    vars["inheritDatasource"] = CVUValueConstant(CVUConstantBool(false));
    var newDefinition = context.viewDefinition.clone();
    newDefinition.definitions
        .lastWhere((element) => element.type == CVUDefinitionType.datasource)
        .parsed = vars["datasource"]?.value;
    await CVUActionOpenView(
            vars: vars, renderer: context.rendererName, viewDefinition: newDefinition)
        .execute(pageController, context);
  }
}

class CVUActionOpenView extends CVUAction {
  Map<String, CVUValue> vars;

  String? viewName;
  String? renderer;
  Set<int>? uids;
  DateTimeRange? dateRange;
  CVUDefinitionContent? viewDefinition;

  CVUActionOpenView(
      {vars, this.viewName, this.renderer, this.uids, this.dateRange, this.viewDefinition})
      : this.vars = vars ?? {};

  @override
  Future execute(memri.PageController pageController, CVUContext context) async {
    var customDefinition = viewDefinition;
    if (customDefinition == null) {
      var view = vars["view"];
      if (view is CVUValueSubdefinition) {
        customDefinition = view.value;
      }
    }
    var viewArgs = vars["viewArguments"];

    var viewArguments = CVUViewArguments(
        args: viewArgs is CVUValueSubdefinition ? viewArgs.value.properties : null,
        argumentItem: context.currentItem,
        parentArguments: context.viewArguments);
    DatabaseController db = pageController.appController.databaseController;
    var resolver = CVUPropertyResolver(
        context: context, lookup: CVULookupController(), db: db, properties: vars);

    var sceneController = pageController.sceneController; //TODO
    memri.PageController? navigatePageController = pageController;

    if (viewArguments.args["pageLabel"] != null) {
      var lookup = CVULookupController();
      var pageLabel = await lookup.resolve<String>(
          value: viewArguments.args["pageLabel"], db: db, context: context);
      if (pageLabel != null) {
        while (pageLabel!.startsWith("~") && sceneController.parentSceneController != null) {
          sceneController = sceneController.parentSceneController!;
          pageLabel = pageLabel.substring(1);
        }

        navigatePageController = sceneController.pageControllerByLabel(pageLabel);

        if (navigatePageController == null &&
            pageLabel.isNotEmpty &&
            viewArguments.args["addPageIfMissing"] != null) {
          var addPageIfMissing = await lookup.resolve<bool>(
                  value: viewArguments.args["addPageIfMissing"], db: db, context: context) ??
              false;
          if (addPageIfMissing) {
            navigatePageController = await sceneController.addPageController(pageLabel);
          }
        }
      }
    }

    var cvuEditorPageController = sceneController.pageControllerByLabel("mainCVUEditor");
    if (cvuEditorPageController != null && viewName != "cvuEditor") {
      sceneController.removePageController(cvuEditorPageController);
    }

    await sceneController.navigateToNewContext(
        clearStack: await resolver.boolean("clearStack") ?? false,
        viewName: viewName ?? await resolver.string("viewName") ?? "customView",
        inheritDatasource: (await resolver.boolean("inheritDatasource", true))!,
        overrideRenderer: renderer ?? await resolver.string("renderer"),
        defaultRenderer: "singleItem",
        targetItem: (await resolver.item("item")) ?? context.currentItem,
        overrideRowIDs: uids,
        dateRange: dateRange,
        customDefinition: customDefinition,
        viewArguments: viewArguments,
        clearPageControllers: await resolver.boolean("clearPageControllers") ?? false,
        pageController: navigatePageController);
  }
}

class CVUActionOpenCVUEditor extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionOpenCVUEditor({Map<String, CVUValue>? vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    var label = "mainCVUEditor";
    var cvuEditorPageController = pageController.sceneController.pageControllerByLabel(label);

    var db = pageController.appController.databaseController;
    var resolver = CVUPropertyResolver(
        context: context, lookup: CVULookupController(), db: db, properties: vars);
    var forceOpen = (await resolver.boolean("forceOpen", false))!;

    if (cvuEditorPageController != null && !forceOpen) {
      pageController.sceneController.removePageController(cvuEditorPageController);
    } else {
      var newVars = Map.of(vars);
      var viewArguments = <String, CVUValue>{};
      if (newVars["viewArguments"] != null) {
        viewArguments =
            Map.of((newVars["viewArguments"] as CVUValueSubdefinition).value.properties);
      }
      newVars["viewArguments"] = CVUValueSubdefinition(CVUDefinitionContent(
          properties: viewArguments
            ..addAll({"clearStack": CVUValueConstant(CVUConstantBool(true))})));

      int pageControllersCount = pageController.sceneController.pageControllers.length;
      if (forceOpen && cvuEditorPageController != null) {
        pageController.sceneController.removePageController(cvuEditorPageController);
      }

      cvuEditorPageController = await pageController.sceneController.addPageController(label);
      int cols = (6 / pageControllersCount)
          .round(); //TODO will kinda sorta work for 1-3 page controllers, cols logic is tech debt for now
      pageController.sceneController.pageControllers.forEach(
          (currentPageController) => currentPageController.topMostContext?.config.cols = cols);

      await CVUActionOpenView(
        vars: newVars,
        viewName: "cvuEditor",
        renderer: "cvueditor",
      ).execute(cvuEditorPageController, context);
    }
  }
}

class CVUActionOpenLink extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionOpenLink({vars}) : this.vars = vars ?? {};

  @override
  Future execute(memri.PageController pageController, CVUContext context) async {
    var link = vars["link"];
    if (link != null) {
      var db = pageController.appController.databaseController;
      var resolver = CVUPropertyResolver(
          context: context, lookup: CVULookupController(), db: db, properties: vars);
      var url = await resolver.string("link");
      if (url != null) {
        await canLaunch(url) ? await launch(url) : AppLogger.err('Could not launch $url');
      }
    }
  }
}

class CVUActionOpenViewByName extends CVUAction {
  Map<String, CVUValue> vars;

  String? viewName;
  String? renderer;
  String? itemType;

  CVUActionOpenViewByName({vars, this.viewName, this.renderer, this.itemType})
      : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {}

  Future<ViewContextController?> getViewContext(
      CVUContext context, memri.PageController pageController,
      {CVUViewArguments? viewArguments} //TODO
      ) async {
    CVUDefinitionContent? customDefinition;
    var view = vars["view"];
    if (view is CVUValueSubdefinition) {
      customDefinition = view.value;
    }
    viewArguments ??=
        CVUViewArguments(args: view is CVUValueSubdefinition ? view.value.properties : null);
    viewArguments.argumentItem = context.currentItem;
    viewArguments.parentArguments = context.viewArguments;

    AppController appController = AppController.shared;
    var db = appController.databaseController;
    var resolver = CVUPropertyResolver(
        context: context, lookup: CVULookupController(), db: db, properties: vars);
    var viewName = this.viewName ?? await resolver.string("viewName") ?? "customView";
    var viewDefinition = appController.cvuController
            .viewDefinitionFor(viewName: viewName, customDefinition: customDefinition) ??
        CVUDefinitionContent();
    var newContext = CVUContext(
        currentItem: null,
        selector: null,
        viewName: viewName,
        viewDefinition: viewDefinition,
        viewArguments: viewArguments);

    var defaultRenderer = "list";
    var rendererName = await ((() async =>
        await viewDefinition
            .propertyResolver(
                context: newContext,
                lookup: CVULookupController(),
                db: appController.databaseController)
            .string("defaultRenderer") ??
        defaultRenderer))();

    var datasource = viewDefinition.definitions
        .firstWhereOrNull((definition) => definition.type == CVUDefinitionType.datasource);
    var queryConfig = await DatabaseQueryConfig.queryConfigWith(
        context: newContext, datasource: datasource, databaseController: db);

    if (itemType != null) {
      queryConfig.itemTypes = [itemType!];
    } else {
      var query = viewArguments.args["query"];
      if (query is CVUValueConstant) {
        var value = query.value;
        if (value is CVUConstantString) {
          queryConfig.itemTypes = [value.value];
        }
      }
    }

    var config = ViewContext(
        viewName: viewName,
        rendererName: rendererName,
        pageLabel: pageController.label,
        viewDefinition: viewDefinition,
        query: queryConfig,
        viewArguments: viewArguments,
        focusedItem: context.currentItem);
    var holder = ViewContextHolder(config);
    var newViewContext = ViewContextController(
        config: holder,
        databaseController: appController.databaseController,
        cvuController: appController.cvuController,
        pageController: pageController);

    return newViewContext;
  }
}

class CVUActionNavigateBack extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionNavigateBack({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    var db = pageController.appController.databaseController;
    var resolver = CVUPropertyResolver(
        context: context, lookup: CVULookupController(), db: db, properties: vars);
    var pageLabel = await resolver.string("pageLabel");
    if (pageLabel != null) {
      var sceneController = pageController.sceneController;
      while (pageLabel!.startsWith("~") && sceneController.parentSceneController != null) {
        sceneController = sceneController.parentSceneController!;
        pageLabel = pageLabel.substring(1);
      }

      pageController = sceneController.pageControllerByLabel(pageLabel) ?? pageController;
    }

    await pageController.navigateBack();
  }
}

class CVUActionCopyToClipboard extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionCopyToClipboard({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    var db = pageController.appController.databaseController;
    var resolver = CVUPropertyResolver(
        context: context, lookup: CVULookupController(), db: db, properties: vars);
    var value = await resolver.string("value");
    if (value != null) {
      if (value.toLowerCase().contains('key')) {
        if (value.contains('ownerKey')) {
          Clipboard.setData(
              ClipboardData(text: (await AppController.shared.podConnectionConfig)!.ownerKey));
        } else if (value.contains('databaseKey')) {
          Clipboard.setData(
              ClipboardData(text: (await AppController.shared.podConnectionConfig)!.databaseKey));
        }
      } else {
        Clipboard.setData(ClipboardData(text: value));
      }
    }
  }
}

class CVUActionAddItem extends CVUAction {
  Map<String, CVUValue> vars;

  Map<String, CVUValue> get defaultVars {
    return {"icon": CVUValueConstant(CVUConstantString("plus"))};
  }

  CVUActionAddItem({vars}) : this.vars = vars ?? {};

  @override
  Future execute(memri.PageController pageController, CVUContext context) async {
    var db = pageController.appController.databaseController;
    var resolver = CVUPropertyResolver(
        context: context, lookup: CVULookupController(), db: db, properties: vars);
    var template = resolver.subdefinition("template");
    if (template == null) {
      return;
    }
    var type = await template.string("_type");

    if (type != null) {
      var isNew = false;
      var item = await resolver.item("initialItem");
      if (item == null) {
        isNew = true;
        item = ItemRecord(type: type);
        try {
          await item.save(db.databasePool);
        } catch (error) {
          AppLogger.err("ERROR Adding item: " + error.toString());
        }
      }

      var itemRowId = item.rowId;
      if (itemRowId == null) {
        return;
      }

      /// Take all the properties defined in the template definition (in CVU) and map them against the schema. Resolve the CVU based on the type expected by the schema.

      for (var key in template.properties.keys.toList()) {
        var isReverse = false;
        ResolvedType? valueType = null;
        var cleanKey = key;
        if (key.startsWith("~")) {
          isReverse = true;
          cleanKey = key.substring(1);
          var source = await template.item(key);
          if (source == null) {
            continue;
          }
          valueType = db.schema.expectedType(source.type, cleanKey);
        } else {
          valueType = db.schema.expectedType(type, cleanKey);
        }
        if (valueType == null) {
          continue;
        }
        if (valueType is ResolvedTypeProperty) {
          var propertyType = valueType.value;
          var propertyDatabaseValue = await () async {
            switch (propertyType) {
              case SchemaValueType.string:
                var stringValue = await template.string(key);
                if (stringValue == null) {
                  return null;
                }
                return PropertyDatabaseValueString(stringValue);
              case SchemaValueType.bool:
                var boolValue = await template.boolean(key);
                if (boolValue == null) {
                  return null;
                }
                return PropertyDatabaseValueBool(boolValue);
              case SchemaValueType.int:
                var intValue = await template.integer(key);
                if (intValue == null) {
                  return null;
                }
                return PropertyDatabaseValueInt(intValue);
              case SchemaValueType.double:
                var doubleValue = await template.number(key);
                if (doubleValue == null) {
                  return null;
                }
                return PropertyDatabaseValueDouble(doubleValue);
              case SchemaValueType.datetime:
                var datetimeValue = await template.dateTime(key);
                if (datetimeValue == null) {
                  return null;
                }
                return PropertyDatabaseValueDatetime(datetimeValue);
              default:
                return null;
            }
          }();
          if (propertyDatabaseValue != null) {
            await ItemPropertyRecord(itemRowID: itemRowId, name: key, value: propertyDatabaseValue)
                .save(db.databasePool, isNew: isNew ? true : null);
          }
        } else if (valueType is ResolvedTypeEdge) {
          var targets = await template.items(isReverse ? key : cleanKey);
          var targetRowIDs = targets.compactMap((target) => target.rowId);
          if (targetRowIDs.isEmpty) continue;

          if (!isNew) {
            var existingEdges =
                isReverse ? await item.reverseEdges(cleanKey) : await item.edges(cleanKey);
            await Future.forEach<ItemEdgeRecord>(
                existingEdges,
                (edge) async =>
                    targetRowIDs.contains(isReverse ? edge.sourceRowID : edge.targetRowID)
                        ? targetRowIDs.remove(isReverse ? edge.sourceRowID! : edge.targetRowID!)
                        : await edge.delete(db));
          }
          for (var targetRowId in targetRowIDs) {
            await ItemEdgeRecord(
                    sourceRowID: isReverse ? targetRowId : itemRowId,
                    name: cleanKey,
                    targetRowID: isReverse ? itemRowId : targetRowId)
                .save();
          }
        }
      }

      var openNewView = await resolver.boolean("openNewView", true);
      if (openNewView!) {
        var renderer;
        var viewName = await resolver.string("viewName");
        if (viewName == null) {
          renderer = "generalEditor";
          var viewDefinition =
              AppController.shared.cvuController.viewDefinitionForItemRecord(itemRecord: item);
          if (viewDefinition == null) {
            return;
          }
          var defaultRenderer = viewDefinition.properties["defaultRenderer"];
          if (defaultRenderer is CVUValueConstant) {
            var defaultRendererValue = defaultRenderer.value;
            if (defaultRendererValue is CVUConstantArgument) {
              renderer = defaultRendererValue.value;
            }
          }
        }
        var newVars = Map.of(vars);
        if (newVars["viewArguments"] != null) {
          (newVars["viewArguments"] as CVUValueSubdefinition).value.properties.update(
              "readOnly", (value) => CVUValueConstant(CVUConstantBool(false)),
              ifAbsent: () => CVUValueConstant(CVUConstantBool(false)));
        } else {
          newVars["viewArguments"] = CVUValueSubdefinition(CVUDefinitionContent(properties: {
            "readOnly": CVUValueConstant(CVUConstantBool(false)),
          }));
        }

        await CVUActionOpenView(viewName: viewName, vars: newVars, renderer: renderer)
            .execute(pageController, context.replacingItem(item));
      }

      pageController.scheduleUIUpdate();
    }
  }
}

class CVUActionOpenPlugin extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionOpenPlugin({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    var lookup = CVULookupController();
    var db = pageController.appController.databaseController;

    var pluginValue = vars["plugin"];
    var pluginNameValue = vars["pluginName"];

    if (pluginValue == null && pluginNameValue == null) {
      AppLogger.warn("Plugin data missing");
      return;
    }
    String? pluginName;
    ItemRecord? plugin;
    if (pluginValue != null) {
      plugin = await lookup.resolve<ItemRecord>(value: pluginValue, context: context, db: db);
    }
    if (plugin == null) {
      pluginName = await lookup.resolve<String>(value: pluginNameValue, context: context, db: db);
      if (pluginName == null) {
        AppLogger.warn("Plugin data missing");
        return;
      }

      var pluginItems = await db.databasePool.itemPropertyRecordsCustomSelect(
          "name = ? AND value = ?", [Variable("pluginName"), Variable(pluginName)]);
      if (pluginItems.isNotEmpty) {
        plugin = await ItemRecord.fetchWithRowID(pluginItems[0].item);
      }
    }

    if (plugin == null) {
      AppLogger.warn("Plugin data missing");
      return;
    }
    if (pluginName == null) {
      pluginName = (await plugin.property("pluginName", db))!.$value.value;
    }

    List<ItemRecord> pluginRunList =
        await plugin.reverseEdgeItems("plugin", db: db, sourceItemType: "PluginRun");
    pluginRunList.sort((a, b) => b.rowId! - a.rowId!);

    var lastPluginRun = pluginRunList.asMap()[0];
    var account;
    String viewName;
    if (lastPluginRun == null) {
      viewName = "${pluginName}Run";
    } else {
      var status = (await lastPluginRun.property("status", db))!.$value.value;
      switch (status) {
        case "userActionNeeded":
        case "cvuPresented":
          account = await lastPluginRun.edgeItem("account");
          viewName = "${pluginName}-userActionNeeded";
          break;
        case "idle":
        case "ready":
          viewName = "pluginRunWait";
          break;
        case "done":
        case "daemon":
          viewName = "pluginShortInfo";
          break;
        default:
          viewName = "${pluginName}Run";
          break;
      }
    }

    await CVUActionOpenView(vars: vars, viewName: viewName)
        .execute(pageController, context.replacingItem(account ?? plugin));
  }
}

class CVUActionPluginRun extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionPluginRun({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    var lookup = CVULookupController();
    var db = pageController.appController.databaseController;

    var pluginIdValue = vars["pluginId"];
    var pluginModuleValue = vars["pluginModule"];
    var pluginNameValue = vars["pluginName"];
    var containerValue = vars["container"];
    if (pluginIdValue == null ||
        containerValue == null ||
        pluginModuleValue == null ||
        pluginNameValue == null) {
      AppLogger.warn("Not all params provided for PluginRun");
      return;
    }
    var configValue = vars["config"];

    String? pluginId = await lookup.resolve<String>(value: pluginIdValue, context: context, db: db);

    String? container =
        await lookup.resolve<String>(value: containerValue, context: context, db: db);
    if (container == null) return;

    ItemRecord plugin = (await ItemRecord.fetchWithUID(pluginId!, db))!;

    String? pluginModule =
        await lookup.resolve<String>(value: pluginModuleValue, context: context, db: db) ?? "";
    String? pluginName =
        await lookup.resolve<String>(value: pluginNameValue, context: context, db: db) ?? "";
    String? config;
    if (configValue != null) {
      config = await lookup.resolve<String>(value: configValue, context: context, db: db) ?? "";
    }
    try {
      var pluginRunItem = ItemRecord(type: "PluginRun");
      var propertyRecords = [
        ItemPropertyRecord(
            name: "targetItemId", value: PropertyDatabaseValueString(pluginRunItem.uid)),
        ItemPropertyRecord(name: "pluginModule", value: PropertyDatabaseValueString(pluginModule)),
        ItemPropertyRecord(name: "pluginName", value: PropertyDatabaseValueString(pluginName)),
        ItemPropertyRecord(name: "containerImage", value: PropertyDatabaseValueString(container)),
        ItemPropertyRecord(name: "status", value: PropertyDatabaseValueString("idle")),
      ];

      if (config != null) {
        propertyRecords
            .add(ItemPropertyRecord(name: "config", value: PropertyDatabaseValueString(config)));
      }

      await pluginRunItem.save();
      await pluginRunItem.addEdge(edgeName: "plugin", targetItem: plugin);
      await pluginRunItem.setPropertyValueList(propertyRecords, db: db);

      await PluginHandler.run(
          plugin: plugin, runner: pluginRunItem, pageController: pageController, context: context);
    } catch (error) {
      AppLogger.err("Error starting plugin: $error");
    }
  }
}

class CVUActionSync extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionSync({vars}) : this.vars = vars ?? {};

  @override
  void execute(memri.PageController pageController, CVUContext context) async {
    try {
      var pendingItems = <ItemRecord>[];
      var pendingEdges = <ItemEdgeRecord>[];

      var item = context.currentItem;

      if (item != null) {
        if (item.syncState == SyncState.skip) {
          item.syncState = SyncState.create;
          pendingItems.add(item);
        }

        var edges = await item.edges(null) + await item.reverseEdges(null);

        for (var edge in edges) {
          if (edge.syncState == SyncState.skip) {
            edge.syncState = SyncState.create;
            pendingEdges.add(edge);
          }
        }

        var edgeItems = await item.edgeItems(null) + await item.reverseEdgeItems(null);

        for (var edgeItem in edgeItems) {
          if (edgeItem.syncState == SyncState.skip) {
            edgeItem.syncState = SyncState.create;
            pendingItems.add(edgeItem);
          }
        }
      }

      for (var edge in pendingEdges) {
        var selfEdge = await edge.selfItem();
        if (selfEdge.syncState == SyncState.skip) {
          selfEdge.syncState = SyncState.create;
          pendingItems.add(selfEdge);
        }

        await edge.save();
      }

      for (var item in pendingItems) {
        await item.save();
      }

      pageController.isInEditMode.value = false;
    } catch (error) {
      AppLogger.err("Error starting sync: $error");
    }
  }
}

class CVUActionToggleEditMode extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionToggleEditMode({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    pageController.toggleEditMode();
  }
}

class CVUActionToggleNavigation extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionToggleNavigation({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    // TODO: implement execute
  }
}

class CVUActionToggleFullScreen extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionToggleFullScreen({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    // TODO: implement execute
  }
}

class CVUActionDelete extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionDelete({vars}) : this.vars = vars ?? {};

  Map<String, CVUValue> get defaultVars {
    return {"title": CVUValueConstant(CVUConstantString("Delete"))};
  }

  @override
  Future<void> execute(memri.PageController pageController, CVUContext context) async {
    var lookup = CVULookupController();
    var db = pageController.appController.databaseController;

    ItemRecord? subjectItem;
    var subjectVal = vars["subject"];
    if (subjectVal != null) {
      subjectItem = await lookup.resolve<ItemRecord>(value: subjectVal, context: context, db: db);
    }
    subjectItem ??= context.currentItem;
    if (subjectItem == null) {
      AppLogger.warn("No subject item for property " + (subjectVal?.value?.toString() ?? ""));
      return;
    }

    await subjectItem.delete(pageController.appController.databaseController);

    var closeVal = vars["close"];
    if (closeVal != null) {
      var lookup = CVULookupController();
      var db = pageController.appController.databaseController;

      bool shouldClose = (await lookup.resolve<bool>(value: closeVal, context: context, db: db))!;
      if (shouldClose) {
        pageController.navigateBack();
      }
    }
    pageController.scheduleUIUpdate();
  }
}

class CVUActionSelectAll extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionSelectAll({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    // TODO: implement execute
  }
}

class CVUActionDeselectAll extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionDeselectAll({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    // TODO: implement execute
  }
}

class CVUActionLink extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionLink({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    var lookup = CVULookupController();
    var db = pageController.appController.databaseController;

    var currentItem = context.currentItem;
    var resolver = CVUPropertyResolver(context: context, lookup: lookup, db: db, properties: vars);
    List<ItemRecord?> subjectItems = await resolver.items("subject");
    if (subjectItems.isEmpty) return;

    String? edgeType = await resolver.string("edgeType");
    if (currentItem == null || edgeType == null) {
      return;
    }

    bool unique = (await resolver.boolean("distinct", false))!;
    bool removePrevious = (await resolver.boolean("removePrevious", false))!;

    var subjectRowIDs = subjectItems.compactMap((target) => target?.rowId);
    if (subjectRowIDs.isEmpty) return;

    var isReverse = false;
    var cleanKey = edgeType;
    if (edgeType.startsWith("~")) {
      isReverse = true;
      cleanKey = edgeType.substring(1);
    }

    if (unique) {
      var edges = await subjectItems[0]!.edges(edgeType); //TODO: logic for many edges
      for (ItemEdgeRecord currentEdge in edges) {
        if (currentEdge.name == edgeType) {
          var result = await currentEdge.delete();
          if (result != true) {
            AppLogger.err(
                "ERROR CVUAction_link: item: ${subjectItems[0]!.type} with id: ${subjectItems[0]!.rowId} edge id: ${currentEdge.selfRowID}");
            return;
          }
        }
      }
    } else if (removePrevious) {
      var existingEdges =
          isReverse ? await currentItem.edges(cleanKey) : await currentItem.reverseEdges(cleanKey);
      await Future.forEach<ItemEdgeRecord>(
          existingEdges,
          (edge) async => subjectRowIDs.contains(isReverse ? edge.targetRowID : edge.sourceRowID)
              ? subjectRowIDs.remove(isReverse ? edge.targetRowID! : edge.sourceRowID!)
              : await edge.delete(db));

      if (subjectRowIDs.isEmpty) return;
    }

    for (var itemRowId in subjectRowIDs) {
      await ItemEdgeRecord(
              sourceRowID: isReverse ? currentItem.rowId : itemRowId,
              name: cleanKey,
              targetRowID: isReverse ? itemRowId : currentItem.rowId)
          .save(db.databasePool);
    }
  }
}

class CVUActionUnlink extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionUnlink({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    var lookup = CVULookupController();
    var db = pageController.appController.databaseController;

    var currentItem = context.currentItem;
    var subjectVal = vars["subject"];
    ItemRecord subjectItem =
        (await lookup.resolve<ItemRecord>(value: subjectVal, context: context, db: db))!;
    var edgeTypeVal = vars["edgeType"];
    String? edgeType = await lookup.resolve<String>(value: edgeTypeVal, context: context, db: db);
    if (currentItem == null || subjectVal == null || edgeTypeVal == null || edgeType == null) {
      return;
    }

    ItemEdgeRecord? edge;
    var edges = await subjectItem.edges(edgeType);
    for (ItemEdgeRecord currentEdge in edges) {
      if (currentEdge.sourceRowID == subjectItem.rowId &&
          currentEdge.targetRowID == currentItem.rowId &&
          currentEdge.name == edgeType) {
        edge = currentEdge;
        break;
      }
    }

    if (edge == null) {
      return;
    }

    var result = await edge.delete();
    if (result != true) {
      AppLogger.err(
          "ERROR CVUAction_Unlink: item: ${subjectItem.type} with id: ${subjectItem.rowId} edge id: ${edge.selfRowID}");
      return;
    }

    pageController.scheduleUIUpdate();
  }
}

class CVUActionStar extends CVUAction {
  Map<String, CVUValue> vars;

  @override
  Future<String?> getString(String key, CVUContext context) async {
    var lexer = CVUExpressionLexer('.starred ? "Unpin" : "Pin"');
    var tokens = lexer.tokenize();
    var parser = CVUExpressionParser(tokens);
    var node = parser.parse();

    return await CVULookupController().resolve<String>(
        expression: node, context: context, db: AppController.shared.databaseController);
  }

  CVUActionStar({vars}) : this.vars = vars ?? {};

  @override
  Future execute(memri.PageController pageController, CVUContext context) async {
    var currentItem = context.currentItem;
    if (currentItem == null) {
      return;
    }

    var prop = "starred";
    var currentVal = (await currentItem.propertyValue(prop))?.asBool() ?? false;
    try {
      await currentItem.setPropertyValue(prop, PropertyDatabaseValueBool(!currentVal));
    } catch (error) {
      AppLogger.err(
          "ERROR CVUAction_Star: item: ${currentItem.type} with id: ${currentItem.rowId} error: $error");
    }
  }
}

class CVUActionClosePopup extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionClosePopup({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    pageController.closeLastInStack();
  }
}

class CVUActionToggleFilterPanel extends CVUAction {
  Map<String, CVUValue> vars;

  Map<String, CVUValue> get defaultVars {
    return {"icon": CVUValueConstant(CVUConstantString("rhombus.fill"))};
  }

  CVUActionToggleFilterPanel({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    pageController.sceneController.filterPanelIsVisible.value =
        !pageController.sceneController.filterPanelIsVisible.value;
  }
}

class CVUActionOpenGroup extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionOpenGroup({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionShowContextPane extends CVUAction {
  Map<String, CVUValue> vars;

  Map<String, CVUValue> get defaultVars {
    return {"icon": CVUValueConstant(CVUConstantString("ellipsis"))};
  }

  CVUActionShowContextPane({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionShowNavigation extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionShowNavigation({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionDuplicate extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionDuplicate({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionSchedule extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionSchedule({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionShowSessionSwitcher extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionShowSessionSwitcher({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionForwardToFront extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionForwardToFront({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionBackAsSession extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionBackAsSession({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionOpenSession extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionOpenSession({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionOpenSessionByName extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionOpenSessionByName({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionMultiAction extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionMultiAction({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionRunIndexer extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionRunIndexer({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionSetProperty extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionSetProperty({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    var lookup = CVULookupController();
    var db = pageController.appController.databaseController;
    var schema = db.schema;

    var subjectVal = vars["subject"];
    ItemRecord? subjectItem =
        await lookup.resolve<ItemRecord>(value: subjectVal, context: context, db: db);
    if (subjectItem == null) {
      AppLogger.warn("No subject item for property " + subjectVal?.value);
      return;
    }
    String? property;
    var propertyValue = vars["property"];
    if (propertyValue is CVUValueConstant) {
      var propertyName = propertyValue.value;
      if (propertyName is CVUConstantString) {
        property = propertyName.value;
      }
    }
    if (property == null) return;

    SchemaValueType? expectedType = schema.expectedPropertyType(subjectItem.type, property);
    CVUValue? value = vars["value"];

    if (expectedType == null || value == null) return;
    var databaseValue = await PropertyDatabaseValue.createFromCVUValue(
        cvuValue: value, propertyType: expectedType, context: context, db: db);
    if (databaseValue == null) return;
    await subjectItem.setPropertyValue(property, databaseValue);

    pageController.topMostContext
        ?.setupQueryObservation(); //TODO this is workaround: should delete as soon as db streams are implemented correctly
    pageController.scheduleUIUpdate();
  }
}

class CVUActionSetSetting extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionSetSetting({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionToNextItem extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionToNextItem({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    if (pageController.topMostContext == null) {
      return;
    }
    var index = pageController.topMostContext!.focusedIndex;
    pageController.topMostContext?.focusedIndex =
        index >= pageController.topMostContext!.items.length - 1 ? 0 : index + 1;
    pageController.scheduleUIUpdate();
  }
}

class CVUActionToPreviousItem extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionToPreviousItem({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    if (pageController.topMostContext == null) {
      return;
    }
    var index = pageController.topMostContext!.focusedIndex;
    pageController.topMostContext?.focusedIndex =
        index <= 0 ? pageController.topMostContext!.items.length - 1 : index - 1;
    pageController.scheduleUIUpdate();
  }
}

class CVUActionNoop extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionNoop({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionRequestContactsPermission extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionRequestContactsPermission({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    await pageController.appController.permissionController.requestContacts();
  }
}

class CVUActionRequestLocationPermission extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionRequestLocationPermission({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    await pageController.appController.permissionController.requestLocation();
  }
}

class CVUActionRequestStoragePermission extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionRequestStoragePermission({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    await pageController.appController.permissionController.requestStorage();
  }
}

class CVUActionOpenPopup extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionOpenPopup({vars}) : this.vars = vars ?? {};

  Future<Map<String, dynamic>?> setPopupSettings(
      memri.PageController pageController, CVUContext context) async {
    var lookup = CVULookupController();
    var db = pageController.appController.databaseController;

    var titleProp = vars["title"];
    var textProp = vars["text"];
    if (titleProp == null || textProp == null) return null;

    String? title = await lookup.resolve<String>(value: titleProp, context: context, db: db);
    String? text = await lookup.resolve<String>(value: textProp, context: context, db: db);
    if (title == null || text == null) return null;
    var resolver =
        CVUPropertyResolver(context: context, lookup: lookup, db: db, properties: this.vars);
    var resolvedActions = resolver.actions("actions");
    return {"title": title, "text": text, "actions": resolvedActions};
  }

  @override
  execute(memri.PageController pageController, CVUContext context) async {}
}

class CVUActionValidate extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionValidate({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    var db = pageController.appController.databaseController;
    var resolver = CVUPropertyResolver(
        context: context, lookup: CVULookupController(), db: db, properties: vars);

    var rules = resolver.subdefinitionArray("rules");

    for (var rule in rules) {
      var exp = (await rule.boolean("expression", false, true))!;
      if (!exp) {
        var error =
            await rule.string("error") ?? "Error on ${rule.properties["expression"].toString()}";
        throw error;
      }
    }
  }
}

class CVUActionWait extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionWait({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    var seconds = vars["seconds"];

    if (seconds != null && seconds is CVUValueConstant && seconds.value is CVUConstantNumber) {
      await Future.delayed(Duration(seconds: (seconds.value.value as num).toInt()), () {});
    }
  }
}

class CVUActionBlock extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionBlock({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    var lookup = CVULookupController();
    var appController = pageController.appController;
    var db = appController.databaseController;
    var pageLabelProp = vars["pageLabel"];
    if (pageLabelProp == null) return null;

    String? pageLabel =
        await lookup.resolve<String>(value: pageLabelProp, context: context, db: db);
    if (pageLabel == null) {
      return;
    }
    if (appController.storage.containsKey(pageLabel)) {
      appController.storage[pageLabel]["isBlocked"] = ValueNotifier(true);
    } else {
      appController.storage.addEntries([
        MapEntry(pageLabel, {"isBlocked": ValueNotifier(true)})
      ]);
    }

    var seconds = vars["seconds"];

    if (seconds != null && seconds is CVUValueConstant && seconds.value is CVUConstantNumber) {
      Future.delayed(Duration(seconds: (seconds.value.value as num).toInt()), () {
        if (appController.storage.containsKey(pageLabel)) {
          (appController.storage[pageLabel]["isBlocked"] as ValueNotifier).value = false;
        }
      });
    }
  }
}

class CVUActionCreateLabellingTask extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionCreateLabellingTask({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    var lookup = CVULookupController();
    var db = pageController.appController.databaseController;
    var resolver = CVUPropertyResolver(context: context, lookup: lookup, db: db, properties: vars);
    var template = resolver.subdefinition("template");
    if (template == null) {
      return;
    }
    var dataset = await resolver.item("dataset");
    if (dataset == null) {
      AppLogger.warn("CreateLabellingTask error: dataset not resolved");
      return;
    }
    var datasetType = await dataset.edgeItem("datasetType", db: db);
    if (datasetType == null) {
      AppLogger.warn("CreateLabellingTask error: dataset type not resolved");
      return;
    }
    var query = (await datasetType.propertyValue("queryStr"))?.asString();
    if (query == null) {
      AppLogger.warn("CreateLabellingTask error: couldn't find query from dataset type");
      return;
    }
    var decodedQuery = jsonDecode(query);
    var itemType = decodedQuery["type"];
    if (itemType == null) {
      return;
    }
    var filterQuery = Map.of(decodedQuery);
    filterQuery.remove('type');
    List<DatabaseQueryConditionPropertyEquals> properties = [];
    filterQuery.forEach((key, value) {
      properties.add(DatabaseQueryConditionPropertyEquals(PropertyEquals(key, value)));
    });

    var databaseQueryConfig =
        DatabaseQueryConfig(itemTypes: [itemType], pageSize: 500, conditions: properties);
    databaseQueryConfig.dbController = db;
    var datasetEntries = <ItemRecord>[];
    var edgesFromFilteredItems = (await databaseQueryConfig.constructFilteredRequest())
        .map((item) {
          var datasetEntry = ItemRecord(type: "DatasetEntry");
          datasetEntries.add(datasetEntry);

          return [
            ItemEdgeRecord(name: "entry", sourceRowID: dataset.rowId, targetUID: datasetEntry.uid),
            ItemEdgeRecord(name: "data", sourceUID: datasetEntry.uid, targetRowID: item.rowId)
          ];
        })
        .expand((element) => element)
        .toList();

    await ItemRecord.insertList(datasetEntries, db: db.databasePool);
    await ItemEdgeRecord.insertList(edgesFromFilteredItems, db: db.databasePool);

    List<ItemRecord> featureItems = await resolver.items("features");
    var cvu =
        '.labellingAnnotation${Uuid().v4()} { \n ${itemType} > labelAnnotation {\n VStack {\n alignment: left\n padding: 30\n spacing: 5\n';
    for (var feature in featureItems) {
      var propertyName = (await feature.propertyValue("propertyName", db))?.value;
      if (propertyName != null) {
        if (itemType == "EmailMessage" && propertyName == "content") {
          cvu += '\nHTMLView {\n maxHeight: 400\n content: {{.content}}\n}';
        } else {
          cvu += '\nText {\n text: "{.${propertyName}}"\n font: headline1 \n}';
        }
      }
    }
    cvu += '\n}\n}\n}';
    var cvuID = await CVUController.storeDefinition(db, cvuString: cvu);
    if (cvuID == null) {
      AppLogger.warn("CreateLabellingTask error: definition haven't saved");
      return;
    }
    var newVars = Map.of(vars);
    newVars["template"] =
        CVUValueSubdefinition((vars["template"] as CVUValueSubdefinition).value.clone());
    (newVars["template"] as CVUValueSubdefinition)
        .value
        .properties
        .update("view", (value) => CVUValueItem(cvuID), ifAbsent: () => CVUValueItem(cvuID));
    await CVUActionAddItem(vars: newVars).execute(pageController, context);
  }
}

class CVUActionParsePluginItem extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionParsePluginItem({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    var lookup = CVULookupController();
    var db = pageController.appController.databaseController;
    var resolver = CVUPropertyResolver(context: context, lookup: lookup, db: db, properties: vars);
    var project = await resolver.item("project");
    if (project == null) {
      throw "Labelling project is not exist!";
    }

    var url = await resolver.string("url");
    if (url == null) {
      throw "Repository URL is not provided!";
    }
    if (!url.startsWith("https://gitlab.memri.io/")) {
      throw "Repository URL should lead to gitlab.memri.io project";
    }
    Uri? uri = Uri.tryParse(url + "/-/raw/main/metadata.json");
    if (uri == null || !uri.hasAbsolutePath) {
      throw "Url is not valid";
    }

    //TODO: for future we need to save branch
    var searchNeedle =
        url.replaceFirst("https://gitlab.memri.io/", "").replaceFirst(RegExp(r"\/\-\/tree.*$"), "");
    var newUri = Uri.tryParse(
        "https://gitlab.memri.io/api/v4/projects?search=$searchNeedle&search_namespaces=true");
    if (newUri == null || !newUri.hasAbsolutePath) {
      throw "Url is not valid";
    }

    var response = await http.get(newUri, headers: {"content-type": "application/json"});
    if (response.statusCode != 200) {
      throw "ERROR: ${response.statusCode} ${response.reasonPhrase}";
    }
    var repoJson = Utf8Decoder().convert(response.bodyBytes);
    var decodedRepo = jsonDecode(repoJson);
    if (decodedRepo.length == 0 || decodedRepo[0]["id"] == null) {
      throw "Gitlab project id not provided";
    }
    var gitProjectId = decodedRepo[0]["id"];
    if (gitProjectId is! int) {
      throw "Git Project Id has wrong type";
    }

    await createPlugin(gitProjectId: gitProjectId, db: db, project: project);
  }

  createPlugin(
      {required int gitProjectId,
      required DatabaseController db,
      required ItemRecord project}) async {
    var encodedPlugin = await GitlabApi.getTextFileContentFromGitlab(
        gitProjectId: gitProjectId, filename: "metadata.json");
    var decodedPlugin = jsonDecode(encodedPlugin);

    var pluginItem = ItemRecord(type: "Plugin");
    await pluginItem.save(db.databasePool);
    var pluginProperties = Map.of(decodedPlugin);
    List<ItemPropertyRecord> properties = [];
    pluginProperties.forEach((key, value) {
      if (value != null) {
        if (key == "description")
          key = "pluginDescription"; //TODO: change this after param in pyMemri will be changed
        properties.add(ItemPropertyRecord(name: key, value: PropertyDatabaseValueString(value)));
      }
    });

    var encodedConfig = await GitlabApi.downloadSingleArtifact(
        gitProjectId: gitProjectId, filename: "config.json", jobName: "create_config");
    properties.add(
        ItemPropertyRecord(name: "configJson", value: PropertyDatabaseValueString(encodedConfig)));
    var configJsonList =
        (jsonDecode(encodedConfig) as List).map((json) => PluginConfigJson.fromJson(json)).toList();
    Map<String, dynamic> configData = {};
    for (var configItem in configJsonList) {
      if (configItem.defaultData != null && configItem.defaultData != "") {
        configData.addEntries([MapEntry(configItem.name, configItem.defaultData)]);
      }
    }
    configData["isMock"] ??= true;
    properties.add(ItemPropertyRecord(
        name: "config", value: PropertyDatabaseValueString(jsonEncode(configData))));
    properties.add(
        ItemPropertyRecord(name: "gitProjectId", value: PropertyDatabaseValueInt(gitProjectId)));

    await project.addEdge(edgeName: "labellingPlugin", targetItem: pluginItem);
    await pluginItem.setPropertyValueList(properties, db: db);
  }

  //TODO: this part is not used now, we will need it on next iterations
  parsePluginSchema({required int gitProjectId, required DatabaseController db}) async {
    var encodedSchema = await GitlabApi.getTextFileContentFromGitlab(
        gitProjectId: gitProjectId, filename: "schema.json");
    var decodedSchema = jsonDecode(encodedSchema);
    if (decodedSchema is! List) {
      throw "Schema is invalid";
    }
    List<ItemPropertyRecord> properties = [];
    for (var el in decodedSchema) {
      properties = [];
      var type = el["type"];
      if (type != null && type is String) {
        if (type == "ItemPropertySchema") {
          var itemType = el["itemType"];
          var propertyName = el["propertyName"];
          var propertyValue = ItemRecord.reverseMapSchemaValueType(el["valueType"]);
          if (itemType is String && propertyName is String && propertyValue is String) {
            var record = ItemRecord(type: "ItemPropertySchema");
            await record.save(db.databasePool);
            properties.addAll([
              ItemPropertyRecord(name: "itemType", value: PropertyDatabaseValueString(itemType)),
              ItemPropertyRecord(
                  name: "propertyName", value: PropertyDatabaseValueString(propertyName)),
              ItemPropertyRecord(
                  name: "valueType", value: PropertyDatabaseValueString(propertyValue)),
            ]);

            await record.setPropertyValueList(properties);
          }
        } else {
          if (type == "ItemEdgeSchema") {
            var sourceType = el["sourceType"];
            var edgeName = el["edgeName"];
            var targetType = el["targetType"];
            if (sourceType is String && edgeName is String && targetType is String) {
              var record = ItemRecord(type: "ItemEdgeSchema");
              await record.save(db.databasePool);
              properties.addAll([
                ItemPropertyRecord(
                    name: "sourceType", value: PropertyDatabaseValueString(sourceType)),
                ItemPropertyRecord(name: "edgeName", value: PropertyDatabaseValueString(edgeName)),
                ItemPropertyRecord(
                    name: "targetType", value: PropertyDatabaseValueString(targetType)),
              ]);

              await record.setPropertyValueList(properties);
            }
          }
        }
      }
    }
    await db.schema.load(db.databasePool);
  }
}

class CVUActionGeneratePluginCvu extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionGeneratePluginCvu({vars}) : this.vars = vars ?? {};

  @override
  execute(memri.PageController pageController, CVUContext context) async {
    var lookup = CVULookupController();
    var db = pageController.appController.databaseController;
    var resolver = CVUPropertyResolver(context: context, lookup: lookup, db: db, properties: vars);
    var plugin = await resolver.item("plugin");
    if (plugin == null) {
      throw "Couldn't find plugin item in database";
    }
    var queryStr = await resolver.string("query");
    if (queryStr == null) {
      throw "Project couldn't receive query from dataset";
    }

    var decodedQuery = jsonDecode(queryStr);
    if (decodedQuery == null || decodedQuery["type"] == null) {
      throw "Dataset doesn't have type property";
    }
    var filterProperties = Map.of(decodedQuery);

    List<ItemRecord> featureItems = await resolver.items("features");

    var forceUpdate = (await resolver.boolean("forceUpdate", false))!;

    var cvuRowId = await generatePluginCvu(
        filterProperties: filterProperties,
        features: featureItems,
        db: db,
        forceUpdate: forceUpdate,
        cvuController: pageController.topMostContext!.cvuController,
        pluginUID: plugin.uid);
    if (!forceUpdate) {
      var viewEdge = ItemEdgeRecord(name: "view", sourceRowID: plugin.rowId, targetRowID: cvuRowId);
      await viewEdge.save(db.databasePool);
    }
  }

  Future<int?> generatePluginCvu(
      {required Map<dynamic, dynamic> filterProperties,
      required List<ItemRecord> features,
      required DatabaseController db,
      required bool forceUpdate,
      required CVUController cvuController,
      required String pluginUID}) async {
    var startItemType = Map.of(filterProperties)["type"];
    filterProperties.remove('type');
    var propertiesFilter = "";
    Map<dynamic, dynamic> properties = {};
    List<DatabaseQueryConditionPropertyEquals> queryProperties = [];

    if (filterProperties.isNotEmpty) {
      propertiesFilter += "filter: {\n properties: {\n";
      filterProperties.forEach((key, value) {
        propertiesFilter += '$key: "$value"\n';
        properties.addEntries({MapEntry(key, value)});
        queryProperties.add(DatabaseQueryConditionPropertyEquals(PropertyEquals(key, value)));
      });
      propertiesFilter += '\nisMock: {{isMock}}\n';
      propertiesFilter += "}}";
    }

    var cvu = '''.dataPlugin$pluginUID { 
        defaultRenderer: singleItem
        cols: 6
        [renderer = singleItem] {
          scrollable: false
        }
        
        [datasource = pod] {
            query: Plugin
        }
    Plugin > singleItem {
    viewArguments: {
      currentPlugin: {{.}}
    }    
    VStack {
        alignment: topleft
        padding: 60 30 30 30

        Text {
            font: "headline2"
            text: {{.name}}
        }

        HStack {
            background: #1AE9500F

            VStack {
                alignment: left
                padding: 30 20 45 20

                Text {
                    font: bodyText1
                    padding: 0 0 25 0
                    text: "Customize and preview your app using the CVU renderer on the right."
                }

                Button {
                    isLink: true
                    onPress: [
                        openLink
                        {
                            link: "https://memri.docs.memri.io/docs.memri.io/component-architectures/frontend/cvu-intro/"
                        }
                    ]

                    Text {
                        color: #E9500F
                        font: link
                        text: "Read our CVU guide"
                    }

                    Image {
                        alignment: center
                        bundleImage: "ico_arrow"
                        color: #E9500F
                        isVector: true
                        padding: 0 0 0 15
                    }
                }

                Button {
                    isLink: true
                    onPress: [
                        openLink
                        {
                            link: "https://memri.docs.memri.io/docs.memri.io/component-architectures/frontend/cvu-ui-elements/"
                        }
                    ]

                    Text {
                        color: #E9500F
                        font: link
                        text: "See the full list of available CVU components"
                    }

                    Image {
                        alignment: center
                        bundleImage: "ico_arrow"
                        color: #E9500F
                        isVector: true
                        padding: 0 0 0 15
                    }
                }
            }

            Spacer
        }

        VStack {
            alignment: topleft
            background: #F6F6F6
            padding: 20

            Text {
                color: #999999
                font: smallCaps
                text: "USED DEFINED ATTRIBUTES:"
            }
            
            FlowStack {
                list: {{.~labellingPlugin.dataset.feature[]}}
                spacing: 4

                Wrap {
                    background: #fff

                    Text {
                        color: #999999
                        font: tabList
                        padding: 12 10 12 10
                        text: "{.propertyName}"
                    }
                }
            }

            Text {
                color: #999999
                font: smallCaps
                padding: 30 0 0 0
                text: "EXAMPLE ITEMS:"
            }

            SubView {
                height: 200
                view: {
                    defaultRenderer: list
                    editMode: false
                    viewArguments: {
                        currentPlugin: {{currentPlugin}}
                        isMock: {{currentPlugin.config.fromJson("isMock")}}
                    }

                    [datasource = pod] {
                        query: $startItemType
                        $propertiesFilter
                    }

                    [renderer = list] {
                        edgeInset: 0
                        hideSeparators: true
                        spacing: 0
                    }

                    $startItemType > list {
                        VStack {
                            alignment: left

                            RichText {
                                font: bodyText1
                                spans: [''';

    for (var feature in features) {
      var propertyName = (await feature.propertyValue("propertyName", db))?.value;
      if (propertyName != null) {
        cvu += '\n {\n text: "{.${propertyName}} " \n}';
        if (!properties.containsKey(propertyName)) {
          properties.addEntries({MapEntry(propertyName, null)});
        }
      }
    }

    //TODO: hard-coded part for labels
    cvu += '\n{ \n text: " - {.label.value OR \'Place for your label\'}" \n }';

    cvu += '\n]\n}\n}\n}\n}\n}\n}\n}\n}\n}';

    if (forceUpdate) {
      await cvuController.updateDefinition(content: cvu);
    } else {
      var cvuID = await CVUController.storeDefinition(db, cvuString: cvu);
      if (cvuID == null) {
        throw "CVU couldn't be saved";
      }
      var databaseQueryConfig = DatabaseQueryConfig(
          itemTypes: [startItemType], pageSize: 10, conditions: queryProperties);
      databaseQueryConfig.dbController = db;
      var items = await databaseQueryConfig.constructFilteredRequest();
      if (items.isEmpty) {
        await MockDataGenerator.generateMockItems(
            db: db, properties: properties, itemType: startItemType);
      } else {
        for (var item in items) {
          await ItemRecord.fromItem(item)
              .copy(db, withProperties: {"isMock": PropertyDatabaseValueBool(true)});
        }
      }
      return cvuID;
    }
    return null;
  }
}
