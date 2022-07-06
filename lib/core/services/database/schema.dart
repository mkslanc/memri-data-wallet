import 'dart:async';

import 'package:memri/core/models/database/database.dart';
import 'package:memri/utilities/extensions/collection.dart';

import '../pod_service.dart';

/// A schema definition. This is used to dynamically enforce supported types and properties
class Schema {
  final PodService _podService;

  Schema(this._podService);

  /// Supported types in the schema
  Map<String, SchemaType> types = {};

  static Map<String, String> _mapSchemaValueType = {
    "Text": "string",
    "Integer": "int",
    "Real": "double",
    "Bool": "bool",
    "DateTime": "datetime",
  };

  /// Load a Schema struct from the given file URL. Default URL of nil loads `schema.json` from the app bundle
  load() async {
    var groupedProperties = await getSchemaProperties();
    var groupedEdges = await getSchemaEdges();

    var allTypes =
        Set.of(groupedProperties.keys).union(Set.of(groupedEdges.keys));

    types = Map.fromEntries(allTypes.map((type) {
      var schemaType = SchemaType(
          type: type,
          propertyTypes: Map.fromEntries(groupedProperties[type]?.map(($0) {
                var schemaProperty =
                    SchemaProperty($0.itemType, $0.property, $0.valueType);
                return MapEntry($0.property, schemaProperty);
              }) ??
              []),
          edgeTypes: Map.fromEntries(groupedEdges[type]?.map(($0) {
                var schemaEdge =
                    SchemaEdge($0.sourceType, $0.edge, $0.targetType);
                return MapEntry($0.edge, schemaEdge);
              }) ??
              []));
      return MapEntry(type, schemaType);
    }));
  }

  Future<Map<String, List<SchemaProperty>>> getSchemaProperties(
      [Database? db]) async {
    var query = '''
      query {
        ItemPropertySchema {
          id
          itemType
          propertyName
          valueType
        }
      }''';
    var schemaPropertyRecords = await _podService.graphql(query: query);

    return Dictionary.groupBy(
        schemaPropertyRecords.compactMap((itemPropertyRecord) {
      var itemType = itemPropertyRecord.get("itemType");
      var propertyName = itemPropertyRecord.get("propertyName");
      var valueType = _mapSchemaValueType[itemPropertyRecord.get("valueType")];
      return itemType == null || propertyName == null || valueType == null
          ? null
          : SchemaProperty(itemType, propertyName,
              SchemaValueTypeExtension.rawValue(valueType));
    }), (SchemaProperty $0) => $0.itemType);
  }

  Future<Map<String, List<SchemaEdge>>> getSchemaEdges([Database? db]) async {
    var query = '''
      query {
        ItemEdgeSchema {
          id
          sourceType
          edgeName
          targetType
        }
      }''';
    var schemaEdgeRecords = await _podService.graphql(query: query);

    return Dictionary.groupBy(schemaEdgeRecords.compactMap((edge) {
      var sourceType = edge.get("sourceType");
      var edgeName = edge.get("edgeName");
      var targetType = edge.get("targetType");
      return sourceType == null || edgeName == null || targetType == null
          ? null
          : SchemaEdge(sourceType, edgeName, targetType);
    }), (SchemaEdge $0) => $0.sourceType);
  }

  List<String> propertyNamesForItemType(String itemType) {
    return types[itemType]?.propertyTypes.keys.toList() ?? [];
  }

  ResolvedType? expectedType(String itemType, String propertyOrEdgeName) {
    var propertyType = expectedPropertyType(itemType, propertyOrEdgeName);
    if (propertyType != null) {
      return ResolvedTypeProperty(propertyType);
    } else {
      var edgeType = expectedTargetType(itemType, propertyOrEdgeName);
      if (edgeType != null) {
        return ResolvedTypeEdge(edgeType);
      } else {
        return null;
      }
    }
  }

  SchemaValueType? expectedPropertyType(String itemType, String propertyName) {
    return types[itemType]?.propertyTypes[propertyName]?.valueType;
  }

  String? expectedTargetType(String itemType, String edgeName) {
    return types[itemType]?.edgeTypes[edgeName]?.targetType;
  }

  List<String> expectedSourceTypes(String itemType, String edgeName) {
    var sourceTypes = <String>[];
    types.forEach((sourceType, schemaType) {
      if (schemaType.edgeTypes.containsKey(edgeName) &&
          (schemaType.edgeTypes[edgeName]!.targetType == itemType ||
              schemaType.edgeTypes[edgeName]!.targetType == "Any")) {
        sourceTypes.add(sourceType);
      }
    });
    return sourceTypes;
  }
}

abstract class ResolvedType {}

class ResolvedTypeProperty extends ResolvedType {
  SchemaValueType value;

  ResolvedTypeProperty(this.value);
}

class ResolvedTypeEdge extends ResolvedType {
  String value;

  ResolvedTypeEdge(this.value);
}

/// A schema type definition. This defines the supported properties and their value type
class SchemaType {
  String type;

  /// Supported properties for this type in the schema. Value is the value type for the property - this must be a primitive (string, double, dateTime)
  Map<String, SchemaProperty> propertyTypes;

  /// Supported properties for this type in the schema. Target type must be another type (eg. Photo, File, etc)
  Map<String, SchemaEdge> edgeTypes;

  SchemaType(
      {required this.type,
      required this.propertyTypes,
      required this.edgeTypes});
}

/// A schema property definition.
class SchemaProperty {
  String itemType;
  String property;
  SchemaValueType valueType;

  SchemaProperty(this.itemType, this.property, this.valueType);

  SchemaProperty.fromJson(Map<String, dynamic> json)
      : itemType = json['item_type'],
        property = json['property'],
        valueType = SchemaValueTypeExtension.rawValue(json['value_type']);

  Map<String, dynamic> toJson() => {
        'item_type': itemType,
        'property': property,
        'value_type': valueType.inString,
      };
}

enum SchemaValueType { string, bool, int, double, datetime, blob }

extension SchemaValueTypeExtension on SchemaValueType {
  static SchemaValueType rawValue(String value) =>
      SchemaValueType.values.firstWhere((val) => val.inString == value);

  String get inString {
    return this.toString().split('.').last;
  }
}

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
      this.targetType =
          json['target_type'].substring(0, json['target_type'].length - 2);
      this.allowsMultiple = true;
    } else {
      this.targetType = json['target_type'];
      this.allowsMultiple = false;
    }
  }

  Map<String, dynamic> toJson() => {
        'source_type': sourceType,
        'edge': edge,
        'target_type': '$targetType${allowsMultiple ? "[]" : ""}',
      };
}
