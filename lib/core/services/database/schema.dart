import '../pod_service.dart';

/// A schema definition. This is used to dynamically enforce supported types and properties
class Schema {
  final PodService _podService;
  bool isLoaded = false;

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

  loadFromPod() async {
    if (isLoaded)
      return;
    var schemaData = await _podService.getSchema();;

    var nodeTypes = schemaData['nodes_types'] as Map<String, dynamic>;
    var edgeTypes = schemaData['edges_types'] as Map<String, dynamic>;

    types = nodeTypes.map((type, typeData) {
      var properties = (typeData['properties'] as Map<String, dynamic>).map((property, valueType) {

        valueType = _mapSchemaValueType[valueType]!;
        return MapEntry(property, SchemaProperty(type, property, SchemaValueTypeExtension.rawValue(valueType)));
      });

      var edgeProperties = <String, SchemaEdge>{};
      edgeTypes.forEach((edgeName, edgeList) {
        for (var edge in edgeList) {
          if (edge['source'] == type) {
            edgeProperties[edgeName] = SchemaEdge(
              edge['source'],
              edgeName,
              edge['target'],
            );
          }
        }
      });

      return MapEntry(type, SchemaType(
        type: type,
        propertyTypes: properties,
        edgeTypes: edgeProperties,
      ));
    });
    isLoaded = true;
  }

  List<String> propertyNamesForItemType(String itemType) {
    return types[itemType]?.propertyTypes.keys.toList() ?? [];
  }

  List<String> edgeNamesForItemType(String itemType) {
    return types[itemType]?.edgeTypes.keys.toList() ?? [];
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
