import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../AppController.dart';
import 'DatabaseController.dart';
import 'ItemEdgeRecord.dart';
import 'ItemPropertyRecord.dart';
import 'ItemRecord.dart';
import 'PropertyDatabaseValue.dart';
import 'Schema.dart';

class DemoData {
  static Future<void> importDemoData(
      {DatabaseController? databaseController, bool throwIfAgainstSchema = false}) async {
    databaseController ??= AppController.shared.databaseController;
    var fileURL = "assets/demo_database.json";
    var fileData = await rootBundle.loadString(fileURL);
    var items = jsonDecode(fileData);
    if (items == null || items is! List) {
      return;
    }

    List<DemoDataItem> processedItems = items
        .expand((item) => processItemJSON(item: item, schema: databaseController!.schema))
        .toList();

    Map<String, int> tempIDLookup = {};
    Map<String, int> sourceIDLookup = {};

    for (var item in processedItems) {
      var record = ItemRecord(
          uid: item.uid,
          type: item.type,
          dateCreated: item.dateCreated,
          dateModified: item.dateModified);
      var tempUID = item.tempUID;
      var recordID = await record.insert(databaseController.databasePool);
      if (tempUID != null) {
        tempIDLookup[tempUID] = recordID;
      }
      sourceIDLookup[item.uid] = recordID;
    }

    for (var item in processedItems) {
      for (var property in item.properties) {
        ItemPropertyRecord record = ItemPropertyRecord(
            itemUID: item.uid,
            itemRowID: sourceIDLookup[item.uid]!,
            name: property.name,
            value: property.value);
        await record.insert(databaseController.databasePool);
      }
      for (var edge in item.edges) {
        var targetActualID = tempIDLookup[edge.targetTempUID];
        if (targetActualID == null) {
          continue;
        }
        var sourceRowID = sourceIDLookup[item.uid];

        ItemRecord selfRecord = ItemRecord(
            type: "Edge", dateCreated: item.dateCreated, dateModified: item.dateModified);
        var selfRowId = await selfRecord.insert(databaseController.databasePool);
        var record = ItemEdgeRecord(
            selfRowID: selfRowId,
            sourceRowID: sourceRowID,
            name: edge.name,
            targetRowID: targetActualID);
        await record.insert(databaseController.databasePool);
      }
    }
  }

  static List<DemoDataItem> processItemJSON(
      {required Map<String, dynamic> item,
      required Schema schema,
      String? overrideUID,
      isRunningTests = false}) {
    handleError(String string) {
      if (isRunningTests) {
        // Used for testing: throw an error if error in demo data
        throw (string);
      } else {
        // Notify developer of error in demo data, but continue
        print(string);
      }
    }

    var itemType = item["_type"];
    if (itemType is! String) {
      handleError("BAD RECORD: $item");
      return [];
    }

    if (schema.types[itemType] == null) {
      print("$itemType not in schema");
      return [];
    }

    var itemTempUID = overrideUID ?? item["uid"]?.toString();

    List<DemoDataItem> items = [];
    List<DemoDataProperty> properties = [];
    List<DemoDataEdge> edges = [];
    // Fake a recent date for the demo data

    var dateCreated = DateTime.now().subtract(Duration(milliseconds: Random().nextInt(1814400)));
    var dateModified = dateCreated;

    item.forEach((propertyName, propertyValue) {
      switch (propertyName) {
        case "_type":
        case "uid":
        case "version":
          return;
        case "allEdges":
          var edgeList = propertyValue;
          if (edgeList is! List ||
              edgeList.length == 0 ||
              (edgeList.length > 0 && edgeList[0] is! Map)) {
            return;
          }
          for (var edge in edgeList) {
            var edgeName = edge["_type"];
            if (edgeName is! String) {
              return;
            }
            var targetUID = edge["uid"]?.toString();
            if (targetUID != null) {
              edges.add(DemoDataEdge(name: edgeName, targetTempUID: targetUID));
            } else {
              var subitem = edge["_target"];
              if (subitem is Map) {
                // Sub-item declared as edge, add edge property AND item
                var targetUID = Uuid().v4();
                edges.add(DemoDataEdge(name: edgeName, targetTempUID: targetUID));
                items = [
                  ...items,
                  ...processItemJSON(
                      item: subitem as Map<String, dynamic>, schema: schema, overrideUID: targetUID)
                ];
              }
            }
          }
          break;
        case "dateCreated":
          var dateInMilliseconds = propertyValue;
          if (dateInMilliseconds is! int) return;
          var date = DateTime.fromMillisecondsSinceEpoch(dateInMilliseconds);
          dateCreated = date;
          dateModified = date;
          break;
        default:
          var expectedType = schema.types[itemType]?.propertyTypes[propertyName];
          if (expectedType == null) {
            handleError("$itemType.$propertyName property not in schema");
            return;
          }
          try {
            var result = PropertyDatabaseValue.create(
                propertyValue, expectedType.valueType, "$itemType.$propertyName");
            properties.add(DemoDataProperty(name: propertyName, value: result));
          } catch (error) {
            handleError(error.toString());
            return;
          }
      }
    });

    items.add(DemoDataItem(
        type: itemType,
        tempUID: itemTempUID,
        properties: properties,
        edges: edges,
        dateCreated: dateCreated,
        dateModified: dateModified));
    return items;
  }
}

class DemoDataItem {
  String type;
  String uid;
  String? tempUID;
  List<DemoDataProperty> properties;
  List<DemoDataEdge> edges;
  DateTime? dateCreated;
  DateTime? dateModified;

  DemoDataItem(
      {required this.type,
      uid,
      this.tempUID,
      required this.properties,
      required this.edges,
      this.dateCreated,
      this.dateModified})
      : this.uid = uid ?? Uuid().v4().toString();
}

class DemoDataProperty {
  String name;
  PropertyDatabaseValue value;

  DemoDataProperty({required this.name, required this.value});
}

class DemoDataEdge {
  String name;
  String targetTempUID;

  DemoDataEdge({required this.name, required this.targetTempUID});
}
