//
//  CVUPropertyResolver.swift
//  MemriDatabase
//
//  Created by T Brennan on 8/1/21.
//

import 'dart:math';

import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUFont.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVU_Other.dart';
import 'package:flutter/material.dart';

import 'CVUContext.dart';
import 'CVULookupController.dart';

class CVUPropertyResolver {
  final CVUContext context;
  final CVULookupController lookup;
  final DatabaseController db;
  final Map<String, CVUValue> properties;

  CVUPropertyResolver({required this.context, required this.lookup, required this.db, required this.properties});

  CVUPropertyResolver replacingItem(ItemRecord item) {
    CVUPropertyResolver result = this;
    result.context.currentItem = item;
    return result;
  }

  CVUValue? value(String key) {
    return properties[key];
  }

  List<CVUValue> valueArray(String key) {
    CVUValue? value = properties[key];
    if (value == null) {
      return [];
    }
    if (value is! CVUValueArray) {
      return [value];
    }

    return value.value;
  }

  CVUPropertyResolver? subdefinition(String key) {
    CVUValue? value = properties[key];
    if (value == null || value is! CVUValueSubdefinition) {
      return null;
    }
    return CVUPropertyResolver(
        context: this.context, lookup: this.lookup, db: this.db, properties: value.value.properties);
  }

  Future<double?> number(String key) async {
    var val = value(key);
    if (val != null) {
      return null;
    }
    return await lookup.resolve<double>(value: val, context: context, db: db);
  }

  Future<double?> cgFloat(String key) async {
    //TODO do we need this
    var val = value(key);
    if (val != null) {
      return null;
    }
    return await lookup.resolve<double>(value: val, context: context, db: db);
  }

  Future<int?> integer(String key) async {
    var val = value(key);
    if (val != null) {
      return null;
    }
    return (await lookup.resolve<double>(value: val, context: context, db: db))
        ?.toInt();
  }

  Future<String?> string(String key) async {
    var val = value(key);
    if (val != null) {
      return null;
    }
    return await lookup.resolve<String>(value: val, context: context, db: db);
  }

  Future<List<String>> stringArray(String key) async {
    return (await Future.wait(valueArray(key).map((CVUValue element) async =>
            await lookup.resolve<String>(
                value: element, context: this.context, db: this.db))))
        .whereType<String>()
        .toList();
  }

  Future<bool?> boolean(String key,
      [bool? defaultValue, bool? defaultValueForMissingKey]) async {
    CVUValue? val = value(key);
    if (val == null) {
      if (defaultValue != null || defaultValueForMissingKey != null) {
        return defaultValueForMissingKey ?? defaultValue;
      }
      return null;
    }
    return await lookup.resolve<bool>(
            value: val, context: this.context, db: this.db) ??
        defaultValue;
  }

  Future<DateTime?> dateTime(String key) async {
    var val = value(key);
    if (val != null) {
      return null;
    }
    return await lookup.resolve<DateTime>(value: val, context: context, db: db);
  }

  Future<ItemRecord?> item(String key) async {
    var val = value(key);
    if (val != null) {
      return null;
    }
    return await lookup.resolve<ItemRecord>(
        value: val, context: context, db: db);
  }

  Future<List<ItemRecord>> items(String key) async {
    var val = value(key);
    if (val != null) {
      return [];
    }
    return (await lookup.resolve<List<ItemRecord>>(
        value: val, context: context, db: db))!;
  }

  Future<ItemRecord?> edge(String key, String edgeName) async {
    var val = value(key);
    if (val != null) {
      return null;
    }
    ItemRecord? item =
        await lookup.resolve<ItemRecord>(value: val, context: context, db: db);
    if (item == null) {
      return null;
    }
    return await lookup.resolve<ItemRecord>(
        edge: edgeName, item: item, db: this.db);
  }

  Future<PropertyDatabaseValue?> property(
      {String? key, ItemRecord? item, required String propertyName}) async {
    if (key != null) {
      return await _propertyForString(key, propertyName);
    } else {
      return await _propertyForItemRecord(item!, propertyName);
    }
  }

  Future<PropertyDatabaseValue?> _propertyForString(
      String key, String propertyName) async {
    var val = value(key);
    if (val == null) {
      return null;
    }
    ItemRecord? item = await lookup.resolve<ItemRecord>(
        value: val, context: this.context, db: this.db);
    if (item == null) {
      return null;
    }
    return await lookup.resolve<PropertyDatabaseValue>(
        property: propertyName, item: item, db: this.db);
  }

  Future<PropertyDatabaseValue?> _propertyForItemRecord(
      ItemRecord item, String propertyName) async {
    return await lookup.resolve<PropertyDatabaseValue>(
        property: propertyName, item: item, db: this.db);
  }

  Future<Binding?> binding(String key, dynamic? defaultValue) async {
    if (defaultValue.runtimeType == bool) {
      return await _bindingWithBoolean(key, defaultValue ?? false);
    } else {
      return await _bindingWithString(key, defaultValue);
    }
  }

  Future<Binding<bool>?> _bindingWithBoolean(String key,
      [bool defaultValue = false]) async {
    var val = this.value(key);
    if (val == null) {
      return null;
    }
    return await lookup.resolve<Binding<bool>>(
        value: val,
        defaultValue: defaultValue,
        context: this.context,
        db: this.db);
  }

  Future<Binding<String>?> _bindingWithString(
      String key, String? defaultValue) async {
    var val = this.value(key);
    if (val == null) {
      return null;
    }
    return await lookup.resolve<Binding<String>>(
        value: val,
        defaultValue: defaultValue,
        context: this.context,
        db: this.db);
  }

  CVUAction? action(String key) {
    var val = value(key);
    if (val == null) {
      return null;
    }
    if (val is CVUValueConstant) {
      if (val.value is CVUConstantArgument) {
        String actionName = (val.value as CVUConstantArgument).value;
        var type = cvuAction(actionName);
        if (type == null) {
          return null;
        }
        return type(vars: {});
      } else {
        return null;
      }
    } else if (val is CVUValueArray) {
      var array = val.value;
      if (array[0] is! CVUValueConstant || array[1] is! CVUValueSubdefinition) {
        return null;
      }
      var argument = (array[0] as CVUValueConstant).value;
      if (argument is! CVUConstantArgument) {
        return null;
      }
      String actionName = argument.value;
      var def = (array[1] as CVUValueSubdefinition).value;
      var type = cvuAction(actionName);
      if (type == null) {
        return null;
      }
      return type(vars: def.properties);
    } else {
      return null;
    }
  }

  Future<String?> fileUID(String key) async {
    ItemRecord? file = await item(key);
    if (file == null || file.type != "File") {
      file = await edge(key, "file");
    }
    if (file != null && file.type == "File") {
      String? filename =
          (await property(item: file, propertyName: "filename"))?.asString();
      return filename;
    }
    return null;
  }

  String? fileURL(String key) {
    //TODO type URL? @anijanyan
    return ""; //TODO
    // return FileStorageController.getURLForFile(this.fileUID(key));
  }

  Future<CVU_SizingMode> sizingMode([String key = "sizingMode"]) async {
    var val = value(key);
    if (val == null) {
      return CVU_SizingMode.fit;
    }
    String? string =
        await lookup.resolve<String>(value: val, context: context, db: db);
    if (string == null) {
      return CVU_SizingMode.fit;
    }
    return /*CVU_SizingMode(rawValue: string) ??*/ CVU_SizingMode.fit; //TODO:
  }

  Future<String?> color([String key = "color"]) async {
    var val = this.value(key);
    if (val == null) {
      return null;
    }
    String? string = await lookup.resolve<String>(
        value: val, context: this.context, db: this.db);
    if (string == null) {
      return null;
    }
    return string;
    //TODO @anijanyan
    /*if (Color.named(string)) {
      return Color.named(string)
    } else {
      return Color.hex(string)
    }*/
  }

  Future<Alignment> alignment([String propertyName = "alignment"]) async {
    var val = value(propertyName);
    if (val == null) {
      return Alignment.center;
    }
    switch (
        await lookup.resolve<String>(value: val, context: context, db: db)) {
      case "left":
      case "leading":
        return Alignment.centerLeft;
      case "top":
        return Alignment.topCenter;
      case "right":
      case "trailing":
        return Alignment.centerRight;
      case "bottom":
        return Alignment.bottomCenter;
      case "center":
      case "centre":
      case "middle":
        return Alignment.center;
      case "lefttop":
      case "topleft":
        return Alignment.topLeft;
      case "righttop":
      case "topright":
        return Alignment.topRight;
      case "leftbottom":
      case "bottomleft":
        return Alignment.bottomLeft;
      case "rightbottom":
      case "bottomright":
        return Alignment.bottomRight;
      default:
        return Alignment.center;
    }
  }

  Future<TextAlign> textAlignment([String propertyName = "textAlign"]) async {
    var val = value(propertyName);
    if (val == null) {
      return TextAlign.left;
    }
    switch (
        await lookup.resolve<String>(value: val, context: context, db: db)) {
      case "left":
      case "leading":
        return TextAlign.left;
      case "right":
      case "trailing":
        return TextAlign.right;
      case "center":
      case "middle":
        return TextAlign.center;
      default:
        return TextAlign.left;
    }
  }

  Future<Point?> cgPoint(String propertyName) async {
    var values = valueArray(propertyName);
    double? x, y;
    if (values.length >= 2) {
      x = await lookup.resolve<double>(
          value: values[0], context: this.context, db: this.db);
      y = await lookup.resolve<double>(
          value: values[1], context: this.context, db: this.db);
    }

    if (x != null && y != null) {
      return Point(x, y);
    } else {
      var val = await cgFloat(propertyName);
      if (val != null) {
        return Point(val, val);
      } else {
        return null;
      }
    }
  }

  Future<EdgeInsets?> get edgeInsets async {
    return await this.insets("edgeInset");
  }

  Future<EdgeInsets?> get nsEdgeInset async {
    var edgeInsets = await this.edgeInsets;
    if (edgeInsets == null) {
      return null;
    }
    return edgeInsets; //TODO do we need this? @anijanyan
    /*return {
      top: edgeInsets.top,
      left: edgeInsets.left,
      bottom: edgeInsets.bottom,
      right: edgeInsets.right
    };*/
  }

  Future<EdgeInsets?> insets(String propertyName) async {
    var values = this.valueArray(propertyName);
    List<double> insetArray = (await Future.wait(values.map<Future<double?>>(
            (element) async => await lookup.resolve<double>(
                value: element, context: this.context, db: this.db))))
        .whereType<double>()
        .toList();
    if (insetArray.length > 0) {
      switch (insetArray.length) {
        case 2:
          return EdgeInsets.symmetric(
            vertical: (insetArray[1]),
            horizontal: (insetArray[0]),
          );
        case 4:
          return EdgeInsets.fromLTRB(
            insetArray[3],
            insetArray[0],
            insetArray[1],
            insetArray[2],
          );
        case 1:
          double edgeInset = insetArray[0];
          return EdgeInsets.all(edgeInset);
        default:
          return null;
      }
    }
  }

  Future<CVUFont> font(
      [String propertyName = "font", CVUFont? defaultValue]) async {
    defaultValue = defaultValue ?? CVUFont();
    var values = valueArray(propertyName);
    String? name;
    double? size;
    if (values.length >= 2) {
      name = await lookup.resolve<String>(
          value: values[0], context: this.context, db: this.db);
      size = await lookup.resolve<double>(
          value: values[1], context: this.context, db: this.db);
    }

    if (name != null && size != null) {
      return CVUFont(
          name: name,
          size: size,
          weight: CVUFont.Weight[await lookup.resolve<String>(
                  value: values[2], context: this.context, db: this.db)] ??
              defaultValue
                  .weight //.flatMap(Font.Weight.init) ?? defaultValue.weight TODO:
          );
    } else {
      if (values.isNotEmpty) {
        var val = values[0];
        double? size = await lookup.resolve<double>(
            value: val, context: this.context, db: this.db);

        if (size != null) {
          return CVUFont(
              name: name,
              size: size,
              weight: CVUFont.Weight[await lookup.resolve<String>(
                      value: values[1], context: this.context, db: this.db)] ??
                  defaultValue
                      .weight); //.flatMap(Font.Weight.init) ?? defaultValue.weight TODO:
        } else {
          var weight = CVUFont.Weight[await lookup.resolve<String>(
              value: val,
              context: this.context,
              db: this.db)]; //.flatMap(Font.Weight.init) TODO:
          if (weight != null) {
            return CVUFont(
                name: defaultValue.name,
                size: defaultValue.size,
                weight: weight);
          }
        }
      }
    }
    return defaultValue;
  }

  Future<bool?> get showNode async {
    return await boolean("show", false, true);
  }

  Future<double> get opacity async {
    return await number("opacity") ?? 1;
  }

  Future<String?> get backgroundColor async {
    return await color("background");
  }

  Future<String?> get borderColor async {
    return await color("border");
  }

  Future<double?> get minWidth async {
    return await cgFloat("width") ?? await cgFloat("minWidth");
  }

  Future<double?> get minHeight async {
    return await cgFloat("height") ?? await cgFloat("minHeight");
  }

  Future<double?> get maxWidth async {
    return await cgFloat("width") ?? await cgFloat("maxWidth");
  }

  Future<double?> get maxHeight async {
    return await cgFloat("height") ?? await cgFloat("maxHeight");
  }

  Future<Size?> get offset async {
    var val = await this.cgPoint("offset");
    if (val == null) {
      return null; //.zero TODO:
    }
    return Size(val.x.toDouble(), val.y.toDouble());
  }

  Future<double?> get shadow async {
    var val = await cgFloat("shadow");
    if (val == null || val <= 0) {
      return null;
    }
    return val;
  }

  Future<double?> get zIndex async {
    return await number("zIndex");
  }

  Future<int?> get lineLimit async {
    return await integer("lineLimit");
  }

  Future<bool?> get forceAspect async {
    return await boolean("forceAspect", false);
  }

  Future<EdgeInsets> get padding async {
    var uiInsets = await this.insets("padding");
    if (uiInsets == null) {
      return EdgeInsets.zero;
    }
    return EdgeInsets.fromLTRB(
        uiInsets.left, uiInsets.top, uiInsets.right, uiInsets.bottom);
  }

  Future<EdgeInsets> get margin async {
    var uiInsets = await this.insets("padding");
    if (uiInsets == null) {
      return EdgeInsets.zero;
    }
    return EdgeInsets.fromLTRB(
        uiInsets.left, uiInsets.top, uiInsets.right, uiInsets.bottom);
  }

  Future<double?> get cornerRadius async {
    return await cgFloat("cornerRadius") ?? 0;
  }

  Future<Point?> get spacing async {
    return await cgPoint("spacing");
  }
}
