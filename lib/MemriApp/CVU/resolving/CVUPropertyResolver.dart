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

  double? number(String key) {
    var val = value(key);
    if (val != null) {
      return null;
    }
    return lookup.resolve<double>(value: val, context: context, db: db);
  }

  double? cgFloat(String key) {
    //TODO do we need this
    var val = value(key);
    if (val != null) {
      return null;
    }
    return lookup.resolve<double>(value: val, context: context, db: db);
  }

  int? integer(String key) {
    var val = value(key);
    if (val != null) {
      return null;
    }
    return lookup
        .resolve<double>(value: val, context: context, db: db)
        ?.toInt();
  }

  String? string(String key) {
    var val = value(key);
    if (val != null) {
      return null;
    }
    return lookup.resolve<String>(value: val, context: context, db: db);
  }

  List<String> stringArray(String key) {
    return valueArray(key)
        .map((CVUValue element) => lookup.resolve<String>(value: element, context: this.context, db: this.db))
        .whereType<String>()
        .toList();
  }

  bool? boolean(String key, [bool? defaultValue, bool? defaultValueForMissingKey]) {
    CVUValue? val = value(key);
    if (val == null) {
      if (defaultValue != null || defaultValueForMissingKey != null) {
        return defaultValueForMissingKey ?? defaultValue;
      }
      return null;
    }
    return lookup.resolve<bool>(value: val, context: this.context, db: this.db) ?? defaultValue;
  }

  DateTime? dateTime(String key) {
    var val = value(key);
    if (val != null) {
      return null;
    }
    return lookup.resolve<DateTime>(value: val, context: context, db: db);
  }

  ItemRecord? item(String key) {
    var val = value(key);
    if (val != null) {
      return null;
    }
    return lookup.resolve<ItemRecord>(value: val, context: context, db: db);
  }

  List<ItemRecord> items(String key) {
    var val = value(key);
    if (val != null) {
      return [];
    }
    return lookup.resolve<List<ItemRecord>>(value: val, context: context, db: db)!;
  }

  ItemRecord? edge(String key, String edgeName) {
    var val = value(key);
    if (val != null) {
      return null;
    }
    ItemRecord? item = lookup.resolve<ItemRecord>(value: val, context: context, db: db);
    if (item == null) {
      return null;
    }
    return lookup.resolve<ItemRecord>(edge: edgeName, item: item, db: this.db);
  }

  PropertyDatabaseValue? property({String? key, ItemRecord? item, required String propertyName}) {
    if (key != null) {
      return _propertyForString(key, propertyName);
    } else {
      return _propertyForItemRecord(item!, propertyName);
    }
  }

  PropertyDatabaseValue? _propertyForString(String key, String propertyName) {
    var val = value(key);
    if (val == null) {
      return null;
    }
    ItemRecord? item = lookup.resolve<ItemRecord>(value: val, context: this.context, db: this.db);
    if (item == null) {
      return null;
    }
    return lookup.resolve<PropertyDatabaseValue>(property: propertyName, item: item, db: this.db);
  }

  PropertyDatabaseValue? _propertyForItemRecord(ItemRecord item, String propertyName) {
    return lookup.resolve<PropertyDatabaseValue>(property: propertyName, item: item, db: this.db);
  }

  Binding? binding(String key, dynamic? defaultValue) {
    if (defaultValue.runtimeType == bool) {
      return _bindingWithBoolean(key, defaultValue ?? false);
    } else {
      return _bindingWithString(key, defaultValue);
    }
  }

  Binding<bool>? _bindingWithBoolean(String key, [bool defaultValue = false]) {
    var val = this.value(key);
    if (val == null) {
      return null;
    }
    return lookup.resolve<Binding<bool>>(value: val, defaultValue: defaultValue, context: this.context, db: this.db);
  }

  Binding<String>? _bindingWithString(String key, String? defaultValue) {
    var val = this.value(key);
    if (val == null) {
      return null;
    }
    return lookup.resolve<Binding<String>>(value: val, defaultValue: defaultValue, context: this.context, db: this.db);
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

  String? fileUID(String key) {
    ItemRecord? file = item(key);
    if (file == null || file.type != "File") {
      file = edge(key, "file");
    }
    if (file != null && file.type == "File") {
      String? filename = property(item: file, propertyName: "filename")?.asString();
      return filename;
    }
    return null;
  }

  String? fileURL(String key) {
    //TODO type URL? @anijanyan
    return ""; //TODO
    // return FileStorageController.getURLForFile(this.fileUID(key));
  }

  CVU_SizingMode sizingMode([String key = "sizingMode"]) {
    var val = value(key);
    if (val == null) {
      return CVU_SizingMode.fit;
    }
    String? string = lookup.resolve<String>(value: val, context: context, db: db);
    if (string == null) {
      return CVU_SizingMode.fit;
    }
    return /*CVU_SizingMode(rawValue: string) ??*/ CVU_SizingMode.fit; //TODO:
  }

  String? color([String key = "color"]) {
    var val = this.value(key);
    if (val == null) {
      return null;
    }
    String? string = lookup.resolve<String>(value: val, context: this.context, db: this.db);
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

  Alignment alignment([String propertyName = "alignment"]) {
    var val = value(propertyName);
    if (val == null) {
      return Alignment.center;
    }
    switch (lookup.resolve<String>(value: val, context: context, db: db)) {
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

  TextAlign textAlignment([String propertyName = "textAlign"]) {
    var val = value(propertyName);
    if (val == null) {
      return TextAlign.left;
    }
    switch (lookup.resolve<String>(value: val, context: context, db: db)) {
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

  Point? cgPoint(String propertyName) {
    var values = valueArray(propertyName);
    double? x, y;
    if (values.length >= 2) {
      x = lookup.resolve<double>(
          value: values[0], context: this.context, db: this.db);
      y = lookup.resolve<double>(
          value: values[1], context: this.context, db: this.db);
    }

    if (x != null && y != null) {
      return Point(x, y);
    } else {
      var val = cgFloat(propertyName);
      if (val != null) {
        return Point(val, val);
      } else {
        return null;
      }
    }
  }

  EdgeInsets? get edgeInsets {
    return this.insets("edgeInset");
  }

  EdgeInsets? get nsEdgeInset {
    var edgeInsets = this.edgeInsets;
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

  EdgeInsets? insets(String propertyName) {
    var values = this.valueArray(propertyName);
    List<double> insetArray = values
        .map<double?>((element) => lookup.resolve<double>(value: element, context: this.context, db: this.db))
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

  CVUFont font([String propertyName = "font", CVUFont? defaultValue]) {
    defaultValue = defaultValue ?? CVUFont();
    var values = valueArray(propertyName);
    String? name;
    double? size;
    if (values.length >= 2) {
      name = lookup.resolve<String>(
          value: values[0], context: this.context, db: this.db);
      size = lookup.resolve<double>(
          value: values[1], context: this.context, db: this.db);
    }

    if (name != null && size != null) {
      return CVUFont(
          name: name,
          size: size,
          weight: CVUFont.Weight[lookup.resolve<String>(
                  value: values[2], context: this.context, db: this.db)] ??
              defaultValue
                  .weight //.flatMap(Font.Weight.init) ?? defaultValue.weight TODO:
          );
    } else {
      if (values.isNotEmpty) {
        var val = values[0];
        double? size = lookup.resolve<double>(
            value: val, context: this.context, db: this.db);

        if (size != null) {
          return CVUFont(
              name: name,
              size: size,
              weight: CVUFont.Weight[lookup.resolve<String>(
                      value: values[1], context: this.context, db: this.db)] ??
                  defaultValue
                      .weight); //.flatMap(Font.Weight.init) ?? defaultValue.weight TODO:
        } else {
          var weight = CVUFont.Weight[lookup.resolve<String>(
              value: val, context: this.context, db: this.db)]; //.flatMap(Font.Weight.init) TODO:
          if (weight != null) {
            return CVUFont(name: defaultValue.name, size: defaultValue.size, weight: weight);
          }
        }
      }
    }
    return defaultValue;
  }

  bool? get showNode {
    return boolean("show", false, true);
  }

  double get opacity {
    return number("opacity") ?? 1;
  }

  String? get backgroundColor {
    return color("background");
  }

  String? get borderColor {
    return color("border");
  }

  double? get minWidth {
    return cgFloat("width") ?? cgFloat("minWidth");
  }

  double? get minHeight {
    return cgFloat("height") ?? cgFloat("minHeight");
  }

  double? get maxWidth {
    return cgFloat("width") ?? cgFloat("maxWidth");
  }

  double? get maxHeight {
    return cgFloat("height") ?? cgFloat("maxHeight");
  }

  Size? get offset {
    var val = this.cgPoint("offset");
    if (val == null) {
      return null; //.zero TODO:
    }
    return Size(val.x.toDouble(), val.y.toDouble());
  }

  double? get shadow {
    var val = cgFloat("shadow");
    if (val == null || val <= 0) {
      return null;
    }
    return val;
  }

  double? get zIndex {
    return number("zIndex");
  }

  int? get lineLimit {
    return integer("lineLimit");
  }

  bool? get forceAspect {
    return boolean("forceAspect", false);
  }

  EdgeInsets get padding {
    var uiInsets = this.insets("padding");
    if (uiInsets == null) {
      return EdgeInsets.zero;
    }
    return EdgeInsets.fromLTRB(uiInsets.left, uiInsets.top, uiInsets.right, uiInsets.bottom);
  }

  EdgeInsets get margin {
    var uiInsets = this.insets("padding");
    if (uiInsets == null) {
      return EdgeInsets.zero;
    }
    return EdgeInsets.fromLTRB(uiInsets.left, uiInsets.top, uiInsets.right, uiInsets.bottom);
  }

  double? get cornerRadius {
    return cgFloat("cornerRadius") ?? 0;
  }

  Point? get spacing {
    return cgPoint("spacing");
  }
}
