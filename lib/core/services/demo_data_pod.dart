import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:memri/constants/app_logger.dart';
import 'package:memri/core/controllers/file_storage/file_storage_controller.dart';
import 'package:memri/core/services/database/schema.dart';
import 'package:uuid/uuid.dart';

import '../../utilities/extensions/collection.dart';
import '../models/item.dart';

class DemoData {
  static String demoAssetsLink = "https://gitlab.memri.io/memri/flutter-app-assets/-/raw/dev/";

  static Map<String, SchemaType> types = {};

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

  static Future<Map<String, dynamic>> importDataToPod(
      {bool throwIfAgainstSchema = false, bool defaultData = true}) async {
    var fileURL = "assets/dev_database.json";
    if (!defaultData) {
      fileURL = "assets/demo_database.json";
    }

    var fileData = await rootBundle.loadString(fileURL, cache: false);
    var items = jsonDecode(fileData);
    if (items == null || items is! List) {
      return {"items": [], "urls": []};
    }
    await loadSchema();
    List<DemoItem> processedDemoItems = [];
    List<String> collectedUrls = [];

    var results = await Future.wait(items.map((item) async =>
    await processItemJSON(item: item, isRunningTests: throwIfAgainstSchema)));

    for (var result in results) {
      processedDemoItems.addAll(result["items"]);
      collectedUrls.addAll(result["urls"]);
    }

    Map<String, String> tempIDLookup = {};
    Map<String, String> sourceIDLookup = {};

    List<Item> allItems = [];

    for (var demoItem in processedDemoItems) {
      var item = Item(
          type: demoItem.type,
          properties: demoItem.properties);
      item.properties["id"] = demoItem.uid;
      //item.properties["dateCreated"] = demoItem.dateCreated?.millisecondsSinceEpoch;
      //item.properties["dateModified"] = demoItem.dateModified?.millisecondsSinceEpoch;
      var tempUID = demoItem.tempUID;

      if (demoItem.type == "File" && kIsWeb) {
        continue;
        //TODO: record.fileState = FileState.needsUpload;
      }
      if (tempUID != null) {
        tempIDLookup[tempUID] = demoItem.uid;
      }
      sourceIDLookup[item.id] = demoItem.uid;

      /*if (item.type == "Person") {
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
      }*/
      allItems.add(item);
    }

    for (var demoItem in processedDemoItems) {
      for (var edge in demoItem.edges) {
        var targetActualID = tempIDLookup[edge.targetTempUID];
        if (targetActualID == null) {
          continue;
        }
        var sourceEdgeItem = allItems.firstWhereOrNull((el) {
          return demoItem.uid == el.id;
        });
        var targetEdgeItem = allItems.firstWhereOrNull((el) {
          return el.id == targetActualID;
        });
        if (targetEdgeItem == null || sourceEdgeItem == null) {
          continue;
        }
        sourceEdgeItem.edges[edge.name] = EdgeList(name: edge.name, targets: [targetEdgeItem]);
      }
    }

    return {"items": allItems, "urls": collectedUrls};
  }

  static Future<Map<String, dynamic>> processItemJSON(
      {required Map<String, dynamic> item,
      String? overrideUID,
      bool isRunningTests = false}) async {
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
      return {"items": [], "urls": []};
    }

    if (types[itemType] == null) {
      //TODO:
      AppLogger.warn("$itemType not in schema");
      return {"items": [], "urls": []};
    }

    var itemTempUID = overrideUID ?? item["uid"]?.toString();

    List<DemoItem> items = [];
    List<String> urls = [];
    Map<String, dynamic> properties = {};
    List<DemoEdge> edges = [];
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
        case "id":
        case "version":
          return;
        case "allEdges":
          var edgeList = propertyValue;
          if (edgeList is! List ||
              edgeList.isEmpty ||
              (edgeList.isNotEmpty && edgeList[0] is! Map)) {
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
              edges.add(DemoEdge(name: edgeName, targetTempUID: targetUID));
            } else {
              var subitem = edge["_target"];
              if (subitem is Map) {
                // Sub-item declared as edge, add edge property AND item
                var targetUID = Uuid().v4();
                edges.add(DemoEdge(name: edgeName, targetTempUID: targetUID));
                var result = await processItemJSON(
                      item: subitem as Map<String, dynamic>,
                      overrideUID: targetUID,
                    isRunningTests: isRunningTests);
                items = [...items, ...result["items"]];
                urls = [...urls, ...result["urls"]];
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
            if (!isRunningTests &&
                itemType == "File" &&
                propertyName == "filename" &&
                propertyValue is String && !kIsWeb) {
              var fileName = propertyValue.split(".");

              var baseURL = DemoData.demoAssetsLink; // Replace with your image base URL
              var extension = fileName.length > 1 ? fileName[1] : "jpg";
              var sourceURL = "$baseURL/${fileName[0]}.$extension";

              var newFileName = "${Uuid().v4()}.$extension";
              var url = (await FileStorageController.getFileStorageURL()) + "/" + newFileName;

              await FileStorageController.download(sourceURL, url);

              var sha256 = await FileStorageController.getHashForFile(fileURL: url);

              properties["sha256"] = sha256;
              urls.add(url); // Add the generated URL to the list
            }

            properties[propertyName] = propertyValue;
          } catch (error) {
            handleError(error.toString());
            return;
          }

      }
    });

    items.add(DemoItem(
        type: itemType,
        tempUID: itemTempUID,
        properties: properties,
        edges: edges,
        dateCreated: dateCreated,
        dateModified: dateModified));

    return {"items": items, "urls": urls};
  }
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

class DemoItem {
  String type;
  String uid;
  String? tempUID;
  Map<String, dynamic> properties;
  List<DemoEdge> edges;
  DateTime? dateCreated;
  DateTime? dateModified;

  DemoItem(
      {required this.type,
      uid,
      this.tempUID,
      required this.properties,
      required this.edges,
      this.dateCreated,
      this.dateModified})
      : this.uid = uid ?? Uuid().v4().toString();
}

class DemoEdge {
  String name;
  String targetTempUID;

  DemoEdge({required this.name, required this.targetTempUID});
}
