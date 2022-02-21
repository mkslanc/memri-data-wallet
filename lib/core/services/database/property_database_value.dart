//  Created by T Brennan on 13/11/20.

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:jiffy/jiffy.dart';
import 'package:memri/controllers/cvu_lookup_controller.dart';
import 'package:memri/controllers/database_controller.dart';
import 'package:memri/core/cvu/resolving/cvu_context.dart';
import 'package:memri/core/services/database/schema.dart';
import 'package:memri/models/cvu/cvu_value.dart';
import 'package:moor/moor.dart';

/// This type is used as an intermediate for storing and retrieving values from the database
/// It makes use of the dynamic schema to determine what type to resolve the data as.
abstract class PropertyDatabaseValue with EquatableMixin {
  dynamic get value;

  SchemaValueType get type;

  static PropertyDatabaseValue? createFromDBValue(
      Value databaseValue, SchemaValueType propertyType) {
    switch (propertyType) {
      case SchemaValueType.string:
        var string = databaseValue.value; //TODO:
        if (string == null) {
          return null;
        }
        return PropertyDatabaseValueString(string);
      case SchemaValueType.bool:
        var boolean = databaseValue.value;
        if (boolean == null) {
          return null;
        }
        return PropertyDatabaseValueBool(boolean);
      case SchemaValueType.int:
        var number = int.tryParse(databaseValue.value);
        if (number == null) {
          return null;
        }
        return PropertyDatabaseValueInt(number);
      case SchemaValueType.double:
        var doubleValue = databaseValue.value;
        if (doubleValue == null || !(doubleValue is double)) {
          return null;
        }
        return PropertyDatabaseValueDouble(doubleValue);
      case SchemaValueType.datetime:
        var datetimeInt = databaseValue.value;
        if (datetimeInt == null) {
          return null;
        }
        var date = DateTime.fromMillisecondsSinceEpoch(databaseValue.value);
        return PropertyDatabaseValueDatetime(date);
      case SchemaValueType.blob:
        var data = databaseValue.value;
        if (data == null) {
          return null;
        }
        return PropertyDatabaseValueBlob(jsonEncode(data));
    }
  }

  static PropertyDatabaseValue create(dynamic value, SchemaValueType propertyType,
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
        throw Exception('Expected DateTime (Int with milliseconds since 1970): $debugInfo');
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

  static Future<PropertyDatabaseValue?> createFromCVUValue(
      {required CVUValue cvuValue,
      required SchemaValueType propertyType,
      required CVUContext context,
      required DatabaseController db}) async {
    var lookup = CVULookupController();
    var resolvedValue;
    switch (propertyType) {
      case SchemaValueType.double:
        resolvedValue = await lookup.resolve<double>(value: cvuValue, context: context, db: db);
        if (resolvedValue == null) {
          return null;
        }
        return PropertyDatabaseValueDouble(resolvedValue);
      case SchemaValueType.bool:
        resolvedValue = await lookup.resolve<bool>(value: cvuValue, context: context, db: db);
        if (resolvedValue == null) {
          return null;
        }
        return PropertyDatabaseValueBool(resolvedValue);
      case SchemaValueType.int:
        resolvedValue = await lookup.resolve<int>(value: cvuValue, context: context, db: db);
        if (resolvedValue == null) {
          return null;
        }
        return PropertyDatabaseValueInt(resolvedValue);
      case SchemaValueType.string:
        resolvedValue = await lookup.resolve<String>(value: cvuValue, context: context, db: db);
        if (resolvedValue == null) {
          return null;
        }
        return PropertyDatabaseValueString(resolvedValue);
      case SchemaValueType.datetime:
        resolvedValue = await lookup.resolve<int>(value: cvuValue, context: context, db: db);
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
    var val = int.tryParse(value); //TODO is this correct @anijanyan
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
    return Jiffy(value).format("dd/MM/yyyy HH:mm:s"); //TODO
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
