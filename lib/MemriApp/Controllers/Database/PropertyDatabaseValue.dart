//
//  DatabaseTypes.swift
//  MemriDatabase
//
//  Created by T Brennan on 13/11/20.
//

/// This type is used as an intermediate for storing and retrieving values from the database
/// It makes use of the dynamic schema to determine what type to resolve the data as.
enum PropertyDatabaseValueType { string, bool, int, double, datetime, blob }

class PropertyDatabaseValueString extends PropertyDatabaseValue {
  final String value;

  PropertyDatabaseValueString(this.value);
}

class PropertyDatabaseValueBool extends PropertyDatabaseValue {
  final bool value;

  PropertyDatabaseValueBool(this.value);
}

class PropertyDatabaseValueInt extends PropertyDatabaseValue {
  final int value;

  PropertyDatabaseValueInt(this.value);
}

class PropertyDatabaseValueDouble extends PropertyDatabaseValue {
  final double value;

  PropertyDatabaseValueDouble(this.value);
}

class PropertyDatabaseValueDatetime extends PropertyDatabaseValue {
  final DateTime value;

  PropertyDatabaseValueDatetime(this.value);
}

class PropertyDatabaseValueBlob extends PropertyDatabaseValue {
  final String value;

  PropertyDatabaseValueBlob(this.value);
}

abstract class PropertyDatabaseValue {
  late dynamic value;

  String asString() {
    return value.toString();
  }

  double? asDouble() {
    return double.tryParse(value);
  }

  bool asBool() {
    String str = value.toString(); //TODO find a better way to convert to bool @anijanyan
    return str != '0' && str != 'false' && str != '';
  }

  DateTime asDate() {
    return DateTime(int.parse(value) * 1000);
  }

  double? asCGFloat() {
    return double.tryParse(value);
  }
}