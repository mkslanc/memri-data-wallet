import 'dart:convert';

import 'package:html/parser.dart';
import 'package:memri/constants/app_logger.dart';
import 'package:memri/core/controllers/database_controller.dart' as database;
import 'package:memri/core/models/item.dart';
import 'package:memri/cvu/models/cvu_value_lookup_node.dart';
import 'package:memri/cvu/models/cvu_view_arguments.dart';
import 'package:memri/core/services/database/property_database_value.dart';
import 'package:memri/core/services/database/schema.dart';
import 'package:memri/cvu/models/cvu_value.dart';
import 'package:memri/cvu/models/cvu_value_constant.dart';
import 'package:memri/cvu/models/cvu_value_expression.dart';
import 'package:memri/utilities/extensions/collection.dart';
import 'package:memri/utilities/extensions/date_time.dart';
import 'package:memri/utilities/extensions/number.dart';
import 'package:memri/utilities/extensions/string.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/utilities/mock_generator.dart';
import 'package:moor/moor.dart';

import '../services/resolving/cvu_context.dart';

/// This struct can be used to _resolve CVU values to a final value of the desired type.
/// For lookups you must provide a CVUContext which contains required information on the default item, viewArguments, etc to be used in the lookup.
class CVULookupController {
  LookupMock? lookupMockMode;

  CVULookupController([this.lookupMockMode]);

  T? resolve<T>(
      {CVUValue? value,
      List<CVULookupNode>? nodes,
      String? edge,
      Item? item,
      String? property,
      CVUExpressionNode? expression,
      CVUContext? context,
      dynamic defaultValue,
      database.DatabaseController? db,
      Type? additionalType}) {
    switch (T) {
      case double:
        if (nodes != null) {
          return _resolveNodesDouble(nodes, context!, db!) as T?;
        } else if (expression != null) {
          return _resolveExpressionDouble(expression, context!, db!) as T?;
        }
        return _resolveDouble(value!, context!, db!) as T?;
      case int:
        if (nodes != null) {
          return _resolveNodesInt(nodes, context!, db!) as T?;
        } else if (expression != null) {
          return _resolveExpressionInt(expression, context!, db!) as T?;
        }
        return _resolveInt(value!, context!, db!) as T?;
      case String:
        if (nodes != null) {
          return _resolveNodesString(nodes, context!, db!) as T?;
        } else if (expression != null) {
          return _resolveExpressionString(expression, context!, db!) as T?;
        }
        return _resolveString(value!, context!, db!) as T?;
      case bool:
        if (nodes != null) {
          return _resolveNodesBool(nodes, context!, db!) as T?;
        } else if (expression != null) {
          return _resolveExpressionBool(expression, context!, db!) as T?;
        }
        return _resolveBool(value!, context!, db!) as T?;
      case DateTime:
        return _resolveDate(value!, context!, db!) as T?;
      case Item:
        if (edge != null) {
          return _resolveEdgeItem(edge, item!, db!) as T?;
        } else if (nodes != null) {
          return _resolveNodesItem(nodes, context!, db!) as T?;
        } else if (expression != null) {
          return _resolveExpressionItem(expression, context!, db!) as T?;
        }
        return _resolveItem(value!, context!, db!) as T?;
      case List:
        if (edge != null) {
          return _resolveEdgeItemArray(edge, item!, db!) as T?;
        } else if (nodes != null) {
          return _resolveNodesItemArray(nodes, context!, db!) as T?;
        } else if (expression != null) {
          return _resolveExpressionItemArray(expression, context!, db!) as T?;
        }
        if (additionalType == CVUValue) {
          return _resolveCVUValueArray(value!, context!, db!) as T?;
        } else if (additionalType == CVUConstant) {
          return _resolveCVUConstantArray(value!, context!, db!) as T?;
        } else if (additionalType == Map) {
          return _resolveArrayOfCVUConstantMap(value!, context!, db!) as T?;
        }
        return _resolveItemArray(value!, context!, db!) as T?;
      case LookupStep:
        return _resolveLookupStep(nodes!, context!, db!) as T?;
      case PropertyDatabaseValue:
        return _resolvePropertyDatabaseValue(property!, item!, db!) as T?;
      default:
        throw Exception("Type is required");
    }
  }

  int? _resolveInt(
      CVUValue value, CVUContext context, database.DatabaseController db) {
    if (value is CVUValueConstant) {
      return value.value.asInt();
    } else if (value is CVUValueExpression) {
      return resolve<int>(expression: value.value, context: context, db: db);
    } else {
      return null;
    }
  }

  double? _resolveDouble(
      CVUValue value, CVUContext context, database.DatabaseController db) {
    if (value is CVUValueConstant) {
      return value.value.asNumber();
    } else if (value is CVUValueExpression) {
      return resolve<double>(expression: value.value, context: context, db: db);
    } else {
      return null;
    }
  }

  String? _resolveString(
      CVUValue value, CVUContext context, database.DatabaseController db) {
    if (value is CVUValueConstant) {
      return value.value.asString();
    } else if (value is CVUValueExpression) {
      return resolve<String>(expression: value.value, context: context, db: db);
    } else {
      return null;
    }
  }

  bool? _resolveBool(
      CVUValue value, CVUContext context, database.DatabaseController db) {
    if (value is CVUValueConstant) {
      return value.value.asBool();
    } else if (value is CVUValueExpression) {
      return resolve<bool>(expression: value.value, context: context, db: db);
    } else {
      return null;
    }
  }

  DateTime? _resolveDate(
      CVUValue value, CVUContext context, database.DatabaseController db) {
    if (value is CVUValueConstant) {
      return DateTime.fromMillisecondsSinceEpoch(
          int.parse(value.value.asNumber().toString()));
    } else if (value is CVUValueExpression) {
      return resolve<DateTime>(
          expression: value.value, context: context, db: db);
    } else {
      return null;
    }
  }

  Item? _resolveItem(
      CVUValue value, CVUContext context, database.DatabaseController db) {
    if (value is CVUValueConstant) {
      return null;
    } else if (value is CVUValueExpression) {
      return resolve<Item>(expression: value.value, context: context, db: db);
    } else {
      return null;
    }
  }

  List<Item> _resolveItemArray(
      CVUValue value, CVUContext context, database.DatabaseController db) {
    if (value is CVUValueExpression) {
      CVUExpressionNode expression = value.value;
      return (resolve<List>(
          expression: expression,
          context: context,
          db: db,
          additionalType: Item)) as List<Item>;
    } else if (value is CVUValueArray) {
      var cvuValueArray = (resolve<List>(
          value: value,
          context: context,
          db: db,
          additionalType: CVUValue)) as List<CVUValue>;

      return cvuValueArray.compactMap((cvuValue) =>
          resolve<Item>(value: cvuValue, context: context, db: db));
    } else {
      return [];
    }
  }

  List<CVUValue> _resolveCVUValueArray(
      CVUValue value, CVUContext context, database.DatabaseController db) {
    if (value is CVUValueArray) {
      var values = value.value;
      return values;
    } else {
      return [];
    }
  }

  List<Map<String, List<CVUConstant>>> _resolveArrayOfCVUConstantMap(
      CVUValue value, CVUContext context, database.DatabaseController db) {
    if (value is CVUValueArray) {
      var values = value.value;
      return values
          .map((el) => Map.fromEntries(
              (el.getSubdefinition()?.properties.entries.toList() ?? [])
                  .map((entry) => MapEntry(entry.key,
                      resolve<List<CVUConstant>>(value: entry.value)))
                  .where((element) => element.value != null)))
          .whereType<Map<String, List<CVUConstant>>>()
          .where((element) => element.isNotEmpty)
          .toList();
    } else {
      return [];
    }
  }

  List<CVUConstant>? _resolveCVUConstantArray(
      CVUValue value, CVUContext context, database.DatabaseController db) {
    if (value is CVUValueConstant) {
      var constant = value.value;
      return [constant];
    } else if (value is CVUValueArray) {
      var values = value.value;
      return (values.map((element) =>
          (resolve<List>(value: element, additionalType: CVUConstant) ?? [])
              as List<CVUConstant>)).expand((element) => element).toList();
    } else {
      return null;
    }
  }

  /// Lookup an edge from an Item
  Item? _resolveEdgeItem(
      String edge, Item item, database.DatabaseController db) {
    return item.getEdges(edge)?.first();
  }

  /// Lookup an edge array from an Item
  List<Item> _resolveEdgeItemArray(
      String edge, Item item, database.DatabaseController db) {
    return item.getEdges(edge)?.targets ?? [];
  }

  /// Lookup a property from an Item
  PropertyDatabaseValue? _resolvePropertyDatabaseValue(
      String property, Item item, database.DatabaseController db) {
    var value = item.get(property);
    if (value == null) {
      return null;
    }
    SchemaValueType? propertyType =
        db.schema.expectedPropertyType(item.type, property);
    if (propertyType == null) {
      return null;
    }
    return PropertyDatabaseValue.create(value, propertyType);
  }

  LookupStep? _resolveLookupStep(List<CVULookupNode> nodes, CVUContext context,
      database.DatabaseController db) {
    LookupStep? currentValue;
    var nodePath = "";
    for (CVULookupNode node in nodes) {
      if (node.type is CVULookupTypeDefault ||
          nodePath.isNotEmpty && nodePath != ".") {
        nodePath += ".";
      }
      nodePath += node.toCVUString();
      if (context.hasCache(nodePath)) {
        currentValue = context.getCache(nodePath);
      } else {
        var nodeType = node.type;

        if (nodeType is CVULookupTypeDefault) {
          Item? currentItem = context.currentItem;
          if (currentItem == null) {
            currentValue = null;
          } else {
            currentValue = LookupStepItems([currentItem]);
          }
        } else if (nodeType is CVULookupTypeFunction) {
          currentValue =
              _resolveLookupFunction(node, currentValue, context, db);
        } else if (nodeType is CVULookupTypeLookup) {
          currentValue = _resolveLookup(node, currentValue, context, db);
        } else {
          throw Exception("Unknown CVULookupType ${nodeType.toString()}");
        }

        context.setCache(nodePath, currentValue);
      }

      if (currentValue is LookupStepContext) {
        context = currentValue.context;
        currentValue = null;
      }
    }

    return currentValue;
  }

  LookupStep? _resolveLookup(CVULookupNode node, LookupStep? currentValue,
      CVUContext context, database.DatabaseController db) {
    var nodeType = node.type as CVULookupTypeLookup;

    if (currentValue is LookupStepItems) {
      currentValue = itemLookup(
          node: node,
          items: currentValue.items,
          subexpressions: nodeType.subexpressions,
          context: context,
          db: db);
    } else if (currentValue == null) {
      // Check if there is a matching view argument
      CVUViewArguments? viewArgs = context.viewArguments;
      CVUValue? argValue = viewArgs?.args[node.name];
      if (viewArgs != null && argValue != null) {
        if (argValue is CVUValueConstant) {
          CVUConstant constant = argValue.value;
          if (constant is CVUConstantArgument) {
            currentValue =
                LookupStepValues([PropertyDatabaseValueString(constant.value)]);
          } else if (constant is CVUConstantNumber) {
            currentValue =
                LookupStepValues([PropertyDatabaseValueDouble(constant.value)]);
          } else if (constant is CVUConstantInt) {
            currentValue =
                LookupStepValues([PropertyDatabaseValueInt(constant.value)]);
          } else if (constant is CVUConstantString) {
            currentValue =
                LookupStepValues([PropertyDatabaseValueString(constant.value)]);
          } else if (constant is CVUConstantBool) {
            currentValue =
                LookupStepValues([PropertyDatabaseValueBool(constant.value)]);
          } else if (constant is CVUConstantColorHex) {
            currentValue =
                LookupStepValues([PropertyDatabaseValueString(constant.value)]);
          } else if (constant is CVUConstantNil) {
            currentValue = null;
          } else {
            throw Exception("Unknown CVUConstant: ${constant.toString()}");
          }
        } else if (argValue is CVUValueExpression) {
          currentValue = () {
            CVUExpressionNode expression = argValue.value;

            var context = CVUContext(
                currentItem: viewArgs.argumentItem,
                items: viewArgs.argumentItems,
                viewArguments: viewArgs.parentArguments);

            List<Item> items = resolve<List>(
                expression: expression,
                context: context,
                db: db,
                additionalType: Item) as List<Item>;

            if (items.isNotEmpty) return LookupStepItems(items);

            Item? item =
                resolve<Item>(expression: expression, context: context, db: db);
            if (item != null) return LookupStepItems([item]);

            double? number = resolve<double>(
                expression: expression, context: context, db: db);
            if (number != null)
              return LookupStepValues([PropertyDatabaseValueDouble(number)]);

            String? string = resolve<String>(
                expression: expression, context: context, db: db);
            if (string != null)
              return LookupStepValues([PropertyDatabaseValueString(string)]);

            return null;
          }();
        } else {
          currentValue = null;
        }
      } else if (node.name == "uid") {
        var uid = context.currentItem?.id;
        if (uid != null) {
          currentValue =
              LookupStepValues([PropertyDatabaseValueString(uid as String)]);
        }
      } else if (node.name == "items") {
        List<Item>? items = context.items;
        if (items == null) {
          return null;
        }
        currentValue = LookupStepItems(items);
      } else if (node.name == "currentIndex") {
        currentValue = LookupStepValues(
            [PropertyDatabaseValueInt(context.currentIndex + 1)]);
      }
    } else {
      currentValue = null;
    }

    return currentValue;
  }

  LookupStep? _resolveLookupFunction(
      CVULookupNode node,
      LookupStep? currentValue,
      CVUContext context,
      database.DatabaseController db) {
    var nodeType = node.type as CVULookupTypeFunction;
    List<CVUExpressionNode> args = nodeType.args;
    switch (node.name.toLowerCase()) {
      case "joined":
        if (currentValue == null || currentValue is! LookupStepValues) {
          return null;
        }
        var exp = args.asMap()[0];
        if (exp == null) {
          return null;
        }
        String? separator;
        separator = resolve<String>(expression: exp, context: context, db: db);

        if (separator != null && separator.isNotEmpty) {
          String joined = currentValue.values
              .map((element) => element.asString())
              .where((element) => element != null && element.isNotEmpty)
              .join(separator);
          currentValue =
              LookupStepValues([PropertyDatabaseValueString(joined)]);
        } else {
          String joined = currentValue.values
              .map((element) => element.asString())
              .where((element) => element != null && element.isNotEmpty)
              .join(", "); //TODO @anijanyan String.localizedString(strings);
          currentValue =
              LookupStepValues([PropertyDatabaseValueString(joined)]);
        }
        break;
      case "joinwithcomma":
        String joined = (args.map((element) => (resolve<String>(
                expression: element, context: context, db: db))))
            .where((element) => element != null && element.isNotEmpty)
            .join(", ");
        currentValue = LookupStepValues([PropertyDatabaseValueString(joined)]);
        break;
      case "joinnatural":
        List<String> strings = (args.map((element) =>
            (resolve<String>(expression: element, context: context, db: db))
                .toString())).where((element) => element.isNotEmpty).toList();
        var joined = strings
            .join(", "); //TODO @anijanyan String.localizedString(strings);
        currentValue = LookupStepValues([PropertyDatabaseValueString(joined)]);
        break;
      case "plainstring":
        if (currentValue == null || currentValue is! LookupStepValues) {
          return null;
        }
        List<PropertyDatabaseValue> stripped = currentValue.values
            .map((PropertyDatabaseValue value) {
              String? htmlstring = value.asString();
              if (htmlstring == null || htmlstring.isEmpty) {
                return null;
              }
              var strippedText =
                  parse(parse(htmlstring).body!.text).documentElement!.text;
              return PropertyDatabaseValueString(strippedText);
            })
            .whereType<PropertyDatabaseValue>()
            .toList();

        currentValue = LookupStepValues(stripped);
        break;
      case "first":
        if (currentValue == null) {
          return null;
        }

        if (currentValue is LookupStepValues &&
            currentValue.values.isNotEmpty) {
          currentValue = LookupStepValues([currentValue.values.first]);
        } else if (currentValue is LookupStepItems &&
            currentValue.items.isNotEmpty) {
          currentValue = LookupStepItems([currentValue.items.first]);
        } else {
          return null;
        }
        break;
      case "last":
        if (currentValue == null) {
          return null;
        }

        if (currentValue is LookupStepValues &&
            currentValue.values.isNotEmpty) {
          currentValue = LookupStepValues([currentValue.values.last]);
        } else if (currentValue is LookupStepItems &&
            currentValue.items.isNotEmpty) {
          currentValue = LookupStepItems([currentValue.items.last]);
        } else {
          return null;
        }
        break;
      case "count":
        if (currentValue == null) {
          return null;
        }

        if (currentValue is LookupStepValues) {
          currentValue = LookupStepValues(
              [PropertyDatabaseValueInt(currentValue.values.length)]);
        } else if (currentValue is LookupStepItems) {
          currentValue = LookupStepValues(
              [PropertyDatabaseValueInt(currentValue.items.length)]);
        } else {
          return null;
        }
        break;
      case "percent":
        if (currentValue == null || currentValue is! LookupStepValues) {
          return null;
        }

        var exp = nodeType.args.asMap()[0];
        double? arg;
        if (exp != null) {
          arg = resolve<double>(expression: exp, context: context, db: db);
          if (arg == null) {
            return null;
          }
        } else {
          arg = 1;
        }
        currentValue = LookupStepValues([
          PropertyDatabaseValueString(((arg == 0
                  ? 0
                  : ((currentValue.values.asMap()[0]?.value ?? 0) /
                      arg *
                      100)) as double)
              .format(1))
        ]);

        break;
      case "fullname":
        if (currentValue is LookupStepItems) {
          if (currentValue.items.isEmpty) {
            return null;
          }
          Item first = currentValue.items[0];
          if (first.type == "Person") {
            String name = [
              resolve<PropertyDatabaseValue>(
                  property: "firstName", item: first, db: db),
              resolve<PropertyDatabaseValue>(
                  property: "lastName", item: first, db: db)
            ].map((element) => (element?.asString() ?? "")).join(" ");
            currentValue =
                LookupStepValues([PropertyDatabaseValueString(name)]);
          } else {
            return null;
          }
        } else {
          return null;
        }
        break;
      case "initials":
        if (currentValue is LookupStepValues) {
          String initials = currentValue.values
              .map((element) => element.asString()?[0])
              .where((element) => element != null && element.isNotEmpty)
              .join()
              .toUpperCase();
          currentValue =
              LookupStepValues([PropertyDatabaseValueString(initials)]);
        } else if (currentValue is LookupStepItems) {
          if (currentValue.items.isEmpty) {
            return null;
          }
          Item first = currentValue.items[0];
          if (first.type == "Person") {
            String initials = [
              resolve<PropertyDatabaseValue>(
                  property: "firstName", item: first, db: db),
              resolve<PropertyDatabaseValue>(
                  property: "lastName", item: first, db: db)
            ]
                .map((element) => element?.asString()?[0])
                .where((element) => element != null && element.isNotEmpty)
                .join()
                .toUpperCase();
            currentValue =
                LookupStepValues([PropertyDatabaseValueString(initials)]);
          } else {
            return null;
          }
        } else {
          return null;
        }
        break;
      case "describechangelog":
        if (currentValue is LookupStepItems) {
          if (currentValue.items.isEmpty) {
            return null;
          }
          Item first = currentValue.items[0];
          if (first.type == "Person") {
            var dateCreated =
                DateTime.fromMillisecondsSinceEpoch(first.get("dateCreated"))
                    .formatted();
            var timeSinceCreated =
                DateTime.fromMillisecondsSinceEpoch(first.get("dateCreated"))
                    .timeDelta;
            return LookupStepValues([
              PropertyDatabaseValueString(
                  "You created this ${first.type} $dateCreated over the past $timeSinceCreated")
            ]);
          } else {
            return null;
          }
        }
        return null;
      case "camelcasetowords":
        if (currentValue == null) {
          return null;
        }
        if (currentValue is LookupStepValues) {
          var camelCased = currentValue.values.map((value) {
            var string = value.asString();
            if (string == null) {
              return value;
            } else {
              return PropertyDatabaseValueString(string.camelCaseToWords());
            }
          }).toList();
          currentValue = LookupStepValues(camelCased);
        } else {
          return null;
        }
        break;
      case "titlecase":
        if (currentValue == null) {
          return null;
        }
        if (currentValue is LookupStepValues) {
          var titleCased = currentValue.values.map((value) {
            var string = value.asString();
            if (string == null) {
              return value;
            } else {
              return PropertyDatabaseValueString(string.titleCase());
            }
          }).toList();
          currentValue = LookupStepValues(titleCased);
        } else {
          return null;
        }
        break;
      case "firstuppercased":
        if (currentValue == null) {
          return null;
        }
        if (currentValue is LookupStepValues) {
          var titleCased = currentValue.values.map((value) {
            var string = value.asString();
            if (string == null) {
              return value;
            } else {
              return PropertyDatabaseValueString(string.capitalizingFirst());
            }
          }).toList();
          currentValue = LookupStepValues(titleCased);
        } else {
          return null;
        }
        break;
      case "touppercase":
        if (currentValue == null) {
          return null;
        }
        if (currentValue is LookupStepValues) {
          var upperCased = currentValue.values.map((value) {
            var string = value.asString();
            if (string == null) {
              return value;
            } else {
              return PropertyDatabaseValueString(string.toUpperCase());
            }
          }).toList();
          currentValue = LookupStepValues(upperCased);
        } else {
          return null;
        }
        break;
      case "tolowercase":
        if (currentValue == null) {
          return null;
        }
        if (currentValue is LookupStepValues) {
          var lowerCased = currentValue.values.map((value) {
            var string = value.asString();
            if (string == null) {
              return value;
            } else {
              return PropertyDatabaseValueString(string.toLowerCase());
            }
          }).toList();
          currentValue = LookupStepValues(lowerCased);
        } else {
          return null;
        }
        break;
      case "subview":
        var exp = nodeType.args.asMap()[0];
        String? id = resolve<String>(expression: exp, context: context, db: db);
        if (id == null) {
          return null;
        }
        var subViewArgs = context.viewArguments?.subViewArguments[id];
        if (subViewArgs == null) {
          return null;
        }
        currentValue = LookupStepContext(CVUContext(
            currentItem: context.currentItem,
            items: context.items ?? [],
            viewArguments: subViewArgs));
        break;
      case "selecteditems":
        var viewArgs = context.viewArguments;
        if (viewArgs == null) {
          return null;
        }
        if (viewArgs.args["selectedItems"] == null) {
          return null;
        }
        List<Item> items = resolve<List>(
            value: viewArgs.args["selectedItems"],
            db: db,
            context: context,
            additionalType: Item) as List<Item>;
        if (items.isEmpty) {
          return null;
        }
        currentValue = LookupStepItems(items);
        break;
      case "ishovered":
        var viewArgs = context.viewArguments;
        if (viewArgs == null) {
          return null;
        }
        var exp = nodeType.args.asMap()[0];
        String? id = resolve<String>(expression: exp, context: context, db: db);
        if (id == null) {
          return null;
        }
        var isHovered = viewArgs.args["isHovered$id"];
        if (isHovered is! CVUValueConstant ||
            isHovered.value is! CVUConstantBool) {
          return null;
        }
        currentValue = LookupStepValues(
            [PropertyDatabaseValueBool(isHovered.value.value)]);
        break;
      case "fromjson":
        if (currentValue == null) {
          return null;
        }
        if (currentValue is LookupStepValues) {
          var exp = nodeType.args.asMap()[0];
          if (exp == null) {
            return null;
          }

          String? property =
              resolve<String>(expression: exp, context: context, db: db);
          if (property == null) {
            return null;
          }

          var values = currentValue.values.map((value) {
            var string = value.asString();
            if (string == null) {
              return value;
            } else {
              var obj = jsonDecode(string);
              if (obj == null || obj[property] == null) {
                return value;
              }
              if (obj[property] is bool) {
                return PropertyDatabaseValueBool(obj[property]);
              }
              return PropertyDatabaseValueString(obj[property]);
            }
          }).toList();

          currentValue = LookupStepValues(values);
        } else {
          return null;
        }
        break;
      case "generaterandom":
        var exp = nodeType.args.asMap()[0];
        String? type =
            resolve<String>(expression: exp, context: context, db: db);
        if (type == null) {
          return null;
        }
        var propertyExp = nodeType.args.asMap()[1];
        String? property;
        if (propertyExp != null) {
          property = resolve<String>(
              expression: propertyExp, context: context, db: db);
        }

        //TODO: other types if we will need this
        switch (type.toLowerCase()) {
          case "string":
            currentValue = LookupStepValues([
              PropertyDatabaseValueString(MockDataGenerator.generateMockData(
                  valueType: SchemaValueType.string, property: property))
            ]);
            break;
          case "int":
            currentValue = LookupStepValues([
              PropertyDatabaseValueInt(MockDataGenerator.generateMockData(
                  valueType: SchemaValueType.int, property: property))
            ]);
            break;
          default:
            currentValue = LookupStepValues([
              PropertyDatabaseValueString(MockDataGenerator.generateMockData(
                  valueType: SchemaValueType.string, property: property))
            ]);
            break;
        }
        break;
      case "format":
        if (currentValue == null) {
          return null;
        }
        if (currentValue is LookupStepValues) {
          var exp = nodeType.args.asMap()[0];
          String? dateFormat;
          if (exp != null) {
            dateFormat =
                resolve<String>(expression: exp, context: context, db: db);
          }
          var newDate = currentValue.values.first
              .asDate()
              ?.formatDate(dateFormat: dateFormat);
          if (newDate == null) {
            return null;
          }
          currentValue =
              LookupStepValues([PropertyDatabaseValueString(newDate)]);
        } else {
          return null;
        }
        break;
      case "itemtype":
        if (currentValue is! LookupStepItems ||
            currentValue.items.length == 0) {
          return null;
        }
        currentValue = LookupStepValues(
            [PropertyDatabaseValueString(currentValue.items[0].type)]);
        break;
      case "fromconfig":
        var exp = nodeType.args.asMap()[0];
        String? param =
            resolve<String>(expression: exp, context: context, db: db);
        if (param == null) {
          return null;
        }
        switch (param.toLowerCase()) {
          case "colablink":
            currentValue = LookupStepValues(
                [PropertyDatabaseValueString(app.settings.colabLink)]);
            break;
          default:
            return null;
        }
        break;
      default:
        return null;
    }
    return currentValue;
  }

  List<Item> filter(List<Item> items, CVUExpressionNode? exp,
      database.DatabaseController? db, CVUContext context) {
    if (exp == null) {
      return items;
    }

    return (items.compactMap((item) => (resolve<bool>(
                expression: exp,
                context: CVUContext(
                    currentItem: item,
                    viewArguments: CVUViewArguments(
                      argumentItem: context.currentItem,
                      argumentItems: context.items,
                      args: context.viewArguments?.args,
                    )),
                db: db) ??
            false)
        ? item
        : null));
  }

  T? _resolveNamedExpression<T>(List<CVUExpressionNode> expressions,
      String name, database.DatabaseController db, CVUContext context) {
    var expression = _getNamedExpression(expressions, name);
    if (expression == null) {
      return null;
    }

    return resolve<T>(expression: expression, context: context, db: db);
  }

  CVUExpressionNode? _getNamedExpression(
      List<CVUExpressionNode> expressions, String name) {
    return (expressions.firstWhereOrNull((expression) =>
                expression is CVUExpressionNodeNamed && expression.key == name)
            as CVUExpressionNodeNamed?)
        ?.value;
  }

  List<Map<String, dynamic>> getSort(List<CVUExpressionNode> expressions,
      String edgeType, database.DatabaseController db, CVUContext context) {
    var sortData =
        _resolveNamedExpression<String>(expressions, "sort", db, context);
    var sort = <Map<String, dynamic>>[];

    if (sortData != null && sortData.isNotEmpty) {
      var sortProperties = sortData.split(",");
      sortProperties.forEach((sortProperty) {
        var sortData = sortProperty.trim().split(" ");
        SchemaValueType schemaValueType =
            db.schema.expectedPropertyType(edgeType, sortData[0])!;
        ItemRecordPropertyTable ItemPropertyTable =
            PropertyDatabaseValue.toDBTableName(schemaValueType);
        TableInfo table =
            db.databasePool.getItemPropertyRecordTable(ItemPropertyTable);
        sort.add({
          "table": table,
          "property": sortData[0],
          "order": sortData.length > 1 ? sortData.last : null
        });
      });
    }

    return sort;
  }

  LookupStep? itemLookup(
      {required CVULookupNode node,
      required List<Item> items,
      List<CVUExpressionNode>? subexpressions,
      required CVUContext context,
      required database.DatabaseController db}) {
    if (items.isEmpty) {
      return null;
    }

    String trimmedName = node.name.replaceAll(RegExp(r"(^~)|(~$)"), "");
    CVUExpressionNode? filterExpression;
    if (subexpressions != null && subexpressions.isNotEmpty) {
      filterExpression = subexpressions.first is! CVUExpressionNodeNamed
          ? subexpressions.first
          : _getNamedExpression(subexpressions, "filter");
    }

    /// CHECK IF WE'RE EXPECTING EDGES OR PROPERTIES
    String itemType = items[0].type;

    /// Check if this is an intrinsic property
    switch (node.name) {
      case "uid":
      case "id":
        return LookupStepValues(items
            .map((element) => PropertyDatabaseValueString(element.id))
            .toList());
      case "dateModified":
        return LookupStepValues(items
            .map((element) => PropertyDatabaseValueDatetime(
                DateTime.fromMillisecondsSinceEpoch(
                    element.get("dateModified"))))
            .toList());
      case "dateCreated":
        return LookupStepValues(items
            .map((element) => PropertyDatabaseValueDatetime(
                DateTime.fromMillisecondsSinceEpoch(
                    element.get("dateCreated"))))
            .toList());
      case "label":
        return LookupStepItems(
            items.asMap()[0]?.getEdges("label")?.targets ?? []);
      default:
        break;
    }

    /// Find out if it is a property or an edge (according to schema)

    ResolvedType? expectedType;
    if (node.name.startsWith("~")) {
      var expectedTypes = db.schema.expectedSourceTypes(itemType, trimmedName);
      if (expectedTypes.isEmpty) return null;

      expectedType = ResolvedTypeEdge(expectedTypes.first);
    } else {
      expectedType = db.schema.expectedType(itemType, node.name);
    }

    if (expectedType is ResolvedTypeProperty) {
      /// LOOKUP PROPERTY FOR EACH ITEM
      List<PropertyDatabaseValue> result = [];
      items.forEach((Item item) {
        PropertyDatabaseValue? value =
            _resolvePropertyDatabaseValue(node.name, item, db);
        if (value == null) {
          return null;
        }
        result.add(value);
      });
      return LookupStepValues(result);
    } else if (expectedType is ResolvedTypeEdge) {
      /// LOOKUP EDGE FOR EACH ITEM
      List<Item> result;
      if (node.isArray) {
        result = items
            .map((item) => item.getEdges(trimmedName)?.targets ?? [])
            .expand((element) => element)
            .toList();
      } else {
        result = [];
        items.forEach((Item item) {
          var Item = item.getEdges(trimmedName)?.first();
          if (Item != null) result.add(Item);
        });
      }
      var stepItems = filter(result, filterExpression, db, context);
      return LookupStepItems(stepItems);
    } else {
      return null;
    }
  }

  /// Lookup a variable using its CVU string and return the value as a double
  double? _resolveNodesDouble(List<CVULookupNode> nodes, CVUContext context,
      database.DatabaseController db) {
    if (lookupMockMode != null) {
      return lookupMockMode!.number;
    }
    var lookupResult =
        resolve<LookupStep>(nodes: nodes, context: context, db: db);
    if (lookupResult == null) {
      return null;
    }
    if (lookupResult is LookupStepValues) {
      return lookupResult.values.asMap()[0]?.asDouble();
    } else {
      return null;
    }
  }

  /// Lookup a variable using its CVU string and return the value as a int
  int? _resolveNodesInt(List<CVULookupNode> nodes, CVUContext context,
      database.DatabaseController db) {
    if (lookupMockMode != null) {
      return lookupMockMode!.integer;
    }
    var lookupResult =
        resolve<LookupStep>(nodes: nodes, context: context, db: db);
    if (lookupResult == null) {
      return null;
    }
    if (lookupResult is LookupStepValues) {
      return lookupResult.values.asMap()[0]?.asInt();
    } else {
      return null;
    }
  }

  /// Lookup a variable using its CVU string and return the value as a string
  String? _resolveNodesString(List<CVULookupNode> nodes, CVUContext context,
      database.DatabaseController db) {
    if (lookupMockMode != null) {
      return lookupMockMode!.string;
    }
    LookupStep? lookupResult =
        resolve<LookupStep>(nodes: nodes, context: context, db: db);
    if (lookupResult == null) {
      return null;
    }
    if (lookupResult is LookupStepValues) {
      return lookupResult.values.asMap()[0]?.asString();
    } else {
      return null;
    }
  }

  /// Lookup a variable using its CVU string and return the value as a bool
  bool? _resolveNodesBool(List<CVULookupNode> nodes, CVUContext context,
      database.DatabaseController db) {
    if (lookupMockMode != null) {
      return lookupMockMode!.boolean;
    }
    LookupStep? lookupResult =
        resolve<LookupStep>(nodes: nodes, context: context, db: db);
    if (lookupResult == null) {
      return null;
    }
    if (lookupResult is LookupStepValues) {
      return lookupResult.values.asMap()[0]?.asBool();
    } else if (lookupResult is LookupStepItems) {
      return lookupResult.items.isNotEmpty;
    } else {
      return null;
    }
  }

  /// Lookup using a CVU expression string and return the value as an item
  Item? _resolveNodesItem(List<CVULookupNode> nodes, CVUContext context,
      database.DatabaseController db) {
    LookupStep? lookupResult =
        resolve<LookupStep>(nodes: nodes, context: context, db: db);
    if (lookupResult == null) {
      return null;
    }
    if (lookupResult is LookupStepItems) {
      return lookupResult.items.asMap()[0];
    } else {
      return null;
    }
  }

  /// Lookup using a CVU expression string and return the value as an array of items
  List<Item> _resolveNodesItemArray(List<CVULookupNode> nodes,
      CVUContext context, database.DatabaseController db) {
    LookupStep? lookupResult =
        resolve<LookupStep>(nodes: nodes, context: context, db: db);
    if (lookupResult == null) {
      return [];
    }
    if (lookupResult is LookupStepItems) {
      return lookupResult.items;
    } else {
      return [];
    }
  }

  Item? _resolveExpressionItem(CVUExpressionNode expression, CVUContext context,
      database.DatabaseController db) {
    if (expression is CVUExpressionNodeLookup) {
      return resolve<Item>(nodes: expression.nodes, context: context, db: db);
    } else if (expression is CVUExpressionNodeConditional) {
      bool conditionResolved = resolve<bool>(
              expression: expression.condition, context: context, db: db) ??
          false;
      if (conditionResolved) {
        return resolve<Item>(
            expression: expression.trueExp, context: context, db: db);
      } else {
        return resolve<Item>(
            expression: expression.falseExp, context: context, db: db);
      }
    } else if (expression is CVUExpressionNodeOr) {
      return resolve<Item>(
              expression: expression.lhs, context: context, db: db) ??
          resolve<Item>(expression: expression.rhs, context: context, db: db);
    } else {
      return null;
    }
  }

  List<Item> _resolveExpressionItemArray(CVUExpressionNode expression,
      CVUContext context, database.DatabaseController db) {
    if (expression is CVUExpressionNodeLookup) {
      return (resolve<List>(
          nodes: expression.nodes,
          context: context,
          db: db,
          additionalType: Item)) as List<Item>;
    } else if (expression is CVUExpressionNodeConditional) {
      bool conditionResolved = resolve<bool>(
              expression: expression.condition, context: context, db: db) ??
          false;
      if (conditionResolved) {
        return (resolve<List>(
            expression: expression.trueExp,
            context: context,
            db: db,
            additionalType: Item)) as List<Item>;
      } else {
        return (resolve<List>(
            expression: expression.falseExp,
            context: context,
            db: db,
            additionalType: Item)) as List<Item>;
      }
    } else if (expression is CVUExpressionNodeAnd) {
      return ((resolve<List>(
              expression: expression.lhs,
              context: context,
              db: db,
              additionalType: Item)) as List<Item>) +
          ((resolve<List>(
              expression: expression.rhs,
              context: context,
              db: db,
              additionalType: Item)) as List<Item>);
    } else if (expression is CVUExpressionNodeOr) {
      var resolvedA = (resolve<List>(
          expression: expression.lhs,
          context: context,
          db: db,
          additionalType: Item)) as List<Item>;
      return resolvedA.length > 0
          ? resolvedA
          : (resolve<List>(
              expression: expression.rhs,
              context: context,
              db: db,
              additionalType: Item)) as List<Item>;
    } else {
      return [];
    }
  }

  double? _resolveExpressionDouble(CVUExpressionNode expression,
      CVUContext context, database.DatabaseController db) {
    if (expression is CVUExpressionNodeLookup) {
      return resolve<double>(nodes: expression.nodes, context: context, db: db);
    } else if (expression is CVUExpressionNodeConditional) {
      bool conditionResolved = resolve<bool>(
              expression: expression.condition, context: context, db: db) ??
          false;
      if (conditionResolved) {
        return resolve<double>(
            expression: expression.trueExp, context: context, db: db);
      } else {
        return resolve<double>(
            expression: expression.falseExp, context: context, db: db);
      }
    } else if (expression is CVUExpressionNodeOr) {
      return resolve<double>(
              expression: expression.lhs, context: context, db: db) ??
          resolve<double>(expression: expression.rhs, context: context, db: db);
    } else if (expression is CVUExpressionNodeNegation) {
      AppLogger.err(
          "CVU Expression error: Should not use ! operator on non-boolean value");
      return null;
    } else if (expression is CVUExpressionNodeAddition) {
      return (resolve<double>(
                  expression: expression.lhs, context: context, db: db) ??
              0) +
          (resolve<double>(
                  expression: expression.rhs, context: context, db: db) ??
              0);
    } else if (expression is CVUExpressionNodeSubtraction) {
      return (resolve<double>(
                  expression: expression.lhs, context: context, db: db) ??
              0) -
          (resolve<double>(
                  expression: expression.rhs, context: context, db: db) ??
              0);
    } else if (expression is CVUExpressionNodeConstant) {
      return expression.value.asNumber();
    } else if (expression is CVUExpressionNodeMultiplication) {
      return (resolve<double>(
                  expression: expression.lhs, context: context, db: db) ??
              0) *
          (resolve<double>(
                  expression: expression.rhs, context: context, db: db) ??
              0);
    } else if (expression is CVUExpressionNodeDivision) {
      double? lhs =
          resolve<double>(expression: expression.lhs, context: context, db: db);
      double? rhs =
          resolve<double>(expression: expression.rhs, context: context, db: db);
      if (lhs != null && rhs != null && rhs != 0) {
        return lhs / rhs;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  int? _resolveExpressionInt(CVUExpressionNode expression, CVUContext context,
      database.DatabaseController db) {
    if (expression is CVUExpressionNodeLookup) {
      return resolve<int>(nodes: expression.nodes, context: context, db: db);
    } else if (expression is CVUExpressionNodeConditional) {
      bool conditionResolved = resolve<bool>(
              expression: expression.condition, context: context, db: db) ??
          false;
      if (conditionResolved) {
        return resolve<int>(
            expression: expression.trueExp, context: context, db: db);
      } else {
        return resolve<int>(
            expression: expression.falseExp, context: context, db: db);
      }
    } else if (expression is CVUExpressionNodeOr) {
      return resolve<int>(
              expression: expression.lhs, context: context, db: db) ??
          resolve<int>(expression: expression.rhs, context: context, db: db);
    } else if (expression is CVUExpressionNodeNegation) {
      AppLogger.err(
          "CVU Expression error: Should not use ! operator on non-boolean value");
      return null;
    } else if (expression is CVUExpressionNodeAddition) {
      return (resolve<int>(
                  expression: expression.lhs, context: context, db: db) ??
              0) +
          (resolve<int>(expression: expression.rhs, context: context, db: db) ??
              0);
    } else if (expression is CVUExpressionNodeSubtraction) {
      return (resolve<int>(
                  expression: expression.lhs, context: context, db: db) ??
              0) -
          (resolve<int>(expression: expression.rhs, context: context, db: db) ??
              0);
    } else if (expression is CVUExpressionNodeConstant) {
      return expression.value.asInt();
    } else if (expression is CVUExpressionNodeMultiplication) {
      return (resolve<int>(
                  expression: expression.lhs, context: context, db: db) ??
              0) *
          (resolve<int>(expression: expression.rhs, context: context, db: db) ??
              0);
    } else if (expression is CVUExpressionNodeDivision) {
      int? lhs =
          resolve<int>(expression: expression.lhs, context: context, db: db);
      int? rhs =
          resolve<int>(expression: expression.rhs, context: context, db: db);
      if (lhs != null && rhs != null && rhs != 0) {
        return (lhs / rhs).floor();
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  String? _resolveExpressionString(CVUExpressionNode expression,
      CVUContext context, database.DatabaseController db) {
    if (expression is CVUExpressionNodeLookup) {
      return resolve<String>(nodes: expression.nodes, context: context, db: db);
    } else if (expression is CVUExpressionNodeConditional) {
      bool conditionResolved = resolve<bool>(
              expression: expression.condition, context: context, db: db) ??
          false;
      if (conditionResolved) {
        return resolve<String>(
            expression: expression.trueExp, context: context, db: db);
      } else {
        return resolve<String>(
            expression: expression.falseExp, context: context, db: db);
      }
    } else if (expression is CVUExpressionNodeOr) {
      return resolve<String>(
              expression: expression.lhs,
              context: context,
              db: db) //TODO nilIfBlank?
          ??
          resolve<String>(expression: expression.rhs, context: context, db: db);
    } else if (expression is CVUExpressionNodeNegation) {
      AppLogger.err(
          "CVU Expression error: Should not use ! operator on non-boolean value");
      return null;
    } else if (expression is CVUExpressionNodeAddition) {
      return (resolve<String>(
                  expression: expression.lhs, context: context, db: db) ??
              "") +
          (resolve<String>(
                  expression: expression.rhs, context: context, db: db) ??
              "");
    } else if (expression is CVUExpressionNodeSubtraction) {
      AppLogger.err(
          "CVU Expression error: Should not use - operator on string value");
      return null;
    } else if (expression is CVUExpressionNodeConstant) {
      return expression.value.asString();
    } else if (expression is CVUExpressionNodeStringMode) {
      return (expression.nodes.map((element) =>
              resolve<String>(expression: element, context: context, db: db)))
          .whereType<String>()
          .join();
    } else {
      return null;
    }
  }

  bool? _resolveExpressionBool(CVUExpressionNode expression, CVUContext context,
      database.DatabaseController db) {
    if (expression is CVUExpressionNodeLookup) {
      return resolve<bool>(nodes: expression.nodes, context: context, db: db);
    } else if (expression is CVUExpressionNodeConditional) {
      bool conditionResolved = resolve<bool>(
              expression: expression.condition, context: context, db: db) ??
          false;
      if (conditionResolved) {
        return resolve<bool>(
            expression: expression.trueExp, context: context, db: db);
      } else {
        return resolve<bool>(
            expression: expression.falseExp, context: context, db: db);
      }
    } else if (expression is CVUExpressionNodeAnd) {
      return (resolve<bool>(
                  expression: expression.lhs, context: context, db: db) ??
              false) &&
          (resolve<bool>(
                  expression: expression.rhs, context: context, db: db) ??
              false);
    } else if (expression is CVUExpressionNodeOr) {
      return (resolve<bool>(
                  expression: expression.lhs, context: context, db: db) ??
              false) ||
          (resolve<bool>(
                  expression: expression.rhs, context: context, db: db) ??
              false);
    } else if (expression is CVUExpressionNodeNegation) {
      bool? res = resolve<bool>(
          expression: expression.expression, context: context, db: db);
      return res == null ? res : !res;
    } else if (expression is CVUExpressionNodeAddition) {
      AppLogger.err(
          "CVU Expression error: Should not use + operator on bool value");
      return null;
    } else if (expression is CVUExpressionNodeSubtraction) {
      AppLogger.err(
          "CVU Expression error: Should not use - operator on bool value");
      return null;
    } else if (expression is CVUExpressionNodeConstant) {
      return expression.value.asBool();
    } else if (expression is CVUExpressionNodeLessThan) {
      double? lhs =
          resolve<double>(expression: expression.lhs, context: context, db: db);
      double? rhs =
          resolve<double>(expression: expression.rhs, context: context, db: db);
      if (lhs == null || rhs == null) {
        return null;
      }
      return lhs < rhs;
    } else if (expression is CVUExpressionNodeGreaterThan) {
      double? lhs =
          resolve<double>(expression: expression.lhs, context: context, db: db);
      double? rhs =
          resolve<double>(expression: expression.rhs, context: context, db: db);
      if (lhs == null || rhs == null) {
        return null;
      }
      return lhs > rhs;
    } else if (expression is CVUExpressionNodeLessThanOrEqual) {
      double? lhs =
          resolve<double>(expression: expression.lhs, context: context, db: db);
      double? rhs =
          resolve<double>(expression: expression.rhs, context: context, db: db);
      if (lhs == null || rhs == null) {
        return null;
      }
      return lhs <= rhs;
    } else if (expression is CVUExpressionNodeGreaterThanOrEqual) {
      double? lhs =
          resolve<double>(expression: expression.lhs, context: context, db: db);
      double? rhs =
          resolve<double>(expression: expression.rhs, context: context, db: db);
      if (lhs == null || rhs == null) {
        return null;
      }
      return lhs >= rhs;
    } else if (expression is CVUExpressionNodeAreEqual) {
      dynamic lhs =
          resolve<double>(expression: expression.lhs, context: context, db: db);
      dynamic rhs =
          resolve<double>(expression: expression.rhs, context: context, db: db);
      if (lhs == null || rhs == null) {
        lhs =
            resolve<Item>(expression: expression.lhs, context: context, db: db);
        rhs =
            resolve<Item>(expression: expression.rhs, context: context, db: db);
        if (lhs is Item && rhs is Item) {
          return lhs.id == rhs.id;
        }
      }
      if (lhs == null || rhs == null) {
        lhs = resolve<String>(
            expression: expression.lhs, context: context, db: db);
        rhs = resolve<String>(
            expression: expression.rhs, context: context, db: db);
      }
      if (lhs == null || rhs == null) {
        lhs =
            resolve<bool>(expression: expression.lhs, context: context, db: db);
        rhs =
            resolve<bool>(expression: expression.rhs, context: context, db: db);
      }
      if (lhs == null || rhs == null) {
        return false;
      }
      return lhs == rhs;
    } else if (expression is CVUExpressionNodeAreNotEqual) {
      dynamic lhs =
          resolve<double>(expression: expression.lhs, context: context, db: db);
      dynamic rhs =
          resolve<double>(expression: expression.rhs, context: context, db: db);
      if (lhs == null || rhs == null) {
        lhs =
            resolve<Item>(expression: expression.lhs, context: context, db: db);
        rhs =
            resolve<Item>(expression: expression.rhs, context: context, db: db);
        if (lhs is Item && rhs is Item) {
          return lhs.id != rhs.id;
        }
      }
      if (lhs == null || rhs == null) {
        lhs = resolve<String>(
            expression: expression.lhs, context: context, db: db);
        rhs = resolve<String>(
            expression: expression.rhs, context: context, db: db);
      }
      if (lhs == null || rhs == null) {
        lhs =
            resolve<bool>(expression: expression.lhs, context: context, db: db);
        rhs =
            resolve<bool>(expression: expression.rhs, context: context, db: db);
      }
      if (lhs == null || rhs == null) {
        return true;
      }
      return lhs != rhs;
    } else {
      return null;
    }
  }
}

class LookupMock {
  final bool boolean;
  final String string;
  final double number;
  final int integer;

  LookupMock(this.boolean, this.string, this.number, this.integer);
}

class LookupStepItems extends LookupStep {
  final List<Item> items;

  LookupStepItems(this.items);
}

class LookupStepValues extends LookupStep {
  final List<PropertyDatabaseValue> values;

  LookupStepValues(this.values);
}

class LookupStepContext extends LookupStep {
  final CVUContext context;

  LookupStepContext(this.context);
}

abstract class LookupStep {}
