//  Created by T Brennan on 13/11/20.

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:jiffy/jiffy.dart';
import 'package:memri/cvu/controllers/cvu_lookup_controller.dart';
import 'package:memri/core/services/database/schema.dart';
import 'package:memri/cvu/models/cvu_value.dart';

import '../../../cvu/services/resolving/cvu_context.dart';

/// This type is used as an intermediate for storing and retrieving values from the database
/// It makes use of the dynamic schema to determine what type to resolve the data as.
abstract class PropertyDatabaseValue with EquatableMixin {
  dynamic get value;

  SchemaValueType get type;

  static PropertyDatabaseValue create(
      dynamic value, SchemaValueType propertyType,
      [String debugInfo = ""]) {
    switch (propertyType) {
      case SchemaValueType.double:
        if (value is! num) {
          throw Exception('Expected Double: $debugInfo');
        }
        return PropertyDatabaseValueDouble(value.toDouble());
      case SchemaValueType.bool:
        if (value is! bool && value is! int) {
          throw Exception('Expected Bool: $debugInfo');
        }
        var boolVal;
        if (value is int) {
          boolVal = value == 0 ? false : true;
        } else {
          boolVal = value;
        }
        return PropertyDatabaseValueBool(boolVal);
      case SchemaValueType.int:
        if (value is! int) {
          throw Exception('Expected Int: $debugInfo');
        }
        return PropertyDatabaseValueInt(value);
      case SchemaValueType.string:
        if (value is! String) {
          throw Exception('Expected String: $debugInfo');
        }
        return PropertyDatabaseValueString(value);
      case SchemaValueType.datetime:
        if (value != null && value is int) {
          return PropertyDatabaseValueInt(value);
        }
        throw Exception(
            'Expected DateTime (Int with milliseconds since 1970): $debugInfo');
      case SchemaValueType.blob:
        if (value is String) {
          return PropertyDatabaseValueBlob(value);
        } else {
          if (value == null) {
            throw Exception('Expected Data blob: $debugInfo.');
          }
          var data = jsonEncode(value);
          return PropertyDatabaseValueBlob(data);
        }
    }
  }

  static PropertyDatabaseValue? createFromCVUValue(
      {required CVUValue cvuValue,
      required SchemaValueType propertyType,
      required CVUContext context}) {
    var lookup = CVULookupController();
    var resolvedValue;
    switch (propertyType) {
      case SchemaValueType.double:
        resolvedValue =
            lookup.resolve<double>(value: cvuValue, context: context);
        if (resolvedValue == null) {
          return null;
        }
        return PropertyDatabaseValueDouble(resolvedValue);
      case SchemaValueType.bool:
        resolvedValue = lookup.resolve<bool>(value: cvuValue, context: context);
        if (resolvedValue == null) {
          return null;
        }
        return PropertyDatabaseValueBool(resolvedValue);
      case SchemaValueType.int:
        resolvedValue = lookup.resolve<int>(value: cvuValue, context: context);
        if (resolvedValue == null) {
          return null;
        }
        return PropertyDatabaseValueInt(resolvedValue);
      case SchemaValueType.string:
        resolvedValue =
            lookup.resolve<String>(value: cvuValue, context: context);
        if (resolvedValue == null) {
          return null;
        }
        return PropertyDatabaseValueString(resolvedValue);
      case SchemaValueType.datetime:
        resolvedValue = lookup.resolve<int>(value: cvuValue, context: context);
        if (resolvedValue == null) {
          return null;
        }
        return PropertyDatabaseValueInt(resolvedValue);
      default:
        return null;
    }
  }

  static ItemRecordPropertyTable toDBTableName(SchemaValueType type) {
    switch (type) {
      case SchemaValueType.string:
      case SchemaValueType.blob:
        return ItemRecordPropertyTable.strings;
      case SchemaValueType.bool:
      case SchemaValueType.datetime:
      case SchemaValueType.int:
        return ItemRecordPropertyTable.integers;
      case SchemaValueType.double:
        return ItemRecordPropertyTable.reals;
      default:
        throw Exception("Unknown schema value type");
    }
  }

  String? asString() {
    return value?.toString();
  }

  double? asDouble() {
    return value is double ? value : double.tryParse(value.toString());
  }

  int? asInt() {
    return value is int ? value : int.tryParse(value);
  }

  bool? asBool() {
    return (value == null || ["0", "", "false"].contains(value.toString()))
        ? false
        : true; //TODO find a valid way to convert to boolean @anijanyan
  }

  DateTime? asDate() {
    if (value is DateTime) {
      return value;
    }
    var val = value;
    if (value is String) {
      val = int.tryParse(value);
    }
    return val == null ? null : DateTime.fromMillisecondsSinceEpoch(val);
  }

  double? asCGFloat() {
    return double.tryParse(value);
  }

  @override
  List<Object?> get props => [value, type];
}

enum ItemRecordPropertyTable { strings, integers, reals }

class PropertyDatabaseValueString extends PropertyDatabaseValue {
  @override
  final String value;
  @override
  final SchemaValueType type = SchemaValueType.string;

  PropertyDatabaseValueString(this.value);
}

class PropertyDatabaseValueBool extends PropertyDatabaseValue {
  @override
  final bool value;
  @override
  final SchemaValueType type = SchemaValueType.bool;

  PropertyDatabaseValueBool(this.value);
}

class PropertyDatabaseValueInt extends PropertyDatabaseValue {
  @override
  final int value;
  @override
  final SchemaValueType type = SchemaValueType.int;

  PropertyDatabaseValueInt(this.value);
}

class PropertyDatabaseValueDouble extends PropertyDatabaseValue {
  @override
  final double value;
  @override
  final SchemaValueType type = SchemaValueType.double;

  PropertyDatabaseValueDouble(this.value);
}

class PropertyDatabaseValueDatetime extends PropertyDatabaseValue {
  @override
  final DateTime value;
  @override
  final SchemaValueType type = SchemaValueType.datetime;

  @override
  String? asString() {
    return Jiffy.parseFromDateTime(value).format(pattern: "dd/MM/yyyy HH:mm:s"); //TODO
  }

  PropertyDatabaseValueDatetime(this.value);
}

class PropertyDatabaseValueBlob extends PropertyDatabaseValue {
  @override
  final String value; //TODO type is blob
  @override
  final SchemaValueType type = SchemaValueType.blob;

  PropertyDatabaseValueBlob(this.value);
}
