import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:memri/constants/app_logger.dart';
import 'package:memri/core/controllers/file_storage/file_storage_controller.dart';
import 'package:memri/core/services/database/schema.dart';
import 'package:uuid/uuid.dart';

import '../../utilities/extensions/collection.dart';
import '../models/item.dart';

class DemoData {
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


  static Future<List<Item>> importDemoDataToPod(
      {bool throwIfAgainstSchema = false}) async {
    var fileURL = "assets/demo_database.json";
    var fileData = await rootBundle.loadString(fileURL, cache: false);
    var items = jsonDecode(fileData);
    if (items == null || items is! List) {
      return [];
    }
    await loadSchema();
    List<Item> processedItems = (await Future.wait(items.map((item) async =>
            await processItemJSON(item: item, isRunningTests: throwIfAgainstSchema))))
        .expand((element) => element)
        .toList();

    return processedItems;
  }

  static Future<List<Item>> processItemJSON(
      {required Map<String, dynamic> item, String? overrideUID, bool isRunningTests = false}) async {
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

    if (types[itemType] == null) { //TODO:
      AppLogger.warn("$itemType not in schema");
      return [];
    }

    var itemTempUID = overrideUID ?? item["uid"]?.toString();

    List<Item> items = [];
    Map<String, dynamic> properties = {};
    Map<String, EdgeList> edges = {};
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
              if (!edges.containsKey(edgeName)) {
                edges[edgeName] = EdgeList(name: edgeName, targets: []);
              }
              edges[edgeName]?.targets.add(Item(type: targetType, properties: {"uid": targetUID}));
            } else {
              var subitem = edge["_target"];
              if (subitem is Map) {
                // Sub-item declared as edge, add edge property AND item
                var targetUID = Uuid().v4();
                if (!edges.containsKey(edgeName)) {
                  edges[edgeName] = EdgeList(name: edgeName, targets: []);
                }
                edges[edgeName]?.targets.add(Item(type: targetType, properties: {"uid": targetUID}));
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


            /*PropertyDatabaseValue.create(
                propertyValue, expectedType.valueType, "$itemType.$propertyName");*/

            if (!isRunningTests &&
                itemType == "File" &&
                propertyName == "filename" && propertyValue is String) {
              var fileName = propertyValue.split(".");

              var demoDirectory = "assets/demoAssets";
              var sourcePath = "";
              if (fileName.length == 1) {
                sourcePath = demoDirectory +
                    "/" +
                    ("${fileName[0]}.jpg");
              } else {
                sourcePath = demoDirectory +
                    "/" +
                    ("${fileName[0] ?? ""}.${fileName[1]}");
              }


              // Also add sha256 property for item
              var byteData = await FileStorageController.getByteDataFromAsset(sourcePath);
              var sha256 = FileStorageController.getHashForData(
                  byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

              var url = (await FileStorageController.getFileStorageURL()) + "/" + sha256;

              properties["sha256"] = sha256;

              await FileStorageController.copy(sourcePath, url);
            }

            properties[propertyName] = propertyValue;
          } catch (error) {
            handleError(error.toString());
            return;
          }
      }
    });

    var finalItem = Item(
      type: itemType,
      properties: properties,
      edges: edges,
    );
    items.add(finalItem);
    return items;
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
