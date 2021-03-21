//
//  Schema.swift
//  MemriDatabase
//
//  Created by T Brennan on 30/11/20.
//

// MARK: SCHEMA STRUCTS

/// A schema definition. This is used to dynamically enforce supported types and properties
class Schema {
  dynamic? expectedType({String? itemType, String? propertyName, String? propertyOrEdgeName}) {
    return null;
  }
}

enum ResolvedTypeType { property, edge }

class ResolvedType {
  final ResolvedTypeType type;
  final dynamic value;

  ResolvedType.property(SchemaValueType this.value) : type = ResolvedTypeType.property;

  ResolvedType.edge(String this.value) : type = ResolvedTypeType.edge;
}

enum SchemaValueType { string, bool, int, double, datetime, blob }
