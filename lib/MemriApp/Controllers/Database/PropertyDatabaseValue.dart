//
//  DatabaseTypes.swift
//  MemriDatabase
//
//  Created by T Brennan on 13/11/20.
//

/// This type is used as an intermediate for storing and retrieving values from the database
/// It makes use of the dynamic schema to determine what type to resolve the data as.
enum PropertyDatabaseValueType {
  string, bool, int, double, datetime, blob
}

class PropertyDatabaseValue {
  final PropertyDatabaseValueType type;
  final value;

  PropertyDatabaseValue.string(String this.value) : type = PropertyDatabaseValueType.string;
  PropertyDatabaseValue.bool(bool this.value) : type = PropertyDatabaseValueType.bool;
  PropertyDatabaseValue.int(int this.value) : type = PropertyDatabaseValueType.int;
  PropertyDatabaseValue.double(double this.value) : type = PropertyDatabaseValueType.double;
  PropertyDatabaseValue.datetime(DateTime this.value) : type = PropertyDatabaseValueType.datetime;
  PropertyDatabaseValue.blob(String this.value) : type = PropertyDatabaseValueType.blob;

  String asString() {
    return value.toString();
  }

  double? asDouble() {
    return double.tryParse(value);
  }

  bool asBool() {
    String str = value.toString();//TODO find a better way to convert to bool @anijanyan
    return str != '0' && str != 'false' && str != '';
  }

  DateTime asDate() {
    return DateTime(int.parse(value) * 1000);
  }

  double? asCGFloat() {
    return double.tryParse(value);
  }
}