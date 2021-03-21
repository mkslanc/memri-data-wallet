//
//  ItemRecord.swift
//  MemriDatabase
//
//  Created by T Brennan on 21/12/20.
//


import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';

import 'ItemPropertyRecord.dart';

class ItemRecord {
  String uid;
  String type;
  late DateTime dateCreated;
  late DateTime dateModified;
  ItemRecord({required this.uid, required this.type});

  static ItemRecord? getWithUID(String itemUID, DatabaseController db) {
    return ItemRecord(uid: itemUID, type: "type");
  }

  ItemPropertyRecord? property(String name, DatabaseController? dbController/* = AppController.shared.databaseController*/) {
    return ItemPropertyRecord();
    // return ItemPropertyRecord.getOne(dbController, {
    // name: name,
    // itemUID: this.uid
    // }, this.type);
  }

  List<ItemPropertyRecord> properties(DatabaseController dbController/* = AppController.shared.databaseController*/) {
    return [];
    // return ItemPropertyRecord.getAll(dbController, {
    // itemUID: this.uid
    // }, this.type);
  }

  /*TODO PropertyDatabaseValue*/dynamic propertyValue(
      String name,
      DatabaseController? dbController// = AppController.shared.databaseController
  ) {
    // let property = this.property(name, dbController)
    // if (!property) { return undefined }
    // return property.value(this.type, dbController.schema)
  }

  setPropertyValue(String name, dynamic? value, DatabaseController? dbController) {

  }

  ItemRecord? edgeItem(String name, DatabaseController? dbController) {
    return null;
  }


  List<ItemRecord> edgeItems(String name, DatabaseController? dbController) {
    return [];
  }

  ItemRecord? reverseEdgeItem(String name, [DatabaseController? db]) {
    return null;
  }

  List<ItemRecord> reverseEdgeItems(String name, [DatabaseController? db]) {
    return [];
  }

  Binding<dynamic> propertyBinding({
    required String name,
    dynamic? defaultValue,
    DatabaseController? db,
    Type? type
  }) {
    // db ?= AppController.shared.databaseController
    switch (type) {
      case bool:
        return Binding<bool>(
          () => propertyValue(name, db)?.asBool() ?? defaultValue,
          (newValue) {
            setPropertyValue(name, /*new PropertyDatabaseValue.bool(newValue)*/ null, db);
          }
        );
      default:
        return Binding<String>(
          () => propertyValue(name, db)?.asString() ?? defaultValue.toString(),
          (newValue) {
            setPropertyValue(name, /*new PropertyDatabaseValue.bool(newValue)*/ null, db);
          }
        );
    }
  }
}