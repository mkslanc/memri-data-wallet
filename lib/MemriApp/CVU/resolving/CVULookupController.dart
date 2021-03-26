//
//  CVULookup.swift
//  MemriDatabase
//
//  Created by T Brennan on 23/12/20.
//

import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Expression.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_LookupNode.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemPropertyRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/Controllers/Database/Schema.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';

import 'CVUContext.dart';
import 'CVUViewArguments.dart';

/// This struct can be used to _resolve CVU values to a final value of the desired type.
/// For lookups you must provide a CVUContext which contains required information on the default item, viewArguments, etc to be used in the lookup.
class CVULookupController {
  LookupMock? lookupMockMode;

  CVULookupController([this.lookupMockMode]);

  T? resolve<T>(
      {CVUValue? value,
      List<CVULookupNode>? nodes,
      String? edge,
      ItemRecord? item,
      String? property,
      CVUExpressionNode? expression,
      CVUContext? context,
      dynamic? defaultValue,
      DatabaseController? db}) {
    switch (T) {
      case double:
        if (nodes != null) {
          return _resolveNodesDouble(nodes, context!, db!) as T?;
        } else if (expression != null) {
          return _resolveExpressionDouble(expression, context!, db!) as T?;
        }
        return _resolveDouble(value!, context!, db!) as T?;
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
      case ItemRecord:
        if (edge != null) {
          return _resolveEdgeItemRecord(edge, item!, db!) as T?;
        } else if (nodes != null) {
          return _resolveNodesItemRecord(nodes, context!, db!) as T?;
        } else if (expression != null) {
          return _resolveExpressionItemRecord(expression, context!, db!) as T?;
        }
        return _resolveItemRecord(value!, context!, db!) as T?;
      case List: //TODO this wouldn't work @anijanyan
        if (edge != null) {
          return _resolveEdgeItemRecordArray(edge, item!, db!) as T?;
        } else if (nodes != null) {
          return _resolveNodesItemRecordArray(nodes, context!, db!) as T?;
        } else if (expression != null) {
          return _resolveExpressionItemRecordArray(expression, context!, db!) as T?;
        }
        return _resolveItemRecordArray(value!, context!, db!) as T?;
      case Binding:
        return _resolveBinding(value!, context!, db!, defaultValue) as T?;
      case LookupStep:
        return _resolveLookupStep(nodes!, context!, db!) as T?;
      case PropertyDatabaseValue:
        return _resolvePropertyDatabaseValue(property!, item!, db!) as T?;
      default:
        throw Exception("Type is required");
    }
  }

  double? _resolveDouble(CVUValue value, CVUContext context, DatabaseController db) {
    if (value is CVUValueConstant) {
      return value.value.asNumber();
    } else if (value is CVUValueExpression) {
      return resolve<double>(expression: value.value, context: context, db: db);
    } else {
      return null;
    }
  }

  String? _resolveString(CVUValue value, CVUContext context, DatabaseController db) {
    if (value is CVUValueConstant) {
      return value.value.asString();
    } else if (value is CVUValueExpression) {
      return resolve<String>(expression: value.value, context: context, db: db);
    } else {
      return null;
    }
  }

  bool? _resolveBool(CVUValue value, CVUContext context, DatabaseController db) {
    if (value is CVUValueConstant) {
      return value.value.asBool();
    } else if (value is CVUValueExpression) {
      return resolve<bool>(expression: value.value, context: context, db: db);
    } else {
      return null;
    }
  }

  DateTime? _resolveDate(CVUValue value, CVUContext context, DatabaseController db) {
    if (value is CVUValueConstant) {
      return DateTime.fromMicrosecondsSinceEpoch(
          int.parse(value.value.asNumber().toString()) * 1000); //TODO is this right? @anijanyan
    } else if (value is CVUValueExpression) {
      return resolve<DateTime>(expression: value.value, context: context, db: db);
    } else {
      return null;
    }
  }

  ItemRecord? _resolveItemRecord(CVUValue value, CVUContext context, DatabaseController db) {
    if (value is CVUValueConstant) {
      return null;
    } else if (value is CVUValueItem) {
      return ItemRecord.getWithUID(value.value, db);
    } else if (value is CVUValueExpression) {
      return resolve<ItemRecord>(expression: value.value, context: context, db: db);
    } else {
      return null;
    }
  }

  List<ItemRecord> _resolveItemRecordArray(CVUValue value, CVUContext context, DatabaseController db) {
    if (value is CVUValueItem) {
      String itemUID = value.value;
      ItemRecord? itemRecord = ItemRecord.getWithUID(itemUID, db);
      return (itemRecord != null) ? [itemRecord] : [];
    } else if (value is CVUValueExpression) {
      CVUExpressionNode expression = value.value;
      return resolve<List<ItemRecord>>(expression: expression, context: context, db: db)!; //TODO List<ItemRecord>
    } else {
      return [];
    }
  }

  Binding<dynamic>? _resolveBinding(CVUValue value, CVUContext context, DatabaseController db, dynamic? defaultValue) {
    if (value is CVUValueExpression) {
      var expression = value.value;
      if (expression is CVUExpressionNodeLookup) {
        var nodes = expression.nodes;
        List? res = _resolveToItemAndProperty(nodes, context, db);
        ItemRecord? item = res?[0];
        String? property = res?[1];
        if (res != null && item != null && property != null) {
          return item.propertyBinding(name: property, defaultValue: defaultValue);
        }
      }
      return null;
    } else {
      return null;
    }
  }

  /// Lookup an edge from an ItemRecord
  ItemRecord? _resolveEdgeItemRecord(String edge, ItemRecord item, DatabaseController db) {
    return item.edgeItem(edge, db);
  }

  /// Lookup an edge array from an ItemRecord
  List<ItemRecord> _resolveEdgeItemRecordArray(String edge, ItemRecord item, DatabaseController db) {
    return item.edgeItems(edge, db);
  }

  /// Lookup an edge array from an ItemRecord
  PropertyDatabaseValue? _resolvePropertyDatabaseValue(String property, ItemRecord item, DatabaseController db) {
    return item.property(property, db)?.value(item.type, db.schema);
  }

  LookupStep? _resolveLookupStep(List<CVULookupNode> nodes, CVUContext context, DatabaseController db) {
    LookupStep? currentValue;
    for (CVULookupNode node in nodes) {
      var nodeType = node.type;

      if (nodeType is CVULookupTypeDefault) {
        ItemRecord? currentItem = context.currentItem;
        if (currentItem == null) {
          return null;
        }
        currentValue = LookupStepItems([currentItem]);
      } else if (nodeType is CVULookupTypeFunction) {
        List<CVUExpressionNode> args = nodeType.args;
        switch (node.name.toLowerCase()) {
          case "item":
            var exp = nodeType.args[0];
            String? itemUIDString = resolve<String>(expression: exp, context: context, db: db);
            if (itemUIDString == null || itemUIDString.isEmpty) {
              return null;
            }
            ItemRecord? item = ItemRecord.getWithUID(itemUIDString, db);
            if (item == null) {
              return null;
            }
            currentValue = LookupStepItems([item]);
            break;
          case "joined":
            if (currentValue == null || currentValue is! LookupStepValues) {
              return null;
            }
            var exp = args[0];
            String? separator;
            separator = resolve<String>(expression: exp, context: context, db: db);

            if (separator != null && separator.isNotEmpty) {
              String joined = currentValue.values
                  .map((element) => element.asString())
                  .where((element) => element.isNotEmpty)
                  .join(separator);
              currentValue =
                  LookupStepValues([PropertyDatabaseValueString(joined)]);
            } else {
              String joined = currentValue.values
                  .map((element) => element.asString())
                  .where((element) => element.isNotEmpty)
                  .join(
                      ", "); //TODO @anijanyan String.localizedString(strings);
              currentValue =
                  LookupStepValues([PropertyDatabaseValueString(joined)]);
            }
            break;
          case "joinwithcomma":
            String joined = args
                .map((element) => resolve<String>(
                        expression: element, context: context, db: db)
                    .toString())
                .where((element) => element.isNotEmpty)
                .join(", ");
            currentValue =
                LookupStepValues([PropertyDatabaseValueString(joined)]);
            break;
          case "joinnatural":
            List<String> strings = args
                .map((element) => resolve<String>(
                        expression: element, context: context, db: db)
                    .toString())
                .where((element) => element.isNotEmpty)
                .toList();
            var joined = strings
                .join(", "); //TODO @anijanyan String.localizedString(strings);
            currentValue =
                LookupStepValues([PropertyDatabaseValueString(joined)]);
            break;
          case "plainstring":
            if (currentValue == null || currentValue is! LookupStepValues) {
              return null;
            }
            List<PropertyDatabaseValue> stripped = currentValue.values
                .map((PropertyDatabaseValue value) {
                  String htmlstring = value.asString();
                  if (htmlstring.isEmpty) {
                    return null;
                  }
                  return PropertyDatabaseValueString(htmlstring);
                  //TODO return PropertyDatabaseValueString(DOMPurify.sanitize(htmlstring, {ALLOWED_TAGS: []}))
                })
                .whereType<PropertyDatabaseValue>()
                .toList();

            currentValue = LookupStepValues(stripped);
            break;
          case "first":
            if (currentValue == null) {
              return null;
            }

            if (currentValue is LookupStepValues) {
              currentValue = LookupStepValues([currentValue.values[0]]);
            } else if (currentValue is LookupStepItems) {
              currentValue = LookupStepItems([currentValue.items[0]]);
            } else {
              return null;
            }
            break;
          case "last":
            if (currentValue == null) {
              return null;
            }

            if (currentValue is LookupStepValues) {
              currentValue = LookupStepValues([currentValue.values.last]);
            } else if (currentValue is LookupStepItems) {
              currentValue = LookupStepItems([currentValue.items.last]);
            } else {
              return null;
            }
            break;
          case "fullname":
            if (currentValue is LookupStepItems) {
              if (currentValue.items.isEmpty) {
                return null;
              }
              ItemRecord first = currentValue.items[0];
              if (first.type == "Person") {
                String name = [
                  resolve<PropertyDatabaseValue>(property: "firstName", item: first, db: db),
                  resolve<PropertyDatabaseValue>(property: "lastName", item: first, db: db)
                ].map((element) => element!.asString()).join(" ");
                currentValue = LookupStepValues([PropertyDatabaseValueString(name)]);
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
                  .map((element) => element.asString()[0])
                  .where((element) => element.isNotEmpty)
                  .join()
                  .toUpperCase();
              currentValue = LookupStepValues([PropertyDatabaseValueString(initials)]);
            } else if (currentValue is LookupStepItems) {
              if (currentValue.items.isEmpty) {
                return null;
              }
              ItemRecord first = currentValue.items[0];
              if (first.type == "Person") {
                String initials = [
                  resolve<PropertyDatabaseValue>(
                      property: "firstName", item: first, db: db),
                  resolve<PropertyDatabaseValue>(
                      property: "lastName", item: first, db: db)
                ]
                    .map((element) => element?.asString()[0])
                    .where((element) => element != null && element.isNotEmpty)
                    .join()
                    .toUpperCase();
                currentValue = LookupStepValues([PropertyDatabaseValueString(initials)]);
              } else {
                return null;
              }
            } else {
              return null;
            }
            break;
          default:
            return null;
        }
      } else if (nodeType is CVULookupTypeLookup) {
        if (currentValue is LookupStepItems) {
          currentValue = itemLookup(
              node: node,
              items: currentValue.items,
              subexpression: nodeType.subExpression,
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
                currentValue = LookupStepValues([PropertyDatabaseValueString(constant.value)]);
              } else if (constant is CVUConstantNumber) {
                currentValue = LookupStepValues([PropertyDatabaseValueDouble(constant.value)]);
              } else if (constant is CVUConstantString) {
                currentValue = LookupStepValues([PropertyDatabaseValueString(constant.value)]);
              } else if (constant is CVUConstantBool) {
                currentValue = LookupStepValues([PropertyDatabaseValueBool(constant.value)]);
              } else if (constant is CVUConstantColorHex) {
                currentValue = LookupStepValues([PropertyDatabaseValueString(constant.value)]);
              } else if (constant is CVUConstantNil) {
                currentValue = null;
              } else {
                throw Exception("Unknown CVUConstant: ${constant.toString()}");
              }
            } else if (argValue is CVUValueExpression) {
              CVUExpressionNode expression = argValue.value;
              var context = CVUContext(currentItem: viewArgs.argumentItem, viewArguments: viewArgs.parentArguments);
              ItemRecord? item = resolve<ItemRecord>(expression: expression, context: context, db: db);
              double? number = resolve<double>(expression: expression, context: context, db: db);
              String? string = resolve<String>(expression: expression, context: context, db: db);

              if (item != null) {
                currentValue = LookupStepItems([item]);
              } else if (number != null) {
                currentValue =
                    LookupStepValues([PropertyDatabaseValueDouble(number)]);
              } else if (string != null) {
                currentValue =
                    LookupStepValues([PropertyDatabaseValueString(string)]);
              } else {
                var items = resolve<List<ItemRecord>>(expression: expression, context: context, db: db)!;
                if (items.isNotEmpty) {
                  currentValue = LookupStepItems(items);
                } else {
                  return null;
                }
              }
            } else {
              return null;
            }
          }
        } else {
          return null;
        }
      } else {
        throw Exception("Unknown CVULookupType ${nodeType.toString()}");
      }
    }

    return currentValue;
  }

  List<ItemRecord> filter(List<ItemRecord> items, CVUExpressionNode? subexpression, DatabaseController? db) {
    CVUExpressionNode? exp = subexpression;
    if (exp == null) {
      return items;
    }
    return items.where((item) {
      CVUContext context = CVUContext(currentItem: item);
      return resolve<bool>(expression: exp, context: context, db: db) ?? false;
    }).toList();
  }

  LookupStep? itemLookup(
      {required CVULookupNode node,
      required List<ItemRecord> items,
      CVUExpressionNode? subexpression,
      required CVUContext context,
      required DatabaseController db}) {
    if (items.isEmpty) {
      return null;
    }
    String trimmedName = node.name.replaceAll(RegExp(r"(^~)|(~$)"), ""); //TODO @anijanyan check if this works
    switch (node.name[0]) {
      case "~":

        /// LOOKUP REVERSE EDGE FOR EACH ITEM
        if (node.isArray) {
          List<ItemRecord> result =
              items.map((item) => item.reverseEdgeItems(trimmedName, db)).expand((i) => i).toList();
          return LookupStepItems(filter(result, subexpression, db));
        } else {
          List<ItemRecord> result =
              items.map((item) => item.reverseEdgeItem(trimmedName, db)).whereType<ItemRecord>().toList();
          return LookupStepItems(filter(result, subexpression, db));
        }
      default:
        /// CHECK IF WE'RE EXPECTING EDGES OR PROPERTIES
        String itemType = items[0].type;
        /// Check if this is an intrinsic property
        switch (node.name) {
          case "uid":
            return LookupStepValues(items.map((element) => PropertyDatabaseValueString(element.uid)).toList());
          case "dateModified":
            return LookupStepValues(
                items.map((element) => PropertyDatabaseValueDatetime(element.dateModified)).toList());
          case "dateCreated":
            return LookupStepValues(items
                .map((element) =>
                    PropertyDatabaseValueDatetime(element.dateCreated))
                .toList());
          default:
            break;
        }

        /// Find out if it is a property or an edge (according to schema)
        var expectedType = db.schema?.expectedType(itemType: itemType, propertyOrEdgeName: node.name);
        if (expectedType is ResolvedTypeProperty) {
          /// LOOKUP PROPERTY FOR EACH ITEM
          List<PropertyDatabaseValue> result = items
              .map((item) {
                ItemPropertyRecord? property = item.property(node.name, db);
                PropertyDatabaseValue? value = property?.value(item.type, db.schema);
                if (property == null || value == null) {
                  return null;
                }
                return value;
              })
              .whereType<PropertyDatabaseValue>()
              .toList();
          return LookupStepValues(result);
        } else if (expectedType is ResolvedTypeEdge) {
          /// LOOKUP EDGE FOR EACH ITEM
          if (node.isArray) {
            List<ItemRecord> result =
                items.map((item) => item.edgeItems(trimmedName, db)).expand((element) => element).toList();
            return LookupStepItems(filter(result, subexpression, db));
          } else {
            List<ItemRecord> result =
                items.map((item) => item.edgeItem(trimmedName, db)).whereType<ItemRecord>().toList();
            return LookupStepItems(filter(result, subexpression, db));
          }
        } else {
          return null;
        }
    }
  }

  /// Lookup a variable using its CVU string and return the value as a double
  double? _resolveNodesDouble(List<CVULookupNode> nodes, CVUContext context, DatabaseController db) {
    if (lookupMockMode != null) {
      return lookupMockMode!.number;
    }
    var lookupResult = resolve<LookupStep>(nodes: nodes, context: context, db: db);
    if (lookupResult == null) {
      return null;
    }
    if (lookupResult is LookupStepValues) {
      return lookupResult.values[0].asDouble();
    } else {
      return null;
    }
  }

  /// Lookup a variable using its CVU string and return the value as a string
  String? _resolveNodesString(List<CVULookupNode> nodes, CVUContext context, DatabaseController db) {
    if (lookupMockMode != null) {
      return lookupMockMode!.string;
    }
    LookupStep? lookupResult = resolve<LookupStep>(nodes: nodes, context: context, db: db);
    if (lookupResult == null) {
      return null;
    }
    if (lookupResult is LookupStepValues) {
      return lookupResult.values[0].asString();
    } else {
      return null;
    }
  }

  /// Lookup a variable using its CVU string and return the value as a bool
  bool? _resolveNodesBool(List<CVULookupNode> nodes, CVUContext context, DatabaseController db) {
    if (lookupMockMode != null) {
      return lookupMockMode!.boolean;
    }
    LookupStep? lookupResult = resolve<LookupStep>(nodes: nodes, context: context, db: db);
    if (lookupResult == null) {
      return null;
    }
    if (lookupResult is LookupStepValues) {
      return lookupResult.values[0].asBool();
    } else if (lookupResult is LookupStepItems) {
      return lookupResult.items.isNotEmpty;
    } else {
      return null;
    }
  }

  /// Lookup using a CVU expression string and return the value as an item
  ItemRecord? _resolveNodesItemRecord(List<CVULookupNode> nodes, CVUContext context, DatabaseController db) {
    LookupStep? lookupResult = resolve<LookupStep>(nodes: nodes, context: context, db: db);
    if (lookupResult == null) {
      return null;
    }
    if (lookupResult is LookupStepItems) {
      return lookupResult.items[0];
    } else {
      return null;
    }
  }

  /// Lookup using a CVU expression string and return the value as an array of items
  List<ItemRecord> _resolveNodesItemRecordArray(List<CVULookupNode> nodes, CVUContext context, DatabaseController db) {
    LookupStep? lookupResult = resolve<LookupStep>(nodes: nodes, context: context, db: db);
    if (lookupResult == null) {
      return [];
    }
    if (lookupResult is LookupStepItems) {
      return lookupResult.items;
    } else {
      return [];
    }
  }

  ItemRecord? _resolveExpressionItemRecord(CVUExpressionNode expression, CVUContext context, DatabaseController db) {
    if (expression is CVUExpressionNodeLookup) {
      return resolve<ItemRecord>(nodes: expression.nodes, context: context, db: db);
    } else if (expression is CVUExpressionNodeConditional) {
      bool conditionResolved = resolve<bool>(expression: expression.condition, context: context, db: db) ?? false;
      if (conditionResolved) {
        return resolve<ItemRecord>(expression: expression.trueExp, context: context, db: db);
      } else {
        return resolve<ItemRecord>(expression: expression.falseExp, context: context, db: db);
      }
    } else if (expression is CVUExpressionNodeOr) {
      return resolve<ItemRecord>(expression: expression.lhs, context: context, db: db) ??
          resolve<ItemRecord>(expression: expression.rhs, context: context, db: db);
    } else {
      return null;
    }
  }

  List<ItemRecord> _resolveExpressionItemRecordArray(
      CVUExpressionNode expression, CVUContext context, DatabaseController db) {
    if (expression is CVUExpressionNodeLookup) {
      return resolve<List<ItemRecord>>(nodes: expression.nodes, context: context, db: db)!;
    } else if (expression is CVUExpressionNodeConditional) {
      bool conditionResolved = resolve<bool>(expression: expression.condition, context: context, db: db) ?? false;
      if (conditionResolved) {
        return resolve<List<ItemRecord>>(expression: expression.trueExp, context: context, db: db)!;
      } else {
        return resolve<List<ItemRecord>>(expression: expression.falseExp, context: context, db: db)!;
      }
    } else if (expression is CVUExpressionNodeAnd) {
      return resolve<List<ItemRecord>>(expression: expression.lhs, context: context, db: db)! +
          resolve<List<ItemRecord>>(expression: expression.rhs, context: context, db: db)!;
    } else {
      return [];
    }
  }

  double? _resolveExpressionDouble(CVUExpressionNode expression, CVUContext context, DatabaseController db) {
    if (expression is CVUExpressionNodeLookup) {
      return resolve<double>(nodes: expression.nodes, context: context, db: db);
    } else if (expression is CVUExpressionNodeConditional) {
      bool conditionResolved = resolve<bool>(expression: expression.condition, context: context, db: db) ?? false;
      if (conditionResolved) {
        return resolve<double>(expression: expression.trueExp, context: context, db: db);
      } else {
        return resolve<double>(expression: expression.falseExp, context: context, db: db);
      }
    } else if (expression is CVUExpressionNodeOr) {
      return resolve<double>(expression: expression.lhs, context: context, db: db) ??
          resolve<double>(expression: expression.rhs, context: context, db: db);
    } else if (expression is CVUExpressionNodeNegation) {
      print("CVU Expression error: Should not use ! operator on non-boolean value");
      return null;
    } else if (expression is CVUExpressionNodeAddition) {
      return (resolve<double>(expression: expression.lhs, context: context, db: db) ?? 0) +
          (resolve<double>(expression: expression.rhs, context: context, db: db) ?? 0);
    } else if (expression is CVUExpressionNodeSubtraction) {
      return (resolve<double>(expression: expression.lhs, context: context, db: db) ?? 0) -
          (resolve<double>(expression: expression.rhs, context: context, db: db) ?? 0);
    } else if (expression is CVUExpressionNodeConstant) {
      return expression.value.asNumber();
    } else if (expression is CVUExpressionNodeMultiplication) {
      return (resolve<double>(expression: expression.lhs, context: context, db: db) ?? 0) *
          (resolve<double>(expression: expression.rhs, context: context, db: db) ?? 0);
    } else if (expression is CVUExpressionNodeDivision) {
      double? lhs = resolve<double>(expression: expression.lhs, context: context, db: db);
      double? rhs = resolve<double>(expression: expression.rhs, context: context, db: db);
      if (lhs != null && rhs != null && rhs != 0) {
        return lhs / rhs;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  String? _resolveExpressionString(CVUExpressionNode expression, CVUContext context, DatabaseController db) {
    if (expression is CVUExpressionNodeLookup) {
      return resolve<String>(nodes: expression.nodes, context: context, db: db);
    } else if (expression is CVUExpressionNodeConditional) {
      bool conditionResolved = resolve<bool>(expression: expression.condition, context: context, db: db) ?? false;
      if (conditionResolved) {
        return resolve<String>(expression: expression.trueExp, context: context, db: db);
      } else {
        return resolve<String>(expression: expression.falseExp, context: context, db: db);
      }
    } else if (expression is CVUExpressionNodeOr) {
      return resolve<String>(expression: expression.lhs, context: context, db: db) //TODO nilIfBlank?
          ??
          resolve<String>(expression: expression.rhs, context: context, db: db);
    } else if (expression is CVUExpressionNodeNegation) {
      print("CVU Expression error: Should not use ! operator on non-boolean value");
      return null;
    } else if (expression is CVUExpressionNodeAddition) {
      return (resolve<String>(expression: expression.lhs, context: context, db: db) ?? "") +
          (resolve<String>(expression: expression.rhs, context: context, db: db) ?? "");
    } else if (expression is CVUExpressionNodeSubtraction) {
      print("CVU Expression error: Should not use - operator on string value");
      return null;
    } else if (expression is CVUExpressionNodeConstant) {
      return expression.value.asString();
    } else if (expression is CVUExpressionNodeStringMode) {
      return expression.nodes
          .map((element) =>
              resolve<String>(expression: element, context: context, db: db))
          .whereType<String>()
          .join();
    } else {
      return null;
    }
  }

  bool? _resolveExpressionBool(CVUExpressionNode expression, CVUContext context, DatabaseController db) {
    if (expression is CVUExpressionNodeLookup) {
      return resolve<bool>(nodes: expression.nodes, context: context, db: db);
    } else if (expression is CVUExpressionNodeConditional) {
      bool conditionResolved = resolve<bool>(expression: expression.condition, context: context, db: db) ?? false;
      if (conditionResolved) {
        return resolve<bool>(expression: expression.trueExp, context: context, db: db);
      } else {
        return resolve<bool>(expression: expression.falseExp, context: context, db: db);
      }
    } else if (expression is CVUExpressionNodeAnd) {
      return (resolve<bool>(expression: expression.lhs, context: context, db: db) ?? false) &&
          (resolve<bool>(expression: expression.rhs, context: context, db: db) ?? false);
    } else if (expression is CVUExpressionNodeOr) {
      return (resolve<bool>(expression: expression.lhs, context: context, db: db) ?? false) ||
          (resolve<bool>(expression: expression.rhs, context: context, db: db) ?? false);
    } else if (expression is CVUExpressionNodeNegation) {
      bool? res = resolve<bool>(expression: expression.expression, context: context, db: db);
      return res == null ? res : !res;
    } else if (expression is CVUExpressionNodeAddition) {
      print("CVU Expression error: Should not use + operator on bool value");
      return null;
    } else if (expression is CVUExpressionNodeSubtraction) {
      print("CVU Expression error: Should not use - operator on bool value");
      return null;
    } else if (expression is CVUExpressionNodeConstant) {
      return expression.value.asBool();
    } else if (expression is CVUExpressionNodeLessThan) {
      double? lhs = resolve<double>(expression: expression.lhs, context: context, db: db);
      double? rhs = resolve<double>(expression: expression.rhs, context: context, db: db);
      if (lhs == null || rhs == null) {
        return null;
      }
      return lhs < rhs;
    } else if (expression is CVUExpressionNodeGreaterThan) {
      double? lhs = resolve<double>(expression: expression.lhs, context: context, db: db);
      double? rhs = resolve<double>(expression: expression.rhs, context: context, db: db);
      if (lhs == null || rhs == null) {
        return null;
      }
      return lhs > rhs;
    } else if (expression is CVUExpressionNodeLessThanOrEqual) {
      double? lhs = resolve<double>(expression: expression.lhs, context: context, db: db);
      double? rhs = resolve<double>(expression: expression.rhs, context: context, db: db);
      if (lhs == null || rhs == null) {
        return null;
      }
      return lhs <= rhs;
    } else if (expression is CVUExpressionNodeGreaterThanOrEqual) {
      double? lhs = resolve<double>(expression: expression.lhs, context: context, db: db);
      double? rhs = resolve<double>(expression: expression.rhs, context: context, db: db);
      if (lhs == null || rhs == null) {
        return null;
      }
      return lhs >= rhs;
    } else if (expression is CVUExpressionNodeAreEqual) {
      dynamic? lhs = resolve<double>(expression: expression.lhs, context: context, db: db);
      dynamic? rhs = resolve<double>(expression: expression.rhs, context: context, db: db);
      //TODO is this correct? @anijanyan
      if (lhs == null || rhs == null) {
        lhs = resolve<String>(expression: expression.lhs, context: context, db: db);
        rhs = resolve<String>(expression: expression.rhs, context: context, db: db);
      }
      if (lhs == null || rhs == null) {
        lhs = resolve<bool>(expression: expression.lhs, context: context, db: db);
        rhs = resolve<bool>(expression: expression.rhs, context: context, db: db);
      }
      if (lhs == null || rhs == null) {
        return false;
      }
      return lhs == rhs;
    } else if (expression is CVUExpressionNodeAreNotEqual) {
      dynamic? lhs = resolve<double>(expression: expression.lhs, context: context, db: db);
      dynamic? rhs = resolve<double>(expression: expression.rhs, context: context, db: db);
      //TODO is this correct? @anijanyan
      if (lhs == null || rhs == null) {
        lhs = resolve<String>(expression: expression.lhs, context: context, db: db);
        rhs = resolve<String>(expression: expression.rhs, context: context, db: db);
      }
      if (lhs == null || rhs == null) {
        lhs = resolve<bool>(expression: expression.lhs, context: context, db: db);
        rhs = resolve<bool>(expression: expression.rhs, context: context, db: db);
      }
      if (lhs == null || rhs == null) {
        return true;
      }
      return lhs != rhs;
    } else {
      return null;
    }
  }

/*(ItemRecord item, String property) */
  List? _resolveToItemAndProperty(List<CVULookupNode> nodes, CVUContext context, DatabaseController db) {
    ItemRecord? currentItem;
    if (currentItem == null || nodes.isEmpty) {
      return null;
    }

    // Find the item referenced by the lookup
    CVULookupNode? last = nodes.removeLast();
    for (CVULookupNode node in nodes) {
      var nodeType = node.type;
      if (nodeType is CVULookupTypeDefault) {
        ItemRecord? defaultItem = context.currentItem;
        if (defaultItem == null) {
          return null;
        }
        currentItem = defaultItem;
        break;
      } else if (nodeType is CVULookupTypeLookup) {
        ItemRecord? nextItem = currentItem;
        if (nextItem != null) {
          LookupStep? step = itemLookup(
              node: node, items: [nextItem], subexpression: nodeType.subExpression, context: context, db: db);
          if (step != null && step is LookupStepItems) {
            currentItem = step.items[0];
          }
        }
        break;
      } else if (nodeType is CVULookupTypeFunction) {
        return null;
      } else {
        throw Exception("Unknown CVULookupNode: ${nodeType.toString()}");
      }
    }
    ItemRecord? targetItem = currentItem;
    CVULookupNode? propertyLookup = last;

    // Make a binding to the right property
    return [targetItem, propertyLookup.name];
  }
}

class LookupMock {
  final bool boolean;
  final String string;
  final double number;

  LookupMock(this.boolean, this.string, this.number);
}

class LookupStepItems extends LookupStep {
  final List<ItemRecord> items;

  LookupStepItems(this.items);
}

class LookupStepValues extends LookupStep {
  final List<PropertyDatabaseValue> values;

  LookupStepValues(this.values);
}

abstract class LookupStep {}
