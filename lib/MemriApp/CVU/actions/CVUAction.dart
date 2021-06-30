//
//  CVUAction.swift
//  MemriDatabase
//
//  Created by T Brennan on 8/1/21.
//

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/CVU/resolving/CVULookupController.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUPropertyResolver.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUViewArguments.dart';
import 'package:memri/MemriApp/Controllers/AppController.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseQuery.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemEdgeRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemPropertyRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/Controllers/Database/Schema.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/ViewContext.dart';
import 'package:memri/MemriApp/UI/ViewContextController.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';

abstract class CVUAction {
  execute(SceneController sceneController, CVUContext context);

  Map<String, CVUValue> get defaultVars {
    return {};
  }

  late Map<String, CVUValue> vars;

  String? getString(String key, CVUContext context, ViewContextController? viewContext) {
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
    case "deselectall":
      return ({Map? vars}) => CVUActionDeselectAll(vars: vars);
    case "tonextitem":
      return ({Map? vars}) => CVUActionToNextItem(vars: vars);
    case "topreviousitem":
      return ({Map? vars}) => CVUActionToPreviousItem(vars: vars);
    case "startplugin":
      return ({Map? vars}) => CVUActionStartPlugin(vars: vars);
    case "requestcontacts":
      return ({Map? vars}) => CVUActionRequestContactsPermission(vars: vars);
    case "requestlocation":
      return ({Map? vars}) => CVUActionRequestLocationPermission(vars: vars);
    case "requeststorage":
      return ({Map? vars}) => CVUActionRequestStoragePermission(vars: vars);
    case "openpopup":
      return ({Map? vars}) => CVUActionOpenPopup(vars: vars);
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
  execute(SceneController sceneController, CVUContext context) async {
    Map<String, CVUValue> newVars = {"inheritDatasource": CVUValueConstant(CVUConstantBool(true))};
    CVUActionOpenView(
            vars: newVars,
            viewName: "filter-starred",
            renderer: context.rendererName,
            viewDefinition: context.viewDefinition)
        .execute(sceneController, context);
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
  Future execute(SceneController sceneController, CVUContext context) async {
    var customDefinition = viewDefinition;
    if (customDefinition == null) {
      var view = vars["view"];
      if (view is CVUValueSubdefinition) {
        customDefinition = view.value;
      }
    }
    CVUViewArguments viewArguments;
    var viewArgs = vars["viewArguments"];
    if (viewArgs is CVUValueSubdefinition) {
      viewArguments = CVUViewArguments(
          args: viewArgs.value.properties,
          argumentItem: context.currentItem,
          parentArguments: context.viewArguments);
    } else {
      viewArguments = CVUViewArguments();
    }
    DatabaseController db = sceneController.appController.databaseController;
    var resolver = CVUPropertyResolver(
        context: context, lookup: CVULookupController(), db: db, properties: this.vars);
    await sceneController.navigateToNewContext(
        viewName: viewName ?? await resolver.string("viewName") ?? "customView",
        inheritDatasource: (await resolver.boolean("inheritDatasource", true))!,
        overrideRenderer: renderer ?? await resolver.string("renderer"),
        defaultRenderer: "singleItem",
        targetItem: context.currentItem,
        overrideRowIDs: uids,
        dateRange: dateRange,
        customDefinition: customDefinition,
        viewArguments: viewArguments);
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
  execute(SceneController sceneController, CVUContext context) async {}

  Future<ViewContextController?> getViewContext(CVUContext context) async {
    CVUDefinitionContent? customDefinition;
    var view = vars["view"];
    if (view is CVUValueSubdefinition) {
      customDefinition = view.value;
    }
    CVUViewArguments viewArguments;
    view = vars["viewArguments"];
    if (view is CVUValueSubdefinition) {
      viewArguments = CVUViewArguments(
          args: view.value.properties,
          argumentItem: context.currentItem,
          parentArguments: context.viewArguments);
    } else {
      viewArguments = CVUViewArguments();
    }

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

    var queryConfig = DatabaseQueryConfig();
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
        viewDefinition: viewDefinition,
        query: queryConfig,
        viewArguments: viewArguments,
        focusedItem: context.currentItem);
    var holder = ViewContextHolder(config);
    var newViewContext = ViewContextController(
        config: holder,
        databaseController: appController.databaseController,
        cvuController: appController.cvuController);

    return newViewContext;
  }
}

class CVUActionNavigateBack extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionNavigateBack({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    await sceneController.navigateBack();
  }
}

class CVUActionCopyToClipboard extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionCopyToClipboard({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    // TODO: implement execute
  }
}

class CVUActionAddItem extends CVUAction {
  Map<String, CVUValue> vars;

  Map<String, CVUValue> get defaultVars {
    return {"icon": CVUValueConstant(CVUConstantString("plus"))};
  }

  CVUActionAddItem({vars}) : this.vars = vars ?? {};

  @override
  Future execute(SceneController sceneController, CVUContext context) async {
    var db = sceneController.appController.databaseController;
    var resolver = CVUPropertyResolver(
        context: context, lookup: CVULookupController(), db: db, properties: vars);
    var template = resolver.subdefinition("template");
    if (template == null) {
      return;
    }
    var type = await template.string("_type");

    if (type != null) {
      var item = ItemRecord(type: type);
      try {
        await item.save(db.databasePool);
      } catch (error) {
        print("ERROR Adding item: " + error.toString());
      }

      var itemRowId = item.rowId;
      if (itemRowId == null) {
        return;
      }

      /// Take all the properties defined in the template definition (in CVU) and map them against the schema. Resolve the CVU based on the type expected by the schema.
      List<ItemPropertyRecord> properties = (await Future.wait(
              template.properties.keys.toList().map<Future<ItemPropertyRecord?>>((key) async {
        ResolvedType? valueType = db.schema.expectedType(type, key);
        if (valueType == null) {
          return null;
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
            return ItemPropertyRecord(
                itemRowID: itemRowId, name: key, value: propertyDatabaseValue);
          }
        } else if (valueType is ResolvedTypeEdge) {
          // todo migrate: Make sure this passes
          var target = await template.item(key);
          var targetRowId = target?.rowId;
          if (targetRowId == null) {
            return null;
          }
          await ItemEdgeRecord(
                  selfRowID: itemRowId, sourceRowID: itemRowId, name: key, targetRowID: targetRowId)
              .save();
        }
      })))
          .compactMap<ItemPropertyRecord>();

      await Future.forEach<ItemPropertyRecord>(properties, (property) async {
        await property.save(db.databasePool);
      });

      var renderer = "generalEditor";
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

      var newVars = Map.of(vars);
      newVars["viewArguments"] = CVUValueSubdefinition(CVUDefinitionContent(properties: {
        "readOnly": CVUValueConstant(CVUConstantBool(false)),
        "isEditing": CVUValueConstant(CVUConstantBool(true))
      }));

      await CVUActionOpenView(vars: newVars, viewName: type, renderer: renderer)
          .execute(sceneController, context.replacingItem(item));

      sceneController.isInEditMode.value = true;

      // AppController.shared.syncController.sync();TODO sync
    }
  }
}

class CVUActionStartPlugin extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionStartPlugin({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    var lookup = CVULookupController();
    var db = sceneController.appController.databaseController;

    var targetItemIdValue = vars["targetItemId"];
    var containerValue = vars["container"];
    if (targetItemIdValue == null || containerValue == null) return;

    String? targetItemId =
        await lookup.resolve<String>(value: targetItemIdValue, context: context, db: db);
    String? container =
        await lookup.resolve<String>(value: containerValue, context: context, db: db);
    if (targetItemId == null || container == null) return;

    try {
      var startPluginItem = ItemRecord(type: "StartPlugin");
      await startPluginItem.save();
      await startPluginItem.setPropertyValue("container", PropertyDatabaseValueString(container));
      await startPluginItem.setPropertyValue(
          "targetItemId", PropertyDatabaseValueString(targetItemId));

      await AppController.shared.syncController.sync();
    } catch (error) {
      print("Error starting plugin: $error");
    }
  }
}

class CVUActionToggleEditMode extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionToggleEditMode({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    sceneController.toggleEditMode();
  }
}

class CVUActionToggleNavigation extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionToggleNavigation({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    // TODO: implement execute
  }
}

class CVUActionToggleFullScreen extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionToggleFullScreen({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    // TODO: implement execute
  }
}

class CVUActionDelete extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionDelete({vars}) : this.vars = vars ?? {};

  @override
  Future<void> execute(SceneController sceneController, CVUContext context) async {
    var item = context.currentItem;
    if (item == null) {
      return;
    }

    await item.delete(sceneController.appController.databaseController);
  }
}

class CVUActionSelectAll extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionSelectAll({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    // TODO: implement execute
  }
}

class CVUActionDeselectAll extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionDeselectAll({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    // TODO: implement execute
  }
}

class CVUActionLink extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionLink({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    var lookup = CVULookupController();
    var db = sceneController.appController.databaseController;

    var currentItem = context.currentItem;
    var subjectVal = vars["subject"];
    ItemRecord subjectItem =
        (await lookup.resolve<ItemRecord>(value: subjectVal, context: context, db: db))!;
    var edgeTypeVal = vars["edgeType"];
    String? edgeType = await lookup.resolve<String>(value: edgeTypeVal, context: context, db: db);
    var distinctVal = vars["distinct"];
    bool? unique = await lookup.resolve<bool>(value: distinctVal, context: context, db: db);
    if (currentItem == null ||
        subjectVal == null ||
        edgeTypeVal == null ||
        edgeType == null ||
        distinctVal == null ||
        unique == null) {
      return;
    }

    if (unique) {
      var edges = await subjectItem.edges(edgeType);
      for (ItemEdgeRecord currentEdge in edges) {
        if (currentEdge.name == edgeType) {
          var result = await currentEdge.delete();
          if (result != true) {
            print(
                "ERROR CVUAction_link: item: ${subjectItem.type} with id: ${subjectItem.rowId} edge id: ${currentEdge.selfRowID}");
            return;
          }
        }
      }
    }

    var edge = ItemEdgeRecord(
        sourceRowID: subjectItem.rowId, name: edgeType, targetRowID: currentItem.rowId);
    edge.save(db.databasePool);

    sceneController.scheduleUIUpdate();
  }
}

class CVUActionUnlink extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionUnlink({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    var lookup = CVULookupController();
    var db = sceneController.appController.databaseController;

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
      print(
          "ERROR CVUAction_Unlink: item: ${subjectItem.type} with id: ${subjectItem.rowId} edge id: ${edge.selfRowID}");
      return;
    }

    sceneController.scheduleUIUpdate();
  }
}

class CVUActionStar extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionStar({vars}) : this.vars = vars ?? {};

  @override
  Future execute(SceneController sceneController, CVUContext context) async {
    var currentItem = context.currentItem;
    if (currentItem == null) {
      return;
    }

    var prop = "starred";
    var currentVal = (await currentItem.propertyValue(prop))?.asBool() ?? false;
    try {
      await currentItem.setPropertyValue(prop, PropertyDatabaseValueBool(!currentVal));
      //sceneController.scheduleUIUpdate();
    } catch (error) {
      print(
          "ERROR CVUAction_Star: item: ${currentItem.type} with id: ${currentItem.rowId} error: $error");
    }
  }
}

class CVUActionClosePopup extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionClosePopup({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    sceneController.closeLastInStack();
  }
}

class CVUActionToggleFilterPanel extends CVUAction {
  Map<String, CVUValue> vars;

  Map<String, CVUValue> get defaultVars {
    return {"icon": CVUValueConstant(CVUConstantString("rhombus.fill"))};
  }

  CVUActionToggleFilterPanel({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    sceneController.filterPanelIsVisible.value = !sceneController.filterPanelIsVisible.value;
  }
}

class CVUActionOpenGroup extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionOpenGroup({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
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
  execute(SceneController sceneController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionShowNavigation extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionShowNavigation({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionDuplicate extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionDuplicate({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionSchedule extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionSchedule({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionShowSessionSwitcher extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionShowSessionSwitcher({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionForwardToFront extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionForwardToFront({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionBackAsSession extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionBackAsSession({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionOpenSession extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionOpenSession({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionOpenSessionByName extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionOpenSessionByName({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionMultiAction extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionMultiAction({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionRunIndexer extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionRunIndexer({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionSetProperty extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionSetProperty({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    var lookup = CVULookupController();
    var db = sceneController.appController.databaseController;
    var schema = db.schema;

    var subjectVal = vars["subject"];
    ItemRecord? subjectItem =
        await lookup.resolve<ItemRecord>(value: subjectVal, context: context, db: db);
    if (subjectItem == null) return;
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
    var databaseValue = PropertyDatabaseValue.createFromCVUValue(value, expectedType);
    if (databaseValue == null) return;

    await subjectItem.setPropertyValue(property, databaseValue);

    sceneController.topMostContext
        ?.setupQueryObservation(); //TODO this is workaround: should delete as soon as db streams are implemented correctly

    sceneController.scheduleUIUpdate();
  }
}

class CVUActionSetSetting extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionSetSetting({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionToNextItem extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionToNextItem({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    if (sceneController.topMostContext == null) {
      return;
    }
    var index = sceneController.topMostContext!.focusedIndex;
    sceneController.topMostContext?.focusedIndex =
        index >= sceneController.topMostContext!.items.length - 1 ? 0 : index + 1;
    sceneController.scheduleUIUpdate();
  }
}

class CVUActionToPreviousItem extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionToPreviousItem({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    if (sceneController.topMostContext == null) {
      return;
    }
    var index = sceneController.topMostContext!.focusedIndex;
    sceneController.topMostContext?.focusedIndex =
        index <= 0 ? sceneController.topMostContext!.items.length - 1 : index - 1;
    sceneController.scheduleUIUpdate();
  }
}

class CVUActionNoop extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionNoop({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    // TODO:
  }
}

class CVUActionRequestContactsPermission extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionRequestContactsPermission({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    await sceneController.appController.permissionController.requestContacts();
  }
}

class CVUActionRequestLocationPermission extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionRequestLocationPermission({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    await sceneController.appController.permissionController.requestLocation();
  }
}

class CVUActionRequestStoragePermission extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionRequestStoragePermission({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) async {
    await sceneController.appController.permissionController.requestStorage();
  }
}

class CVUActionOpenPopup extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionOpenPopup({vars}) : this.vars = vars ?? {};

  Future<Map<String, dynamic>?> setPopupSettings(
      SceneController sceneController, CVUContext context) async {
    var lookup = CVULookupController();
    var db = sceneController.appController.databaseController;

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
  execute(SceneController sceneController, CVUContext context) async {}
}
