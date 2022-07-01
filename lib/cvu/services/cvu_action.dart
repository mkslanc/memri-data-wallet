//  Created by T Brennan on 8/1/21.

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:memri/constants/app_logger.dart';
import 'package:memri/core/controllers/app_controller.dart';
import 'package:memri/cvu/controllers/cvu_controller.dart';
import 'package:memri/cvu/controllers/cvu_lookup_controller.dart';
import 'package:memri/core/controllers/database_controller.dart';
import 'package:memri/cvu/controllers/database_query.dart';
import 'package:memri/core/apis/gitlab_api.dart';
import 'package:memri/core/models/database/item_edge_record.dart';
import 'package:memri/core/models/database/item_property_record.dart';
import 'package:memri/core/models/database/item_record.dart';
import 'package:memri/core/models/plugin_config_json.dart';
import 'package:memri/core/services/database/property_database_value.dart';
import 'package:memri/core/services/database/schema.dart';
import 'package:memri/core/services/mixpanel_analytics_service.dart';
import 'package:memri/cvu/models/cvu_value.dart';
import 'package:memri/cvu/models/cvu_value_constant.dart';
import 'package:memri/cvu/services/resolving/cvu_context.dart';
import 'package:memri/cvu/services/resolving/cvu_property_resolver.dart';
import 'package:memri/utilities/extensions/collection.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

abstract class CVUAction {
  execute(CVUContext context);

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
    case "additem":
      return ({Map? vars}) => CVUActionAddItem(vars: vars);
    case "openlink":
      return ({Map? vars}) => CVUActionOpenLink(vars: vars);
    case "delete":
      return ({Map? vars}) => CVUActionDelete(vars: vars);
    case "deleteitems":
      return ({Map? vars}) => CVUActionDeleteItems(vars: vars);
    case "link":
      return ({Map? vars}) => CVUActionLink(vars: vars);
    case "unlink":
      return ({Map? vars}) => CVUActionUnlink(vars: vars);
    case "setproperty":
      return ({Map? vars}) => CVUActionSetProperty(vars: vars);
    case "copytoclipboard":
      return ({Map? vars}) => CVUActionCopyToClipboard(vars: vars);
    case "validate":
      return ({Map? vars}) => CVUActionValidate(vars: vars);
    case "wait":
      return ({Map? vars}) => CVUActionWait(vars: vars);
    case "createlabellingtask":
      return ({Map? vars}) => CVUActionCreateLabellingTask(vars: vars);
    case "parseplugin":
      return ({Map? vars}) => CVUActionParsePluginItem(vars: vars);
    default:
      return null;
  }
}

class CVUActionOpenLink extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionOpenLink({vars}) : this.vars = vars ?? {};

  @override
  Future execute(CVUContext context) async {
    var link = vars["link"];
    if (link != null) {
      var db = AppController.shared.databaseController;
      var resolver = CVUPropertyResolver(
          context: context,
          lookup: CVULookupController(),
          db: db,
          properties: vars);
      var url = await resolver.string("link");
      if (url != null) {
        if (url.toLowerCase().contains('discord.com')) {
          MixpanelAnalyticsService().logDiscordButton();
        } else if (url.toLowerCase().contains('gitlab.memri.io')) {
          MixpanelAnalyticsService().logGitlabButton();
        }
        await canLaunchUrlString(url)
            ? await launchUrlString(url)
            : AppLogger.err('Could not launch $url');
      }
    }
  }
}

class CVUActionCopyToClipboard extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionCopyToClipboard({vars}) : this.vars = vars ?? {};

  @override
  execute(CVUContext context) async {
    var db = AppController.shared.databaseController;
    var resolver = CVUPropertyResolver(
        context: context,
        lookup: CVULookupController(),
        db: db,
        properties: vars);
    var value = await resolver.string("value");
    if (value != null) {
      if (value.toLowerCase().contains('key')) {
        if (value.contains('ownerKey')) {
          Clipboard.setData(ClipboardData(
              text:
                  (await AppController.shared.podConnectionConfig)!.ownerKey));
        } else if (value.contains('databaseKey')) {
          Clipboard.setData(ClipboardData(
              text: (await AppController.shared.podConnectionConfig)!
                  .databaseKey));
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
  Future execute(CVUContext context) async {
    var db = AppController.shared.databaseController;
    var resolver = CVUPropertyResolver(
        context: context,
        lookup: CVULookupController(),
        db: db,
        properties: vars);
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
            await ItemPropertyRecord(
                    itemRowID: itemRowId,
                    name: key,
                    value: propertyDatabaseValue)
                .save(db.databasePool, isNew: isNew ? true : null);
          }
        } else if (valueType is ResolvedTypeEdge) {
          var targets = await template.items(isReverse ? key : cleanKey);
          var targetRowIDs = targets.compactMap((target) => target.rowId);
          if (targetRowIDs.isEmpty) continue;

          if (!isNew) {
            var existingEdges = isReverse
                ? await item.reverseEdges(cleanKey)
                : await item.edges(cleanKey);
            await Future.forEach<ItemEdgeRecord>(
                existingEdges,
                (edge) async => targetRowIDs.contains(
                        isReverse ? edge.sourceRowID : edge.targetRowID)
                    ? targetRowIDs.remove(
                        isReverse ? edge.sourceRowID! : edge.targetRowID!)
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

      //TODO: ?
      /*var openNewView = await resolver.boolean("openNewView", true);
      if (openNewView!) {
        var renderer;
        var viewName = await resolver.string("viewName");
        if (viewName == null) {
          renderer = "generalEditor";
          var viewDefinition = AppController.shared.cvuController
              .viewDefinitionForItemRecord(itemRecord: item);
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
          (newVars["viewArguments"] as CVUValueSubdefinition)
              .value
              .properties
              .update("readOnly",
                  (value) => CVUValueConstant(CVUConstantBool(false)),
                  ifAbsent: () => CVUValueConstant(CVUConstantBool(false)));
        } else {
          newVars["viewArguments"] =
              CVUValueSubdefinition(CVUDefinitionContent(properties: {
            "readOnly": CVUValueConstant(CVUConstantBool(false)),
          }));
        }

        await CVUActionOpenView(
                viewName: viewName, vars: newVars, renderer: renderer)
            .execute(pageController, context.replacingItem(item));
      }*/

      // await pageController.scheduleUIUpdate();
    }
  }
}

class CVUActionDelete extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionDelete({vars}) : this.vars = vars ?? {};

  Map<String, CVUValue> get defaultVars {
    return {"title": CVUValueConstant(CVUConstantString("Delete"))};
  }

  @override
  Future<void> execute(CVUContext context) async {
    var lookup = CVULookupController();
    var db = AppController.shared.databaseController;

    ItemRecord? subjectItem;
    var subjectVal = vars["subject"];
    if (subjectVal != null) {
      subjectItem = await lookup.resolve<ItemRecord>(
          value: subjectVal, context: context, db: db);
    }
    subjectItem ??= context.currentItem;
    if (subjectItem == null) {
      AppLogger.warn("No subject item for property " +
          (subjectVal?.value?.toString() ?? ""));
      return;
    }

    await subjectItem.delete(AppController.shared.databaseController);

    //TODO: ?
    /*var closeVal = vars["close"];
    if (closeVal != null) {
      var lookup = CVULookupController();
      var db = AppController.shared.databaseController;

      bool shouldClose = (await lookup.resolve<bool>(
          value: closeVal, context: context, db: db))!;
      if (shouldClose) {
        //TODO: ?
        pageController.navigateBack();
      }
    }*/
    // pageController.scheduleUIUpdate();
  }
}

class CVUActionDeleteItems extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionDeleteItems({vars}) : this.vars = vars ?? {};

  @override
  Future<void> execute(CVUContext context) async {
    var lookup = CVULookupController();
    var db = AppController.shared.databaseController;

    var subjectVal = vars["subjectItems"];
    if (subjectVal == null) return;

    var subjectItems = await lookup.resolve<List>(
        value: subjectVal,
        context: context,
        db: db,
        additionalType: ItemRecord);
    if (subjectItems == null) return;

    for (var subjectItem in subjectItems) {
      await subjectItem.delete(AppController.shared.databaseController);
    }
  }
}

class CVUActionLink extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionLink({vars}) : this.vars = vars ?? {};

  @override
  execute(CVUContext context) async {
    var lookup = CVULookupController();
    var db = AppController.shared.databaseController;

    var currentItem = context.currentItem;
    var resolver = CVUPropertyResolver(
        context: context, lookup: lookup, db: db, properties: vars);
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
      var edges =
          await subjectItems[0]!.edges(edgeType); //TODO: logic for many edges
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
      var existingEdges = isReverse
          ? await currentItem.edges(cleanKey)
          : await currentItem.reverseEdges(cleanKey);
      await Future.forEach<ItemEdgeRecord>(
          existingEdges,
          (edge) async => subjectRowIDs
                  .contains(isReverse ? edge.targetRowID : edge.sourceRowID)
              ? subjectRowIDs
                  .remove(isReverse ? edge.targetRowID! : edge.sourceRowID!)
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
  execute(CVUContext context) async {
    var lookup = CVULookupController();
    var db = AppController.shared.databaseController;

    var currentItem = context.currentItem;
    var subjectVal = vars["subject"];
    ItemRecord subjectItem = (await lookup.resolve<ItemRecord>(
        value: subjectVal, context: context, db: db))!;
    var edgeTypeVal = vars["edgeType"];
    String? edgeType = await lookup.resolve<String>(
        value: edgeTypeVal, context: context, db: db);
    if (currentItem == null ||
        subjectVal == null ||
        edgeTypeVal == null ||
        edgeType == null) {
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

    //await pageController.scheduleUIUpdate();
  }
}

class CVUActionSetProperty extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionSetProperty({vars}) : this.vars = vars ?? {};

  @override
  execute(CVUContext context) async {
    var lookup = CVULookupController();
    var db = AppController.shared.databaseController;
    var schema = db.schema;

    var subjectVal = vars["subject"];
    ItemRecord? subjectItem = await lookup.resolve<ItemRecord>(
        value: subjectVal, context: context, db: db);
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

    SchemaValueType? expectedType =
        schema.expectedPropertyType(subjectItem.type, property);
    CVUValue? value = vars["value"];

    if (expectedType == null || value == null) return;
    var databaseValue = await PropertyDatabaseValue.createFromCVUValue(
        cvuValue: value, propertyType: expectedType, context: context, db: db);
    if (databaseValue == null) return;
    await subjectItem.setPropertyValue(property, databaseValue);

    //pageController.topMostContext
    // ?.setupQueryObservation(); //TODO this is workaround: should delete as soon as db streams are implemented correctly
    //await pageController.scheduleUIUpdate();
  }
}

class CVUActionValidate extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionValidate({vars}) : this.vars = vars ?? {};

  @override
  execute(CVUContext context) async {
    var db = AppController.shared.databaseController;
    var resolver = CVUPropertyResolver(
        context: context,
        lookup: CVULookupController(),
        db: db,
        properties: vars);

    var rules = resolver.subdefinitionArray("rules");

    for (var rule in rules) {
      var exp = (await rule.boolean("expression", false, true))!;
      if (!exp) {
        var error = await rule.string("error") ??
            "Error on ${rule.properties["expression"].toString()}";
        throw error;
      }
    }
  }
}

class CVUActionWait extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionWait({vars}) : this.vars = vars ?? {};

  @override
  execute(CVUContext context) async {
    var seconds = vars["seconds"];

    if (seconds != null &&
        seconds is CVUValueConstant &&
        seconds.value is CVUConstantNumber) {
      await Future.delayed(
          Duration(seconds: (seconds.value.value as num).toInt()), () {});
    }
  }
}

class CVUActionCreateLabellingTask extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionCreateLabellingTask({vars}) : this.vars = vars ?? {};

  @override
  execute(CVUContext context) async {
    var lookup = CVULookupController();
    var db = AppController.shared.databaseController;
    var resolver = CVUPropertyResolver(
        context: context, lookup: lookup, db: db, properties: vars);
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
      AppLogger.warn(
          "CreateLabellingTask error: couldn't find query from dataset type");
      return;
    }
    var decodedQuery = jsonDecode(query);
    var itemType = decodedQuery["type"];
    if (itemType == null) {
      return;
    }

    var datasetEntry = await dataset.edgeItem("entry");
    if (datasetEntry == null) {
      var filterQuery = Map.of(decodedQuery);
      filterQuery.remove('type');
      List<DatabaseQueryConditionPropertyEquals> properties = [];
      filterQuery.forEach((key, value) {
        properties.add(
            DatabaseQueryConditionPropertyEquals(PropertyEquals(key, value)));
      });

      var databaseQueryConfig = DatabaseQueryConfig(
          itemTypes: [itemType],
          pageSize: 500,
          conditions: properties,
          sortProperty: "random");
      databaseQueryConfig.dbController = db;
      var datasetEntries = <ItemRecord>[];
      var edgesFromFilteredItems =
          (await databaseQueryConfig.constructFilteredRequest())
              .map((item) {
                var datasetEntry = ItemRecord(type: "DatasetEntry");
                datasetEntries.add(datasetEntry);

                return [
                  ItemEdgeRecord(
                      name: "entry",
                      sourceRowID: dataset.rowId,
                      targetUID: datasetEntry.uid),
                  ItemEdgeRecord(
                      name: "data",
                      sourceUID: datasetEntry.uid,
                      targetRowID: item.rowId)
                ];
              })
              .expand((element) => element)
              .toList();

      await ItemRecord.insertList(datasetEntries, db: db.databasePool);
      await ItemEdgeRecord.insertList(edgesFromFilteredItems,
          db: db.databasePool);
    }

    List<ItemRecord> featureItems = await resolver.items("features");
    var cvu =
        '.labellingAnnotation${Uuid().v4()} { \n ${itemType} > labelAnnotation {\n VStack {\n alignment: left\n padding: 30\n spacing: 5\n';
    for (var feature in featureItems) {
      var propertyName =
          (await feature.propertyValue("propertyName", db))?.value;
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
    newVars["template"] = CVUValueSubdefinition(
        (vars["template"] as CVUValueSubdefinition).value.clone());
    (newVars["template"] as CVUValueSubdefinition).value.properties.update(
        "view", (value) => CVUValueItem(cvuID),
        ifAbsent: () => CVUValueItem(cvuID));
    await CVUActionAddItem(vars: newVars).execute(context);
  }
}

class CVUActionParsePluginItem extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionParsePluginItem({vars}) : this.vars = vars ?? {};

  @override
  execute(CVUContext context) async {
    var lookup = CVULookupController();
    var db = AppController.shared.databaseController;
    var resolver = CVUPropertyResolver(
        context: context, lookup: lookup, db: db, properties: vars);
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
    var searchNeedle = url
        .replaceFirst("https://gitlab.memri.io/", "")
        .replaceFirst(RegExp(r"\/\-\/tree.*$"), "");
    var newUri = Uri.tryParse(
        "https://gitlab.memri.io/api/v4/projects?search=$searchNeedle&search_namespaces=true");
    if (newUri == null || !newUri.hasAbsolutePath) {
      throw "Url is not valid";
    }

    var response =
        await http.get(newUri, headers: {"content-type": "application/json"});
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
          key =
              "pluginDescription"; //TODO: change this after param in pyMemri will be changed
        properties.add(ItemPropertyRecord(
            name: key, value: PropertyDatabaseValueString(value)));
      }
    });

    var encodedConfig = await GitlabApi.downloadSingleArtifact(
        gitProjectId: gitProjectId,
        filename: "config.json",
        jobName: "create_config");
    properties.add(ItemPropertyRecord(
        name: "configJson", value: PropertyDatabaseValueString(encodedConfig)));
    var configJsonList = (jsonDecode(encodedConfig) as List)
        .map((json) => PluginConfigJson.fromJson(json))
        .toList();
    Map<String, dynamic> configData = {};
    for (var configItem in configJsonList) {
      if (configItem.defaultData != null && configItem.defaultData != "") {
        configData
            .addEntries([MapEntry(configItem.name, configItem.defaultData)]);
      }
    }
    configData["isMock"] ??= true;
    properties.add(ItemPropertyRecord(
        name: "config",
        value: PropertyDatabaseValueString(jsonEncode(configData))));
    properties.add(ItemPropertyRecord(
        name: "gitProjectId", value: PropertyDatabaseValueInt(gitProjectId)));

    await project.addEdge(edgeName: "labellingPlugin", targetItem: pluginItem);
    await pluginItem.setPropertyValueList(properties, db: db);
  }

  //TODO: this part is not used now, we will need it on next iterations
  parsePluginSchema(
      {required int gitProjectId, required DatabaseController db}) async {
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
          var propertyValue =
              ItemRecord.reverseMapSchemaValueType(el["valueType"]);
          if (itemType is String &&
              propertyName is String &&
              propertyValue is String) {
            var record = ItemRecord(type: "ItemPropertySchema");
            await record.save(db.databasePool);
            properties.addAll([
              ItemPropertyRecord(
                  name: "itemType",
                  value: PropertyDatabaseValueString(itemType)),
              ItemPropertyRecord(
                  name: "propertyName",
                  value: PropertyDatabaseValueString(propertyName)),
              ItemPropertyRecord(
                  name: "valueType",
                  value: PropertyDatabaseValueString(propertyValue)),
            ]);

            await record.setPropertyValueList(properties);
          }
        } else {
          if (type == "ItemEdgeSchema") {
            var sourceType = el["sourceType"];
            var edgeName = el["edgeName"];
            var targetType = el["targetType"];
            if (sourceType is String &&
                edgeName is String &&
                targetType is String) {
              var record = ItemRecord(type: "ItemEdgeSchema");
              await record.save(db.databasePool);
              properties.addAll([
                ItemPropertyRecord(
                    name: "sourceType",
                    value: PropertyDatabaseValueString(sourceType)),
                ItemPropertyRecord(
                    name: "edgeName",
                    value: PropertyDatabaseValueString(edgeName)),
                ItemPropertyRecord(
                    name: "targetType",
                    value: PropertyDatabaseValueString(targetType)),
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
