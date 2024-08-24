//  Created by T Brennan on 8/1/21.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/core/models/item.dart';
import 'package:memri/cvu/constants/cvu_color.dart';
import 'package:memri/cvu/constants/cvu_font.dart';
import 'package:memri/cvu/controllers/cvu_lookup_controller.dart';
import 'package:memri/core/controllers/file_storage/file_storage_controller.dart';
import 'package:memri/cvu/services/cvu_action.dart';
import 'package:memri/cvu/models/cvu_sizing_mode.dart';
import 'package:memri/core/services/database/property_database_value.dart';
import 'package:memri/cvu/models/cvu_value.dart';
import 'package:memri/cvu/models/cvu_value_constant.dart';
import 'package:memri/utilities/extensions/collection.dart';

import 'cvu_context.dart';

class CVUPropertyResolver {
  final CVUContext context;
  final CVULookupController lookup;
  final Map<String, CVUValue> properties;

  CVUPropertyResolver(
      {required this.context, required this.lookup, required this.properties});

  CVUPropertyResolver replacingItem(Item item) {
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
        properties: value.value.properties);
  }

  double? number(String key) {
    var val = value(key);
    if (val == null) {
      return null;
    }
    return lookup.resolve<double>(value: val, context: context);
  }

  double? cgFloat(String key) {
    //TODO do we need this
    var val = value(key);
    if (val == null) {
      return null;
    }
    return lookup.resolve<double>(value: val, context: context);
  }

  int? integer(String key) {
    var val = value(key);
    if (val == null) {
      return null;
    }
    return (lookup.resolve<double>(value: val, context: context))?.toInt();
  }

  String? string(String key) {
    var val = value(key);
    if (val == null) {
      return null;
    }
    return lookup.resolve<String>(value: val, context: context);
  }

  List<String> stringArray(String key) {
    return valueArray(key).compactMap((CVUValue element) =>
        lookup.resolve<String>(value: element, context: this.context));
  }

  List<int> intArray(String key) {
    return valueArray(key).compactMap((CVUValue element) =>
        lookup.resolve<int>(value: element, context: this.context));
  }

  List<double> numberArray(String key) {
    return valueArray(key).compactMap((CVUValue element) =>
        lookup.resolve<double>(value: element, context: this.context));
  }

  bool? boolean(String key,
      [bool? defaultValue, bool? defaultValueForMissingKey]) {
    CVUValue? val = value(key);
    if (val == null) {
      if (defaultValue != null || defaultValueForMissingKey != null) {
        return defaultValueForMissingKey ?? defaultValue;
      }
      return null;
    }
    return lookup.resolve<bool>(value: val, context: this.context) ??
        defaultValue;
  }

  DateTime? dateTime(String key) {
    var val = value(key);
    if (val == null) {
      return null;
    }
    return lookup.resolve<DateTime>(value: val, context: context);
  }

  Item? item(String key) {
    var val = value(key);
    if (val == null) {
      return null;
    }
    return lookup.resolve<Item>(value: val, context: context);
  }

  List<Item> items(String key) {
    var val = value(key);
    if (val == null) {
      return [];
    }
    return (lookup.resolve<List>(
        value: val, context: context, additionalType: Item)) as List<Item>;
  }

  Item? edge(String key, String edgeName) {
    var val = value(key);
    if (val == null) {
      return null;
    }
    Item? item = lookup.resolve<Item>(value: val, context: context);
    if (item == null) {
      return null;
    }
    return lookup.resolve<Item>(edge: edgeName, item: item);
  }

  PropertyDatabaseValue? property(
      {String? key, Item? item, required String propertyName}) {
    if (key != null) {
      return _propertyForString(key, propertyName);
    } else {
      return _propertyForItem(item!, propertyName);
    }
  }

  PropertyDatabaseValue? _propertyForString(String key, String propertyName) {
    var val = value(key);
    if (val == null) {
      return null;
    }
    Item? item = lookup.resolve<Item>(value: val, context: this.context);
    if (item == null) {
      return null;
    }
    return lookup.resolve<PropertyDatabaseValue>(
        property: propertyName, item: item);
  }

  PropertyDatabaseValue? _propertyForItem(Item item, String propertyName) {
    return lookup.resolve<PropertyDatabaseValue>(
        property: propertyName, item: item);
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
                //TODO priorities seem to be broken, properties should be checked first
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

  String? fileUID(String key) {
    Item? file = item(key);
    if (file == null || file.type != "File") {
      file = edge(key, "file");
    }
    if (file != null && file.type == "File") {
      String? filename =
          (property(item: file, propertyName: "sha256"))?.asString();
      return filename;
    }
    return null;
  }

  Future<String?> fileURL(String key) async {
    var uuid = fileUID(key);
    if (uuid == null) return null;
    return FileStorageController.getURLForFile(uuid);
  }

  CVU_SizingMode sizingMode([String key = "sizingMode"]) {
    var val = value(key);
    if (val == null) {
      return CVU_SizingMode.fit;
    }
    String? string = lookup.resolve<String>(value: val, context: context);
    if (string == null) {
      return CVU_SizingMode.fit;
    }

    return string == "fill" ? CVU_SizingMode.fill : CVU_SizingMode.fit;
  }

  Color? color([String key = "color"]) {
    var val = this.value(key);
    if (val == null) {
      return null;
    }
    String? string = lookup.resolve<String>(value: val, context: this.context);
    if (string == null) {
      return null;
    }
    var predefined = CVUColor.predefined[string];
    if (predefined != null) {
      return predefined;
    }
    return CVUColor(color: string).value;
  }

  AlignmentResolver alignment(String alignType,
      [String propertyName = "alignment"]) {
    var val = value(propertyName);
    if (val == null) {
      return AlignmentResolver(
          mainAxis: MainAxisAlignment.start,
          crossAxis: CrossAxisAlignment.start);
    }
    if (alignType == "row") {
      switch (lookup.resolve<String>(value: val, context: context)) {
        case "left":
        case "leading":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.start,
              crossAxis: CrossAxisAlignment.center);
        case "top":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.start,
              crossAxis: CrossAxisAlignment.start);
        case "right":
        case "trailing":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.end,
              crossAxis: CrossAxisAlignment.center);
        case "bottom":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.start,
              crossAxis: CrossAxisAlignment.end);
        case "center":
        case "centre":
        case "middle":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.center,
              crossAxis: CrossAxisAlignment.center);
        case "lefttop":
        case "topleft":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.start,
              crossAxis: CrossAxisAlignment.start);
        case "righttop":
        case "topright":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.end,
              crossAxis: CrossAxisAlignment.start);
        case "leftbottom":
        case "bottomleft":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.start,
              crossAxis: CrossAxisAlignment.end);
        case "rightbottom":
        case "bottomright":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.end,
              crossAxis: CrossAxisAlignment.end);
        case "topspacebetween":
        case "spacebetweentop":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.spaceBetween,
              crossAxis: CrossAxisAlignment.start);
        case "bottomspacebetween":
        case "spacebetweenbottom":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.spaceBetween,
              crossAxis: CrossAxisAlignment.end);
        case "spacebetween":
        case "centerspacebetween":
        case "spacebetweencenter":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.spaceBetween,
              crossAxis: CrossAxisAlignment.center);
        default:
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.center,
              crossAxis: CrossAxisAlignment.center);
      }
    } else {
      switch (lookup.resolve<String>(value: val, context: context)) {
        case "left":
        case "leading":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.center,
              crossAxis: CrossAxisAlignment.start);
        case "top":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.start,
              crossAxis: CrossAxisAlignment.center);
        case "right":
        case "trailing":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.center,
              crossAxis: CrossAxisAlignment.end);
        case "bottom":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.end,
              crossAxis: CrossAxisAlignment.start);
        case "center":
        case "centre":
        case "middle":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.center,
              crossAxis: CrossAxisAlignment.center);
        case "lefttop":
        case "topleft":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.start,
              crossAxis: CrossAxisAlignment.start);
        case "righttop":
        case "topright":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.start,
              crossAxis: CrossAxisAlignment.end);
        case "leftbottom":
        case "bottomleft":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.end,
              crossAxis: CrossAxisAlignment.start);
        case "rightbottom":
        case "bottomright":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.end,
              crossAxis: CrossAxisAlignment.end);
        case "leftspacebetween":
        case "spacebetweenleft":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.spaceBetween,
              crossAxis: CrossAxisAlignment.start);
        case "rightspacebetween":
        case "spacebetweenright":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.spaceBetween,
              crossAxis: CrossAxisAlignment.end);
        case "spacebetween":
        case "centerspacebetween":
        case "spacebetweencenter":
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.spaceBetween,
              crossAxis: CrossAxisAlignment.center);
        default:
          return AlignmentResolver(
              mainAxis: MainAxisAlignment.center,
              crossAxis: CrossAxisAlignment.center);
      }
    }
  }

  Alignment alignmentForStack([String propertyName = "alignment"]) {
    var val = value(propertyName);
    if (val == null) {
      return Alignment.center;
    }
    switch (lookup.resolve<String>(value: val, context: context)) {
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

  TextAlign textAlignment([String propertyName = "textAlign"]) {
    var val = value(propertyName);
    if (val == null) {
      return TextAlign.left;
    }
    switch (lookup.resolve<String>(value: val, context: context)) {
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
      x = lookup.resolve<double>(value: values[0], context: this.context);
      y = lookup.resolve<double>(value: values[1], context: this.context);
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
    List<double> insetArray = values.compactMap<double>((element) =>
        lookup.resolve<double>(value: element, context: this.context));
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

  CVUFont font([String propertyName = "font", CVUFont? defaultValue]) {
    defaultValue = defaultValue ?? CVUFont();
    var values = valueArray(propertyName);
    String? name;
    double? size;
    if (values.length >= 2) {
      name = lookup.resolve<String>(value: values[1], context: this.context);
      size = lookup.resolve<double>(value: values[0], context: this.context);
    }

    if (name != null && size != null) {
      var weight =
          lookup.resolve<String>(value: values[1], context: this.context);
      return CVUFont(
          size: size, weight: CVUFont.Weight[weight] ?? defaultValue.weight);
    } else {
      if (values.isNotEmpty) {
        var val = values[0];
        String? defaultStyle =
            lookup.resolve<String>(value: val, context: this.context);
        if (defaultStyle != null && CVUFont.predefined[defaultStyle] != null) {
          return CVUFont.predefined[defaultStyle]!;
        } else {
          double? size =
              lookup.resolve<double>(value: val, context: this.context);
          if (size != null) {
            return CVUFont(
                name: name,
                size: size,
                weight: CVUFont.Weight[lookup.resolve<String>(
                      value: values[0],
                      context: this.context,
                    )] ??
                    defaultValue.weight);
          } else {
            var weight = CVUFont.Weight[
                lookup.resolve<String>(value: val, context: this.context)];
            if (weight != null) {
              return CVUFont(
                  name: defaultValue.name,
                  size: defaultValue.size,
                  weight: weight);
            }
          }
        }
      }
    }
    return defaultValue;
  }

  T? style<T>({required StyleType type}) {
    switch (type) {
      case StyleType.button:
        var styleName = string("styleName");
        if (styleName != null && buttonStyles[styleName] != null) {
          return buttonStyles[styleName] as T;
        }
    }
    return null;
  }

  bool get showNode {
    return (boolean(
        "show", false, true))!; //TODO boolean function type @anijanyan
  }

  double get opacity {
    return number("opacity") ?? 1;
  }

  Color? get backgroundColor {
    return color("background");
  }

  Color? get borderColor {
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

  Offset get offset {
    var val = cgPoint("offset");
    if (val == null) {
      return Offset.zero;
    }
    return Offset(val.x.toDouble(), val.y.toDouble());
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
    return EdgeInsets.fromLTRB(
        uiInsets.left, uiInsets.top, uiInsets.right, uiInsets.bottom);
  }

  EdgeInsets get margin {
    var uiInsets = this.insets("padding");
    if (uiInsets == null) {
      return EdgeInsets.zero;
    }
    return EdgeInsets.fromLTRB(
        uiInsets.left, uiInsets.top, uiInsets.right, uiInsets.bottom);
  }

  double get cornerRadius {
    return cgFloat("cornerRadius") ?? 0;
  }

  List<double> get cornerRadiusOnly {
    var values = numberArray("cornerRadiusOnly");
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

  Point? get spacing {
    return cgPoint("spacing");
  }
}

class AlignmentResolver {
  MainAxisAlignment mainAxis;
  CrossAxisAlignment crossAxis;

  AlignmentResolver({required this.mainAxis, required this.crossAxis});
}

enum StyleType { button }
