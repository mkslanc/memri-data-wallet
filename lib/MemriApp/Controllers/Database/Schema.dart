//
//  Schema.swift
//  MemriDatabase
//
//  Created by T Brennan on 30/11/20.
//

// MARK: SCHEMA STRUCTS

/// A schema definition. This is used to dynamically enforce supported types and properties
class Schema {
  ResolvedType? expectedType({String? itemType, String? propertyName, String? propertyOrEdgeName}) {
    return null;
  }
}

class ResolvedTypeProperty extends ResolvedType {
  final SchemaValueType value;

  ResolvedTypeProperty(this.value);
}

class ResolvedTypeEdge extends ResolvedType {
  final String value;

  ResolvedTypeEdge(this.value);
}

abstract class ResolvedType {}

enum SchemaValueType { string, bool, int, double, datetime, blob }
