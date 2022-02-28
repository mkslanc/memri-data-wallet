import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:memri/constants/app_logger.dart';
import 'package:memri/constants/app_settings.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/controllers/database_controller.dart';
import 'package:memri/controllers/file_storage/file_storage_controller.dart';
import 'package:memri/core/services/database/property_database_value.dart';
import 'package:memri/core/services/database/schema.dart';
import 'package:memri/models/database/item_edge_record.dart';
import 'package:memri/models/database/item_property_record.dart';
import 'package:memri/models/database/item_record.dart';
import 'package:memri/utils/extensions/collection.dart';
import 'package:memri/utils/extensions/string.dart';
import 'package:uuid/uuid.dart';

class DemoData {
  static Map<String, SchemaType> types = {};

  static importSchemaOnce(
      {DatabaseController? databaseController, bool throwIfAgainstSchema = false}) async {
    databaseController ??= AppController.shared.databaseController;

    var schemaItems = await ItemRecord.fetchWithType("ItemPropertySchema", databaseController);
    if (schemaItems.isEmpty) {
      schemaItems = await ItemRecord.fetchWithType("ItemEdgeSchema", databaseController);
    }

    if (schemaItems.isNotEmpty) {
      return;
    }

    var fileURL = "assets/schema.json";
    var fileData = await rootBundle.loadString(fileURL, cache: false);
    var items = jsonDecode(fileData);
    if (items == null ||
        items["properties"] == null ||
        items["properties"] is! List ||
        items["edges"] == null ||
        items["edges"] is! List) {
      throw Exception("Could not locate schema file");
    }

    await databaseController.databasePool.schemaImportTransaction(items);
    await databaseController.schema.load(databaseController.databasePool);
  }

  static loadSchema({isRunningTests = false}) async {
    handleError(String string) {
      if (isRunningTests) {
        throw (string);
      } else {
        AppLogger.err(string);
      }
    }

    var fileURL = 'assets/schema.json';

    var fileData = await rootBundle.loadString(fileURL, cache: false);
    var jsonFile = jsonDecode(fileData);
    var fileDecoded = SchemaFile.fromJson(jsonFile);

    var groupedProperties =
        Dictionary.groupBy(fileDecoded.properties, (SchemaProperty $0) => $0.itemType);
    var groupedEdges = Dictionary.groupBy(fileDecoded.edges, (SchemaEdge $0) => $0.sourceType);
    var allTypes = Set.of(groupedProperties.keys).union(Set.of(groupedEdges.keys));

    // Confirm that all edge target types actually exist in the schema
    var allEdgeTargetTypes = Set.of(fileDecoded.edges.map(($0) => $0.targetType));
    var undefinedEdgeTargetTypes =
        allEdgeTargetTypes.difference(allTypes).difference(Set.of(["Any"]));
    if (undefinedEdgeTargetTypes.isNotEmpty) {
      handleError(
          "Edge target types in schema for types that don't exist: $undefinedEdgeTargetTypes");
    }

    // Collate the schema into a format we can efficiently traverse
    types = Map.fromEntries(allTypes.map((type) {
      var schemaType = SchemaType(
          type: type,
          propertyTypes: Map.fromEntries(groupedProperties[type]?.map(($0) {
                var schemaProperty = SchemaProperty($0.itemType, $0.property, $0.valueType);
                return MapEntry($0.property, schemaProperty);
              }) ??
              []),
          edgeTypes: Map.fromEntries(groupedEdges[type]?.map(($0) {
                var schemaEdge = SchemaEdge($0.sourceType, $0.edge, $0.targetType);
                return MapEntry($0.edge, schemaEdge);
              }) ??
              []));
      return MapEntry(type, schemaType);
    }));
  }

  static importDefaultData(
      {DatabaseController? databaseController, bool throwIfAgainstSchema = false}) async {
    databaseController ??= AppController.shared.databaseController;
    await importData(
        fileName: AppSettings.defaultDatabase,
        databaseController: databaseController,
        throwIfAgainstSchema: throwIfAgainstSchema);
  }

  static importDemoData(
      {DatabaseController? databaseController, bool throwIfAgainstSchema = false}) async {
    databaseController ??= AppController.shared.databaseController;
    await importData(
        fileName: "demo_database",
        databaseController: databaseController,
        throwIfAgainstSchema: throwIfAgainstSchema);
  }

  static Future<void> importData(
      {required String fileName,
      required DatabaseController databaseController,
      bool throwIfAgainstSchema = false}) async {
    handleError(String string) {
      if (throwIfAgainstSchema) {
        // Used for testing: throw an error if error in demo data
        throw (string);
      } else {
        // Notify developer of error in demo data, but continue
        AppLogger.err(string);
      }
    }

    var fileURL = "assets/$fileName.json";
    var fileData = await rootBundle.loadString(fileURL, cache: false);
    var items = jsonDecode(fileData);
    if (items == null || items is! List) {
      return;
    }
    await databaseController.databasePool.transaction(() async {
      await loadSchema();

      List<DemoDataItem> processedItems = (await Future.wait(items.map((item) async =>
              await processItemJSON(item: item, isRunningTests: throwIfAgainstSchema))))
          .expand((element) => element)
          .toList();

      //we need this to point persons to current device owner
      var meRowId = (await ItemRecord.me(databaseController))?.rowId ??
          (await ItemRecord.createMe(databaseController))?.rowId;

      Map<String, int> tempIDLookup = {};
      Map<String, int> sourceIDLookup = {};

      for (var item in processedItems) {
        var record = ItemRecord(
            uid: item.uid,
            type: item.type,
            dateCreated: item.dateCreated,
            dateModified: item.dateModified);
        var tempUID = item.tempUID;

        if (record.type == "File") {
          record.fileState = FileState.needsUpload;
        }

        var recordID = await record.insert(databaseController.databasePool);
        if (tempUID != null) {
          tempIDLookup[tempUID] = recordID;
        }
        sourceIDLookup[item.uid] = recordID;

        if (item.type == "Person") {
          var record = ItemRecord(
              type: "Relationship", dateCreated: item.dateCreated, dateModified: item.dateModified);
          var recordRowID = await record.insert(databaseController.databasePool);
          record.rowId = recordRowID;
          await record.setPropertyValue("label", PropertyDatabaseValueString("Friend"),
              db: databaseController);
          await record.setPropertyValue("value", PropertyDatabaseValueInt(Random().nextInt(10000)),
              db: databaseController);
          var edge =
              ItemEdgeRecord(sourceRowID: meRowId, name: "relationship", targetRowID: recordRowID);
          await edge.insert(databaseController.databasePool);
          edge =
              ItemEdgeRecord(sourceRowID: recordRowID, name: "relationship", targetRowID: recordID);
          await edge.insert(databaseController.databasePool);
        }
      }

      List<ItemPropertyRecord> properties = [];
      List<ItemEdgeRecord> edges = [];
      for (var item in processedItems) {
        for (var property in item.properties) {
          ItemPropertyRecord record = ItemPropertyRecord(
              itemUID: item.uid,
              itemRowID: sourceIDLookup[item.uid]!,
              name: property.name,
              value: property.value);
          properties.add(record);
        }
        for (var edge in item.edges) {
          var targetActualID = tempIDLookup[edge.targetTempUID];
          if (targetActualID == null) {
            continue;
          }
          var targetItem = await ItemRecord.fetchWithRowID(targetActualID, databaseController);
          if (targetItem!.type != edge.targetType) {
            handleError(
                "Target item actual type is ${targetItem.type} should be ${edge.targetType}, uid: ${edge.targetTempUID}");
          }

          var sourceRowID = sourceIDLookup[item.uid];

          var record = ItemEdgeRecord(
              sourceRowID: sourceRowID, name: edge.name, targetRowID: targetActualID);
          edges.add(record);
        }
      }
      await databaseController.databasePool.itemPropertyRecordInsertAll(properties);
      await databaseController.databasePool.itemEdgeRecordInsertAll(edges);
    });
  }

  static Future<List<DemoDataItem>> processItemJSON(
      {required Map<String, dynamic> item, String? overrideUID, isRunningTests = false}) async {
    handleError(String string) {
      if (isRunningTests) {
        // Used for testing: throw an error if error in demo data
        throw (string);
      } else {
        // Notify developer of error in demo data, but continue
        AppLogger.err(string);
      }
    }

    var itemType = item["_type"];
    if (itemType is! String) {
      handleError("BAD RECORD: $item");
      return [];
    }

    if (types[itemType] == null) {
      AppLogger.warn("$itemType not in schema");
      return [];
    }

    var itemTempUID = overrideUID ?? item["uid"]?.toString();

    List<DemoDataItem> items = [];
    List<DemoDataProperty> properties = [];
    List<DemoDataEdge> edges = [];
    // Fake a recent date for the demo data

    var dateCreated =
        DateTime.now().subtract(Duration(milliseconds: Random().nextInt(1814400 * 1000)));
    var dateModified = dateCreated;

    await Future.forEach(item.entries, (MapEntry itemProperty) async {
      var propertyName = itemProperty.key;
      var propertyValue = itemProperty.value;
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

            SchemaEdge? expectedEdge = types[itemType]?.edgeTypes[edgeName];
            if (expectedEdge == null) {
              handleError("$itemType.$edgeName edge not in schema");
              return;
            }
            String? targetType = edge["targetType"] ?? edge["_target"]["_type"];
            if (targetType == null) {
              handleError("$itemType.$edgeName targetType is missing");
              return;
            }
            if (targetType != expectedEdge.targetType && expectedEdge.targetType != "Any") {
              handleError(
                  "$itemType.$edgeName targetType should be ${expectedEdge.targetType}, $targetType received");
              return;
            }

            var targetUID = edge["uid"]?.toString();
            if (targetUID != null) {
              edges.add(
                  DemoDataEdge(name: edgeName, targetTempUID: targetUID, targetType: targetType));
            } else {
              var subitem = edge["_target"];
              if (subitem is Map) {
                // Sub-item declared as edge, add edge property AND item
                var targetUID = Uuid().v4();
                edges.add(
                    DemoDataEdge(name: edgeName, targetTempUID: targetUID, targetType: targetType));
                items = [
                  ...items,
                  ...await processItemJSON(
                      item: subitem as Map<String, dynamic>,
                      overrideUID: targetUID,
                      isRunningTests: isRunningTests)
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
          var expectedType = types[itemType]?.propertyTypes[propertyName];
          if (expectedType == null) {
            handleError("$itemType.$propertyName property not in schema");
            return;
          }
          try {
            var databaseValue = PropertyDatabaseValue.create(
                propertyValue, expectedType.valueType, "$itemType.$propertyName");

            if (!isRunningTests &&
                itemType == "File" &&
                propertyName == "filename" &&
                databaseValue is PropertyDatabaseValueString) {
              var fileName = databaseValue.value;

              var demoDirectory = "assets/demoAssets";
              var sourcePath = demoDirectory +
                  "/" +
                  ("${fileName.fileName ?? ""}.${fileName.fileExtension ?? "jpg"}");

              // Also add sha256 property for item
              var byteData = await FileStorageController.getByteDataFromAsset(sourcePath);
              var sha256 = FileStorageController.getHashForData(
                  byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

              var url = (await FileStorageController.getFileStorageURL()) + "/" + sha256;

              properties.add(
                  DemoDataProperty(name: "sha256", value: PropertyDatabaseValueString(sha256)));

              await FileStorageController.copy(sourcePath, url);
            }

            properties.add(DemoDataProperty(name: propertyName, value: databaseValue));
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
  String targetType;

  DemoDataEdge({required this.name, required this.targetTempUID, required this.targetType});
}

class SchemaFile {
  List<SchemaProperty> properties;
  List<SchemaEdge> edges;

  SchemaFile(this.properties, this.edges);

  SchemaFile.fromJson(Map<String, dynamic> json)
      : properties = (json['properties'] as List)
            .map((property) => SchemaProperty.fromJson(property))
            .toList(),
        edges = (json['edges'] as List).map((edge) => SchemaEdge.fromJson(edge)).toList();

  Map<String, dynamic> toJson() => {
        'properties': properties,
        'edges': edges,
      };
}
