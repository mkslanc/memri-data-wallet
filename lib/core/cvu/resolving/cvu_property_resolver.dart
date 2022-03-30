//  Created by T Brennan on 8/1/21.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/constants/cvu/cvu_color.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/controllers/cvu_lookup_controller.dart';
import 'package:memri/controllers/database_controller.dart';
import 'package:memri/controllers/file_storage/file_storage_controller.dart';
import 'package:memri/core/cvu/cvu_action.dart';
import 'package:memri/core/cvu/resolving/cvu_context.dart';
import 'package:memri/core/services/database/property_database_value.dart';
import 'package:memri/models/cvu/cvu_sizing_mode.dart';
import 'package:memri/models/cvu/cvu_value.dart';
import 'package:memri/models/cvu/cvu_value_constant.dart';
import 'package:memri/models/database/item_record.dart';
import 'package:memri/utils/binding.dart';
import 'package:memri/utils/extensions/collection.dart';

class CVUPropertyResolver {
  final CVUContext context;
  final CVULookupController lookup;
  final DatabaseController db;
  final Map<String, CVUValue> properties;

  CVUPropertyResolver(
      {required this.context, required this.lookup, required this.db, required this.properties});

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

  List<CVUPropertyResolver> subdefinitionArray(String key) {
    CVUValue? value = properties[key];
    if (value == null) {
      return [];
    }
    return valueArray(key).compactMap((item) {
      if (item is! CVUValueSubdefinition) return null;
      return CVUPropertyResolver(
          context: this.context,
          lookup: this.lookup,
          db: this.db,
          properties: item.value.properties);
    });
  }

  CVUPropertyResolver? subdefinition(String key) {
    CVUValue? value = properties[key];
    if (value == null || value is! CVUValueSubdefinition) {
      return null;
    }
    return CVUPropertyResolver(
        context: this.context,
        lookup: this.lookup,
        db: this.db,
        properties: value.value.properties);
  }

  Future<double?> number(String key) async {
    var val = value(key);
    if (val == null) {
      return null;
    }
    return await lookup.resolve<double>(value: val, context: context, db: db);
  }

  Future<double?> cgFloat(String key) async {
    //TODO do we need this
    var val = value(key);
    if (val == null) {
      return null;
    }
    return await lookup.resolve<double>(value: val, context: context, db: db);
  }

  Future<int?> integer(String key) async {
    var val = value(key);
    if (val == null) {
      return null;
    }
    return (await lookup.resolve<double>(value: val, context: context, db: db))?.toInt();
  }

  int? syncInteger(String key) {
    var val = value(key);
    if (val == null) {
      return null;
    }
    if (val is CVUValueConstant) {
      if (val.value is CVUConstantNumber) {
        return val.value.value.toInt();
      }
    }
    return null;
  }

  Future<String?> string(String key) async {
    var val = value(key);
    if (val == null) {
      return null;
    }
    return await lookup.resolve<String>(value: val, context: context, db: db);
  }

  Future<String?> resolveString(CVUValue? val) async {
    if (val == null) {
      return null;
    }
    return await lookup.resolve<String>(value: val, context: context, db: db);
  }

  Future<List<String>> stringArray(String key) async {
    return (await Future.wait(valueArray(key).map((CVUValue element) async =>
            await lookup.resolve<String>(value: element, context: this.context, db: this.db))))
        .whereType<String>()
        .toList();
  }

  List<String> syncStringArray(String key) => resolveStringArray(valueArray(key));

  List<String> resolveStringArray(List<CVUValue> value) {
    return value.compactMap((val) {
      if (val is CVUValueConstant) {
        if (val.value is CVUConstantString || val.value is CVUConstantArgument) {
          return val.value.value.toString();
        }
      }
      return null;
    });
  }

  Future<List<int>> intArray(String key) async {
    return (await Future.wait(valueArray(key).map((CVUValue element) async =>
            await lookup.resolve<int>(value: element, context: this.context, db: this.db))))
        .whereType<int>()
        .toList();
  }

  Future<List<double>> numberArray(String key) async {
    return (await Future.wait(valueArray(key).map((CVUValue element) async =>
            await lookup.resolve<double>(value: element, context: this.context, db: this.db))))
        .whereType<double>()
        .toList();
  }

  Future<bool?> boolean(String key, [bool? defaultValue, bool? defaultValueForMissingKey]) async {
    CVUValue? val = value(key);
    if (val == null) {
      if (defaultValue != null || defaultValueForMissingKey != null) {
        return defaultValueForMissingKey ?? defaultValue;
      }
      return null;
    }
    return await lookup.resolve<bool>(value: val, context: this.context, db: this.db) ??
        defaultValue;
  }

  bool? syncBoolean(String key, [bool? defaultValue, bool? defaultValueForMissingKey]) {
    var val = value(key);
    if (val == null) {
      if (defaultValue != null || defaultValueForMissingKey != null) {
        return defaultValueForMissingKey ?? defaultValue;
      }
      return null;
    }
    if (val is CVUValueConstant) {
      if (val.value is CVUConstantBool) {
        return val.value.value;
      }
    }
    return defaultValue;
  }

  Future<DateTime?> dateTime(String key) async {
    var val = value(key);
    if (val == null) {
      return null;
    }
    return await lookup.resolve<DateTime>(value: val, context: context, db: db);
  }

  Future<ItemRecord?> item(String key) async {
    var val = value(key);
    if (val == null) {
      return null;
    }
    return await lookup.resolve<ItemRecord>(value: val, context: context, db: db);
  }

  Future<List<ItemRecord>> items(String key) async {
    var val = value(key);
    if (val == null) {
      return [];
    }
    return (await lookup.resolve<List>(
        value: val, context: context, db: db, additionalType: ItemRecord)) as List<ItemRecord>;
  }

  Future<ItemRecord?> edge(String key, String edgeName) async {
    var val = value(key);
    if (val == null) {
      return null;
    }
    ItemRecord? item = await lookup.resolve<ItemRecord>(value: val, context: context, db: db);
    if (item == null) {
      return null;
    }
    return await lookup.resolve<ItemRecord>(edge: edgeName, item: item, db: this.db);
  }

  Future<PropertyDatabaseValue?> property(
      {String? key, ItemRecord? item, required String propertyName}) async {
    if (key != null) {
      return await _propertyForString(key, propertyName);
    } else {
      return await _propertyForItemRecord(item!, propertyName);
    }
  }

  Future<PropertyDatabaseValue?> _propertyForString(String key, String propertyName) async {
    var val = value(key);
    if (val == null) {
      return null;
    }
    ItemRecord? item =
        await lookup.resolve<ItemRecord>(value: val, context: this.context, db: this.db);
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

  Future<FutureBinding<T>?> binding<T>(String key, [T? defaultValue]) async {
    if (T == bool) {
      return await _bindingWithBoolean(key, defaultValue != null ? defaultValue as bool : false)
          as FutureBinding<T>?;
    } else {
      return await _bindingWithString(key, defaultValue?.toString()) as FutureBinding<T>?;
    }
  }

  Future<FutureBinding<bool>?> _bindingWithBoolean(String key, [bool defaultValue = false]) async {
    var val = this.value(key);
    if (val == null) {
      return null;
    }
    return await lookup.resolve<FutureBinding>(
        value: val,
        defaultValue: defaultValue,
        context: this.context,
        db: this.db,
        additionalType: bool) as FutureBinding<bool>?;
  }

  Future<FutureBinding<String>?> _bindingWithString(String key, String? defaultValue) async {
    var val = value(key);
    if (val == null) {
      return null;
    }
    return await lookup.resolve<FutureBinding>(
        value: val,
        defaultValue: defaultValue,
        context: this.context,
        db: this.db,
        additionalType: String) as FutureBinding<String>?;
  }

  List<CVUAction>? actions(String key) {
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
        return [type()];
      }
    }
    if (val is CVUValueArray) {
      var array = val.value;
      List<CVUAction> actions = [];
      //TODO: hasSubDefinition? Need some use cases
      for (var i = 0; i < array.length; i++) {
        var action = array[i];
        if (action is CVUValueConstant) {
          if (action.value is CVUConstantArgument) {
            var type = cvuAction((action.value as CVUConstantArgument).value);
            if (type == null) {
              continue;
            }
            Map<String, CVUValue> vars = {};
            var def = array.asMap()[i + 1];
            if (def is CVUValueSubdefinition) {
              var keys = def.value.properties.keys;
              for (var key in keys) {
                var value = context.viewArguments?.args[key] ??
                    context.viewArguments?.parentArguments?.args[key] ??
                    def.value.properties[key];
                if (value != null) {
                  vars[key] = value;
                }
              }
            }
            actions.add(type(vars: vars));
          } else {
            continue;
          }
        } else {
          continue;
        }
      }
      return actions;
    }
    return null;
  }

  CVUAction? action(String key, [CVUValue? optional]) {
    var val = value(key) ?? optional;
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
        return type();
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
      String? filename = (await property(item: file, propertyName: "sha256"))?.asString();
      return filename;
    }
    return null;
  }

  Future<String?> fileURL(String key) async {
    var uuid = await fileUID(key);
    if (uuid == null) return null;
    return FileStorageController.getURLForFile(uuid);
  }

  Future<CVU_SizingMode> sizingMode([String key = "sizingMode"]) async {
    var val = value(key);
    if (val == null) {
      return CVU_SizingMode.fit;
    }
    String? string = await lookup.resolve<String>(value: val, context: context, db: db);
    if (string == null) {
      return CVU_SizingMode.fit;
    }

    return string == "fill" ? CVU_SizingMode.fill : CVU_SizingMode.fit;
  }

  Future<Color?> color([String key = "color"]) async {
    var val = this.value(key);
    if (val == null) {
      return null;
    }
    String? string = await lookup.resolve<String>(value: val, context: this.context, db: this.db);
    if (string == null) {
      return null;
    }
    var predefined = CVUColor.predefined[string];
    if (predefined != null) {
      return predefined;
    }
    return CVUColor(color: string).value;
  }

  Future<AlignmentResolver> alignment(String alignType, [String propertyName = "alignment"]) async {
    var val = value(propertyName);
    if (val == null) {
      return AlignmentResolver(
          mainAxis: MainAxisAlignment.center, crossAxis: CrossAxisAlignment.center);
    }
    if (alignType == "row") {
      switch (await lookup.resolve<String>(value: val, context: context, db: db)) {
        case "left":
        case "leading":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.start, crossAxis: CrossAxisAlignment.center);
        case "top":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.start, crossAxis: CrossAxisAlignment.start);
        case "right":
        case "trailing":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.end, crossAxis: CrossAxisAlignment.center);
        case "bottom":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.start, crossAxis: CrossAxisAlignment.end);
        case "center":
        case "centre":
        case "middle":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.center, crossAxis: CrossAxisAlignment.center);
        case "lefttop":
        case "topleft":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.start, crossAxis: CrossAxisAlignment.start);
        case "righttop":
        case "topright":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.end, crossAxis: CrossAxisAlignment.start);
        case "leftbottom":
        case "bottomleft":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.start, crossAxis: CrossAxisAlignment.end);
        case "rightbottom":
        case "bottomright":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.end, crossAxis: CrossAxisAlignment.end);
        case "topspacebetween":
        case "spacebetweentop":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.spaceBetween, crossAxis: CrossAxisAlignment.start);
        case "bottomspacebetween":
        case "spacebetweenbottom":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.spaceBetween, crossAxis: CrossAxisAlignment.end);
        case "spacebetween":
        case "centerspacebetween":
        case "spacebetweencenter":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.spaceBetween, crossAxis: CrossAxisAlignment.center);
        default:
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.center, crossAxis: CrossAxisAlignment.center);
      }
    } else {
      switch (await lookup.resolve<String>(value: val, context: context, db: db)) {
        case "left":
        case "leading":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.center, crossAxis: CrossAxisAlignment.start);
        case "top":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.start, crossAxis: CrossAxisAlignment.center);
        case "right":
        case "trailing":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.center, crossAxis: CrossAxisAlignment.end);
        case "bottom":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.end, crossAxis: CrossAxisAlignment.start);
        case "center":
        case "centre":
        case "middle":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.center, crossAxis: CrossAxisAlignment.center);
        case "lefttop":
        case "topleft":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.start, crossAxis: CrossAxisAlignment.start);
        case "righttop":
        case "topright":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.start, crossAxis: CrossAxisAlignment.end);
        case "leftbottom":
        case "bottomleft":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.end, crossAxis: CrossAxisAlignment.start);
        case "rightbottom":
        case "bottomright":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.end, crossAxis: CrossAxisAlignment.end);
        case "leftspacebetween":
        case "spacebetweenleft":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.spaceBetween, crossAxis: CrossAxisAlignment.start);
        case "rightspacebetween":
        case "spacebetweenright":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.spaceBetween, crossAxis: CrossAxisAlignment.end);
        case "spacebetween":
        case "centerspacebetween":
        case "spacebetweencenter":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.spaceBetween, crossAxis: CrossAxisAlignment.center);
        default:
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.center, crossAxis: CrossAxisAlignment.center);
      }
    }
  }

  Future<Alignment> alignmentForStack([String propertyName = "alignment"]) async {
    var val = value(propertyName);
    if (val == null) {
      return Alignment.center;
    }
    switch (await lookup.resolve<String>(value: val, context: context, db: db)) {
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
        return Alignment.topLeft;
    }
  }

  Future<TextAlign> textAlignment([String propertyName = "textAlign"]) async {
    var val = value(propertyName);
    if (val == null) {
      return TextAlign.left;
    }
    switch (await lookup.resolve<String>(value: val, context: context, db: db)) {
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
      x = await lookup.resolve<double>(value: values[0], context: this.context, db: this.db);
      y = await lookup.resolve<double>(value: values[1], context: this.context, db: this.db);
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
    List<double> insetArray = (await Future.wait(values.map<Future<double?>>((element) async =>
            await lookup.resolve<double>(value: element, context: this.context, db: this.db))))
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
    return null;
  }

  Future<CVUFont> font([String propertyName = "font", CVUFont? defaultValue]) async {
    defaultValue = defaultValue ?? CVUFont();
    var values = valueArray(propertyName);
    String? name;
    double? size;
    if (values.length >= 2) {
      name = await lookup.resolve<String>(value: values[1], context: this.context, db: this.db);
      size = await lookup.resolve<double>(value: values[0], context: this.context, db: this.db);
    }

    if (name != null && size != null) {
      var weight =
          await lookup.resolve<String>(value: values[1], context: this.context, db: this.db);
      return CVUFont(size: size, weight: CVUFont.Weight[weight] ?? defaultValue.weight);
    } else {
      if (values.isNotEmpty) {
        var val = values[0];
        String? defaultStyle =
            await lookup.resolve<String>(value: val, context: this.context, db: this.db);
        if (defaultStyle != null && CVUFont.predefined[defaultStyle] != null) {
          return CVUFont.predefined[defaultStyle]!;
        } else {
          double? size =
              await lookup.resolve<double>(value: val, context: this.context, db: this.db);
          if (size != null) {
            return CVUFont(
                name: name,
                size: size,
                weight: CVUFont.Weight[await lookup.resolve<String>(
                        value: values[0], context: this.context, db: this.db)] ??
                    defaultValue.weight);
          } else {
            var weight = CVUFont.Weight[
                await lookup.resolve<String>(value: val, context: this.context, db: this.db)];
            if (weight != null) {
              return CVUFont(name: defaultValue.name, size: defaultValue.size, weight: weight);
            }
          }
        }
      }
    }
    return defaultValue;
  }

  Future<T?> style<T>({required StyleType type}) async {
    switch (type) {
      case StyleType.button:
        var styleName = await string("styleName");
        if (styleName != null && buttonStyles[styleName] != null) {
          return buttonStyles[styleName] as T;
        }
    }
    return null;
  }

  Future<bool> get showNode async {
    return (await boolean("show", false, true))!; //TODO boolean function type @anijanyan
  }

  Future<double> get opacity async {
    return await number("opacity") ?? 1;
  }

  Future<Color?> get backgroundColor async {
    return await color("background");
  }

  Future<Color?> get borderColor async {
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

  Future<Offset> get offset async {
    var val = await cgPoint("offset");
    if (val == null) {
      return Offset.zero;
    }
    return Offset(val.x.toDouble(), val.y.toDouble());
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
    return EdgeInsets.fromLTRB(uiInsets.left, uiInsets.top, uiInsets.right, uiInsets.bottom);
  }

  Future<EdgeInsets> get margin async {
    var uiInsets = await this.insets("padding");
    if (uiInsets == null) {
      return EdgeInsets.zero;
    }
    return EdgeInsets.fromLTRB(uiInsets.left, uiInsets.top, uiInsets.right, uiInsets.bottom);
  }

  Future<double> get cornerRadius async {
    return await cgFloat("cornerRadius") ?? 0;
  }

  Future<List<double>> get cornerRadiusOnly async {
    var values = await numberArray("cornerRadiusOnly");
    if (values.isNotEmpty && values.length != 4) {
      if (values.length == 1) {
        values.fillRange(1, 4, values[0]);
      } else if (values.length == 2) {
        values.addAll(values);
      } else {
        values.add(0);
      }
    }
    return values;
  }

  Future<Point?> get spacing async {
    return await cgPoint("spacing");
  }
}

class AlignmentResolver {
  MainAxisAlignment mainAxis;
  CrossAxisAlignment crossAxis;

  AlignmentResolver({required this.mainAxis, required this.crossAxis});
}

enum StyleType { button }
