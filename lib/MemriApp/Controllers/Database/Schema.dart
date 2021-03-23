import 'dart:convert';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';

import 'package:flutter/services.dart';

/// A schema definition. This is used to dynamically enforce supported types and properties
class Schema {
  /// Supported types in the schema
  Map<String, SchemaType> types;

  Schema(this.types);

  /// Load a Schema struct from the given file URL. Default URL of nil loads `schema.json` from the app bundle
  static Future<Schema> loadFromFile({String? url, isRunningTests = false}) async {
    handleError(String string) {
      if (isRunningTests) {
        throw (string);
      } else {
        print(string);
      }
    }

    var fileURL = url ?? 'assets/schema.json';

    var fileData = await rootBundle.loadString(fileURL);
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
    Map<String, SchemaType> types = Map.fromEntries(allTypes.map((type) {
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
    return Schema(types);
  }

  ResolvedType? expectedType(String itemType, String propertyOrEdgeName) {
    var propertyType = expectedPropertyType(itemType, propertyOrEdgeName);
    if (propertyType != null) {
      return ResolvedType_property(propertyType);
    } else {
      var edgeType = expectedTargetType(itemType, propertyOrEdgeName);
      if (edgeType != null) {
        return ResolvedType_edge(edgeType);
      } else {
        return null;
      }
    }
  }

  String? expectedPropertyType(String itemType, String propertyName) {
    return types[itemType]?.propertyTypes[propertyName]?.valueType;
  }

  String? expectedTargetType(String itemType, String edgeName) {
    return types[itemType]?.edgeTypes[edgeName]?.targetType;
  }
}

class ResolvedType {}

class ResolvedType_property extends ResolvedType {
  String value;

  ResolvedType_property(this.value);
}

class ResolvedType_edge extends ResolvedType {
  String value;

  ResolvedType_edge(this.value);
}

/// A schema type definition. This defines the supported properties and their value type
class SchemaType {
  String type;

  /// Supported properties for this type in the schema. Value is the value type for the property - this must be a primitive (string, double, dateTime)
  Map<String, SchemaProperty> propertyTypes;

  /// Supported properties for this type in the schema. Target type must be another type (eg. Photo, File, etc)
  Map<String, SchemaEdge> edgeTypes;

  SchemaType({required this.type, required this.propertyTypes, required this.edgeTypes});
}

/// A schema property definition.
class SchemaProperty {
  String itemType;
  String property;
  String valueType;

  SchemaProperty(this.itemType, this.property, this.valueType);

  SchemaProperty.fromJson(Map<String, dynamic> json)
      : itemType = json['item_type'],
        property = json['property'],
        valueType = json['value_type'];

  Map<String, dynamic> toJson() => {
        'item_type': itemType,
        'property': property,
        'value_type': valueType,
      };
}

enum SchemaValueType {
  string,
  bool,
  int,
  double,
  datetime,
  blob
} //TODO: extension to use this enum?

/// A schema edge definition.
class SchemaEdge {
  late String sourceType;
  late String edge;
  late String targetType;
  late bool allowsMultiple;

  SchemaEdge(this.sourceType, this.edge, this.targetType) {
    this.sourceType = sourceType;
    this.edge = edge;
    if (targetType.endsWith("[]")) {
      this.targetType = targetType.substring(0, targetType.length - 2);
      this.allowsMultiple = true;
    } else {
      this.targetType = targetType;
      this.allowsMultiple = false;
    }
  }

  SchemaEdge.fromJson(Map<String, dynamic> json) {
    this.sourceType = json['source_type'];
    this.edge = json['edge'];
    if (json['target_type'].endsWith("[]")) {
      this.targetType = json['target_type'].substring(0, json['target_type'].length - 2);
      this.allowsMultiple = true;
    } else {
      this.targetType = json['target_type'];
      this.allowsMultiple = false;
    }
  }

  Map<String, dynamic> toJson() => {
        'source_type': sourceType,
        'edge': edge,
        'target_type': '${targetType}${allowsMultiple ? "[]" : ""}',
      };
}

// MARK: CODABLE STRUCTS
/// A simple struct used for decoding the schema json.
/// The schema is stored in a diff-friendly format, however the app loads it into memory as dictionaries that can be efficiently queried.
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
