import 'dart:convert';

import 'package:memri/constants/app_logger.dart';
import 'package:memri/core/controllers/app_controller.dart';
import 'package:memri/core/controllers/database_controller.dart';
import 'package:memri/core/controllers/database_query.dart';
import 'package:memri/core/controllers/page_controller.dart' as memri;
import 'package:memri/core/cvu/resolving/cvu_context.dart';
import 'package:memri/core/models/database/item_edge_record.dart';
import 'package:memri/core/models/database/item_property_record.dart';
import 'package:memri/core/models/database/item_record.dart';
import 'package:memri/core/services/database/property_database_value.dart';
import 'package:memri/utilities/helpers/app_helper.dart';

class PluginHandler {
  static run(
      {required ItemRecord plugin,
      required ItemRecord runner,
      // required memri.PageController pageController,
      required CVUContext context}) async {
    AppController.shared.pubSubController.startObservingItemProperty(
        item: runner,
        property: "status",
        desiredValue: null,
        completion: (newValue, [error]) async {
          if (newValue is PropertyDatabaseValueString) {
            var status = newValue.value;

            switch (status) {
              case "userActionNeeded":
                // presentCVUforPlugin(
                //     plugin: plugin,
                //     runner: runner,
                //     pageController: pageController,
                //     context: context);
                break;
              case "daemon":
              case "done":
                await checkEnoughData(
                    plugin: plugin,
                    runner: runner,
                    db: AppController.shared.databaseController,
                    status: status);
                break;
              case "error":
                //TODO: do we have better solution?
                // pageController.sceneController.scheduleUIUpdate();
                // stopPlugin(
                //     plugin: plugin, runner: runner, pageController: pageController, status: status);
                break;
              default:
                break;
            }
            return;
          }
        });
  }

  static checkEnoughData(
      {required ItemRecord plugin,
      required ItemRecord runner,
      required DatabaseController db,
      required String status}) async {
    if (status == "daemon") {
      var progress = (await runner.property("progress"))?.$value.value ?? 0;
      if (progress < 0.96) {
        return;
      }
    }

    var requiredSize = app.settings.minimalRequiredData;

    var data = await getPluginData(plugin: plugin, db: db, size: requiredSize);
    if (data == null) {
      AppLogger.warn("Couldn't check if plugin run had enough data");
      stopPlugin(runner);
      return;
    }

    if (data.length < requiredSize) {
      await runner.setPropertyValueList([
        ItemPropertyRecord(
            name: "error", value: PropertyDatabaseValueString("notEnoughData")),
        ItemPropertyRecord(
            name: "status", value: PropertyDatabaseValueString("error"))
      ], db: db);
    } else {
      stopPlugin(runner);
    }
  }

  static Future<List<ItemRecord>?> getPluginData(
      {ItemRecord? plugin,
      ItemRecord? runner,
      required DatabaseController db,
      int size = 0}) async {
    plugin ??= await runner!.edgeItem("plugin");
    if (plugin == null) {
      throw Exception("Plugin not found");
    }
    var datasetType = await plugin.reverseEdgeItem("datasetPlugin");

    var query = (await datasetType?.propertyValue("queryStr"))?.asString();
    if (query == null) {
      return null;
    }
    var decodedQuery = jsonDecode(query);
    var itemType = decodedQuery["type"];
    if (itemType == null) {
      return null;
    }

    var filterQuery = Map.of(decodedQuery);
    filterQuery.remove('type');
    List<DatabaseQueryConditionPropertyEquals> properties = [];
    filterQuery.forEach((key, value) {
      properties.add(
          DatabaseQueryConditionPropertyEquals(PropertyEquals(key, value)));
    });

    var databaseQueryConfig = DatabaseQueryConfig(
        itemTypes: [itemType], pageSize: size, conditions: properties);
    databaseQueryConfig.dbController = db;
    return (await databaseQueryConfig.constructFilteredRequest())
        .map((item) => ItemRecord.fromItem(item))
        .toList();
  }

  static stopPlugin(ItemRecord runner) async {
    AppController.shared.pubSubController
        .stopObservingItemProperty(item: runner, property: "status");
  }

  static errorOccurred(
      {required ItemRecord plugin,
      required ItemRecord runner,
      required memri.PageController pageController}) async {
    var item = await runner.edgeItem("account");

    var pluginName = (await plugin.property("pluginName"))!.$value.value;

    stopPlugin(runner);
    await pageController.sceneController.navigateToNewContext(
        animated: false,
        viewName: "${pluginName}-error",
        pageController: pageController,
        targetItem: item);
  }

  static presentCVUforPlugin(
      {required ItemRecord plugin,
      required ItemRecord runner,
      required memri.PageController pageController}) async {
    var runnerRowId = runner.rowId;

    var item = await runner.edgeItem("account");

    if (item == null) {
      item = ItemRecord(type: "Account");
      await item.save();
      var itemRowId = item.rowId;
      if (itemRowId == null) {
        return;
      }

      var edge = ItemEdgeRecord(
          sourceRowID: runnerRowId, name: "account", targetRowID: itemRowId);
      await edge.save();

      var meRowID = (await ItemRecord.me())!.rowId;
      var meEdge = ItemEdgeRecord(
          sourceRowID: itemRowId, name: "owner", targetRowID: meRowID);
      await meEdge.save();
    }

    var pluginName = (await plugin.property("pluginName"))!.$value.value;

    await runner.setPropertyValue(
        "status", PropertyDatabaseValueString("cvuPresented"));

    await pageController.sceneController.navigateToNewContext(
        animated: false,
        viewName: "${pluginName}-userActionNeeded",
        pageController: pageController,
        targetItem: item);
  }
}
