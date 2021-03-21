//
//  CVULookup.swift
//  MemriDatabase
//
//  Created by T Brennan on 23/12/20.
//


import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
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

  CVULookupController([lookupMockMode]);

  T? resolve<T>({
    CVUValue? value,
    List<LookupNode>? nodes,
    String? edge,
    ItemRecord? item,
    String? property,
    ExpressionNode? expression,

    CVUContext? context,
    dynamic? defaultValue,
    DatabaseController? db
  }) {
    switch (T) {
      case double:
        if (nodes != null) {
          return _resolveNodesDouble(nodes, context!, db!) as T;
        } else if (expression != null) {
          return _resolveExpressionDouble(expression, context!, db!) as T;
        }
        return _resolveDouble(value!, context!, db!) as T;
      case String:
        if (nodes != null) {
          return _resolveNodesString(nodes, context!, db!) as T;
        } else if (expression != null) {
          return _resolveExpressionString(expression, context!, db!) as T;
        }
        return _resolveString(value!, context!, db!) as T;
      case bool:
        if (nodes != null) {
          return _resolveNodesBool(nodes, context!, db!) as T;
        } else if (expression != null) {
          return _resolveExpressionBool(expression, context!, db!) as T;
        }
        return _resolveBool(value!, context!, db!) as T;
      case DateTime:
        return _resolveDate(value!, context!, db!) as T;
      case ItemRecord:
        if (edge != null) {
          return _resolveEdgeItemRecord(edge, item!, db!) as T;
        } else if (nodes != null) {
          return _resolveNodesItemRecord(nodes, context!, db!) as T;
        } else if (expression != null) {
          return _resolveExpressionItemRecord(expression, context!, db!) as T;
        }
        return _resolveItemRecord(value!, context!, db!) as T;
      case List:
        if (edge != null) {
          return _resolveEdgeItemRecordArray(edge, item!, db!) as T;
        } else if (nodes != null) {
          return _resolveNodesItemRecordArray(nodes, context!, db!) as T;
        } else if (expression != null) {
          return _resolveExpressionItemRecordArray(expression, context!, db!) as T;
        }
        return _resolveItemRecordArray(value!, context!, db!) as T;
      case Binding:
        return _resolveBinding(value!, context!, db!, defaultValue) as T;
      case LookupStep:
        return _resolveLookupStep(nodes!, context!, db!) as T;
      case PropertyDatabaseValue:
        return _resolvePropertyDatabaseValue(property!, item!, db!) as T;
      default:
        throw Exception("Type is required");
    }
  }


  double? _resolveDouble(CVUValue value, CVUContext context, DatabaseController db) {
    switch (value.type) {
      case CVUValueType.constant:
        CVUValue_Constant constant = value.value;
        return constant.asNumber();
      case CVUValueType.expression:
        ExpressionNode expression = value.value;
        return resolve<double>(expression: expression, context: context, db: db);
      default:
        return null;
    }
  }

  String? _resolveString(CVUValue value, CVUContext context, DatabaseController db) {
    switch (value.type) {
      case CVUValueType.constant:
        CVUValue_Constant constant = value.value;
        return constant.asString();
      case CVUValueType.expression:
        ExpressionNode expression = value.value;
        return resolve<String>(expression: expression, context: context, db: db);
      default:
        return null;
    }
  }

  bool? _resolveBool(CVUValue value, CVUContext context, DatabaseController db) {
    switch (value.type) {
      case CVUValueType.constant:
        CVUValue_Constant constant = value.value;
        return constant.asBool();
      case CVUValueType.expression:
        ExpressionNode expression = value.value;
        return resolve<bool>(expression: expression, context: context, db: db);
      default:
        return null;
    }
  }

  DateTime? _resolveDate(CVUValue value, CVUContext context, DatabaseController db) {
    switch (value.type) {
      case CVUValueType.constant:
        CVUValue_Constant constant = value.value;
        return DateTime.fromMicrosecondsSinceEpoch(
            int.parse(constant.asNumber().toString()) * 1000); //TODO is this right? @anijanyan
      case CVUValueType.expression:
        ExpressionNode expression = value.value;
        return resolve<DateTime>(expression: expression, context: context, db: db);
      default:
        return null;
    }
  }

  ItemRecord? _resolveItemRecord(CVUValue value, CVUContext context, DatabaseController db) {
    switch (value.type) {
      case CVUValueType.constant:
        return null;
      case CVUValueType.item:
        String itemUID = value.value;
        return ItemRecord.getWithUID(itemUID, db);
      case CVUValueType.expression:
        ExpressionNode expression = value.value;
        return resolve<ItemRecord>(expression: expression, context: context, db: db);
      default:
        return null;
    }
  }

  List? _resolveItemRecordArray(CVUValue value, CVUContext context,
      DatabaseController db) {
    switch (value.type) {
      case CVUValueType.item:
        String itemUID = value.value;
        ItemRecord? itemRecord = ItemRecord.getWithUID(itemUID, db);
        return (itemRecord != null) ? [itemRecord] : [];
      case CVUValueType.expression:
        ExpressionNode expression = value.value;
        return resolve<List>(expression: expression, context: context, db: db); //TODO List<ItemRecord>
      default:
        return [];
    }
  }

  Binding<dynamic>? _resolveBinding(CVUValue value, CVUContext context, DatabaseController db, dynamic? defaultValue) {
    switch (value.type) {
      case CVUValueType.expression:
        ExpressionNode expression = value.value;
        if (expression.type == ExpressionNodeType.lookup) {
          List<LookupNode> nodes = expression.value;
          List? res = _resolveToItemAndProperty(nodes, context, db);
          ItemRecord? item = res ? [0];
          String property = res ? [1];
          if (res != null && item != null && property != null) {
            return item.propertyBinding(name: property, defaultValue: defaultValue);
          }
        }
        return null;
      default:
        return null;
    }
  }

  /// Lookup an edge from an ItemRecord
  ItemRecord? _resolveEdgeItemRecord(String edge, ItemRecord item, DatabaseController db) {
    return item.edgeItem(edge, db);
  }

  /// Lookup an edge array from an ItemRecord
  List<ItemRecord> _resolveEdgeItemRecordArray(String edge, ItemRecord item,
      DatabaseController db) {
    return item.edgeItems(edge, db);
  }

  /// Lookup an edge array from an ItemRecord
  PropertyDatabaseValue? _resolvePropertyDatabaseValue(String property, ItemRecord item,
      DatabaseController db) {
    return item.property(property, db)?.value(item.type, db.schema);
  }

  LookupStep? _resolveLookupStep(List<LookupNode> nodes, CVUContext context,
      DatabaseController db) {
    LookupStep? currentValue;
    var values, strings, joined, exp;
    for (LookupNode node in nodes) {
      switch (node.type.type) {
        case LookupTypeType.defaultLookup:
          ItemRecord? currentItem = context.currentItem;
          if (currentItem == null) {
            return null;
          }
          currentValue = LookupStep.items([currentItem]);
          break;
        case LookupTypeType.function:
          List<ExpressionNode> args = node.type.value;
          switch (node.name.toLowerCase()) {
            case "item":
              exp = args[0];
              if (exp == null) {
                return null;
              }
              String? itemUIDString = resolve<String>(
                  expression: exp,
                  context: context,
                  db: db
              );
              if (itemUIDString == null || itemUIDString.isEmpty) {
                return null;
              }
              ItemRecord? item = ItemRecord.getWithUID(itemUIDString, db);
              if (item == null) {
                return null;
              }
              currentValue = LookupStep.items([item]);
              break;
            case "joined":
              if (currentValue == null || currentValue.type != LookupStepType.databaseValues) {
                return null;
              }
              List<PropertyDatabaseValue> values = currentValue.value;
              exp = args[0];
              String? separator;
              if (exp != null) {
                separator = resolve<String>(
                    expression: exp,
                    context: context,
                    db: db
                );
              }

              if (separator != null && separator.isNotEmpty) {
                String joined = values.map(($0) =>
                    $0.asString()).where((element) => element.isNotEmpty).join(separator);
                currentValue = LookupStep.values([new PropertyDatabaseValue.string(joined)]);
              } else {
                String joined = values.map(($0) =>
                    $0.asString()).where((element) => element.isNotEmpty).join(
                    ", "); //TODO @anijanyan String.localizedString(strings);
                currentValue = LookupStep.values([new PropertyDatabaseValue.string(joined)]);
              }
              break;
            case "joinwithcomma":
              String joined = args.map(($0) =>
                  resolve<String>(
                      expression: $0,
                      context: context,
                      db: db
                  ).toString()).where((element) => element.isNotEmpty).join(", ");
              currentValue = new LookupStep.values([new PropertyDatabaseValue.string(joined)]);
              break;
            case "joinnatural":
              List<String> strings = args.map(($0) =>
                  resolve<String>(
                      expression: $0,
                      context: context,
                      db: db
                  ).toString()
              ).where((element) => element.isNotEmpty).toList();
              joined = strings.join(", "); //TODO @anijanyan String.localizedString(strings);
              currentValue = new LookupStep.values([PropertyDatabaseValue.string(joined)]);
              break;
            case "plainstring":
              if (currentValue == null || currentValue.type != LookupStepType.databaseValues) {
                return null;
              }
              List<PropertyDatabaseValue> values = currentValue.value as List<
                  PropertyDatabaseValue>;
              List<PropertyDatabaseValue> stripped = values.map((PropertyDatabaseValue value) {
                String htmlstring = value.asString();
                if (htmlstring.isEmpty) {
                  return null;
                }
                return PropertyDatabaseValue.string(htmlstring);
                //TODO return PropertyDatabaseValue.string(DOMPurify.sanitize(htmlstring, {ALLOWED_TAGS: []}))
              }).whereType<PropertyDatabaseValue>().toList();

              currentValue = new LookupStep.values(stripped);
              break;
            case "first":
              if (currentValue == null || currentValue.value[0] == null) {
                return null;
              }
              if (currentValue.type == LookupStepType.databaseValues) {
                currentValue = LookupStep.values([currentValue.value[0]]);
              } else if (currentValue.type == LookupStepType.items) {
                currentValue = new LookupStep.items([currentValue.value[0]]);
              } else {
                return null;
              }
              break;
            case "last":
              if (currentValue == null || currentValue.value.last == null) {
                return null;
              }
              if (currentValue.type == LookupStepType.databaseValues) {
                currentValue = LookupStep.values([currentValue.value.last]);
              } else if (currentValue.type == LookupStepType.items) {
                currentValue = new LookupStep.items([currentValue.value.last]);
              } else {
                return null;
              }
              break;
            case "fullname":
              switch (currentValue?.type) {
                case (LookupStepType.items):
                  List<ItemRecord> items = currentValue!.value as List<ItemRecord>;
                  if (items.isEmpty) {
                    return null;
                  }
                  ItemRecord first = items[0];
                  if (first.type == "Person") {
                    String name = [
                      resolve<PropertyDatabaseValue>(
                          property: "firstName", item: first, db: db),
                      resolve<PropertyDatabaseValue>(
                          property: "lastName", item: first, db: db)
                    ].map(($0) => $0!.asString()).join(" ");
                    currentValue = LookupStep.values([PropertyDatabaseValue.string(name)]);
                  } else {
                    return null;
                  }
                  break;
                default:
                  return null;
              }
              break;
            case "initials":
              switch (currentValue?.type) {
                case (LookupStepType.databaseValues):
                  List<PropertyDatabaseValue> values = currentValue?.value as List<PropertyDatabaseValue>;
                  String initials = values.map(($0) => $0.asString()[0]).where((element) =>
                  element.isNotEmpty).join("").toUpperCase();
                  currentValue = LookupStep.values([PropertyDatabaseValue.string(initials)]);
                  break;
                case (LookupStepType.items):
                  List<ItemRecord> items = currentValue?.value as List<ItemRecord>;
                  if (items.isEmpty) {
                    return null;
                  }
                  ItemRecord first = items[0];
                  if (first.type == "Person") {
                    String initials = [
                      resolve<PropertyDatabaseValue>(property: "firstName", item: first, db: db),
                      resolve<PropertyDatabaseValue>(property: "lastName", item: first, db: db)
                    ].map(($0) => $0?.asString()[0]).
                    where((element) => element != null && element.isNotEmpty).join("").toUpperCase();
                    currentValue = LookupStep.values([PropertyDatabaseValue.string(initials)]);
                  } else {
                    return null;
                  };
                  break;
                case null:
                  return null;
                default:
                  break;
              }
              break;
            default:
              return null;
          }
          break;
        case LookupTypeType.lookup:
          ExpressionNode subexpression = node.type.value;
          switch (currentValue?.type) {
            case LookupStepType.items:
              List<ItemRecord> items = currentValue?.value as List<ItemRecord>;
              currentValue = itemLookup(
                  node: node,
                  items: items,
                  subexpression: subexpression,
                  context: context,
                  db: db
              );
              break;
            case null:
            // Check if there is a matching view argument
              CVUViewArguments? viewArgs = context.viewArguments;
              CVUValue? argValue = viewArgs?.args[node.name];
              if (viewArgs != null && argValue != null) {
                switch (argValue.type) {
                  case (CVUValueType.constant):
                    CVUValue_Constant constant = argValue.value;
                    switch (constant.type) {
                      case (CVUValue_ConstantType.argument):
                        currentValue =
                            LookupStep.values([PropertyDatabaseValue.string(constant.value)]);
                        break;
                      case (CVUValue_ConstantType.number):
                        currentValue =
                            LookupStep.values([PropertyDatabaseValue.double(constant.value)]);
                        break;
                      case (CVUValue_ConstantType.string):
                        currentValue =
                            LookupStep.values([PropertyDatabaseValue.string(constant.value)]);
                        break;
                      case (CVUValue_ConstantType.bool):
                        currentValue =
                            LookupStep.values([PropertyDatabaseValue.bool(constant.value)]);
                        break;
                      case (CVUValue_ConstantType.colorHex):
                        currentValue =
                            LookupStep.values([PropertyDatabaseValue.string(constant.value)]);
                        break;
                      case (CVUValue_ConstantType.nil):
                        currentValue = null;
                        break;
                      default:
                        break;
                    }
                    break;
                  case (CVUValueType.expression):
                    ExpressionNode expression = argValue.value;
                    CVUContext context = CVUContext(
                        currentItem: viewArgs.argumentItem,
                        viewArguments: viewArgs.parentArguments
                    );
                    ItemRecord? item = resolve<ItemRecord>(
                        expression: expression,
                        context: context,
                        db: db
                    );
                    double? number = resolve<double>(
                        expression: expression,
                        context: context,
                        db: db
                    );
                    String? string = resolve<String>(
                        expression: expression,
                        context: context,
                        db: db
                    );

                    if (item != null) {
                      currentValue = LookupStep.items([item]);
                    } else if (number != null) {
                      currentValue =
                      new LookupStep.values([new PropertyDatabaseValue.double(number)]);
                    } else if (string != null) {
                      currentValue =
                      new LookupStep.values([new PropertyDatabaseValue.string(string)]);
                    } else {
                      List<ItemRecord> items = resolve<List<ItemRecord>>(
                          expression: expression,
                          context: context,
                          db: db
                      )!;
                      if (items.isNotEmpty) {
                        currentValue = LookupStep.items(items);
                      } else {
                        return null;
                      }
                    }
                    break;
                  default:
                    return null;
                }
              }
              break;
            default:
              return null;
          }
          break;
        default:
          break;
      }
    }
    return currentValue;
  }

  List<ItemRecord> filter(List<ItemRecord> items, ExpressionNode? subexpression,
      DatabaseController? db) {
    ExpressionNode? exp = subexpression;
    if (exp == null) {
      return items;
    }
    return items.where((item) {
      CVUContext context = new CVUContext(currentItem: item);
      return resolve<bool>(expression: exp, context: context, db: db) ?? false;
    }).toList();
  }

  LookupStep? itemLookup({required LookupNode node, required List<ItemRecord> items, ExpressionNode? subexpression,
    required CVUContext context, required DatabaseController db}) {
    if (items.isEmpty) {
      return null;
    }
    String trimmedName = node.name.replaceAll(
        RegExp("^~)|(~\$)"), ""); //TODO @anijanyan check if this works
    switch (node.name[0]) {
      case "~":

      /// LOOKUP REVERSE EDGE FOR EACH ITEM
        if (node.isArray) {
          List<ItemRecord> result = items.map((item) =>
              item.reverseEdgeItems(trimmedName, db)
          ).expand((i) => i).toList();
          return LookupStep.items(filter(result, subexpression, db));
        } else {
          List<ItemRecord> result = items.map((item) =>
              item.reverseEdgeItem(trimmedName, db)
          ).whereType<ItemRecord>().toList();
          return LookupStep.items(filter(result, subexpression, db));
        }
      default:

      /// CHECK IF WE'RE EXPECTING EDGES OR PROPERTIES
        String itemType = items[0].type;

        /// Check if this is an intrinsic property
        switch (node.name) {
          case "uid":
            return LookupStep.values(
                items.map(($0) => PropertyDatabaseValue.string($0.uid)).toList());
          case "dateModified":
            return LookupStep.values(
                items.map(($0) => PropertyDatabaseValue.datetime($0.dateModified)).toList());
          case "dateCreated":
            return new LookupStep.values(
                items.map(($0) => PropertyDatabaseValue.datetime($0.dateCreated)).toList());
          default:
            break;
        }

        /// Find out if it is a property or an edge (according to schema)
        switch (db.schema
            ?.expectedType(itemType: itemType, propertyOrEdgeName: node.name)
            ?.type) {
          case (ResolvedTypeType.property):

          /// LOOKUP PROPERTY FOR EACH ITEM
            List<PropertyDatabaseValue> result = items.map((item) {
              ItemPropertyRecord? property = item.property(node.name, db);
              PropertyDatabaseValue? value = property?.value(item.type, db.schema);
              if (property == null || value == null) {
                return null;
              }
              return value;
            }).whereType<PropertyDatabaseValue>().toList();
            return new LookupStep.values(result);
          case (ResolvedTypeType.edge):

          /// LOOKUP EDGE FOR EACH ITEM
            if (node.isArray) {
              List<ItemRecord> result = items.map((item) =>
                  item.edgeItems(trimmedName, db)
              ).expand((element) => element).toList();
              return LookupStep.items(filter(result, subexpression, db));
            } else {
              List<ItemRecord> result = items.map((item) =>
                  item.edgeItem(trimmedName, db)
              ).whereType<ItemRecord>().toList();
              return new LookupStep.items(filter(result, subexpression, db));
            }
          default:
            return null;
        }
    }
  }

  /// Lookup a variable using its CVU string and return the value as a double
  double? _resolveNodesDouble(List<LookupNode> nodes, CVUContext context, DatabaseController db) {
    if (lookupMockMode != null) {
      return lookupMockMode!.number;
    }
    LookupStep? lookupResult = resolve<LookupStep>(nodes: nodes, context: context, db: db);
    if (lookupResult == null) {
      return null;
    }
    switch (lookupResult.type) {
      case LookupStepType.databaseValues:
        List<PropertyDatabaseValue?>? values = lookupResult.value;
        return values ? [0]?.asDouble();
      default:
        return null;
    }
  }

  /// Lookup a variable using its CVU string and return the value as a string
  String? _resolveNodesString(List<LookupNode> nodes, CVUContext context, DatabaseController db) {
    if (lookupMockMode != null) {
      return lookupMockMode!.string;
    }
    LookupStep? lookupResult = resolve<LookupStep>(nodes: nodes, context: context, db: db);
    if (lookupResult == null) {
      return null;
    }
    switch (lookupResult.type) {
      case LookupStepType.databaseValues:
        List<PropertyDatabaseValue?>? values = lookupResult.value;
        return values ? [0]?.asString();
      default:
        return null;
    }
  }

  /// Lookup a variable using its CVU string and return the value as a bool
  bool? _resolveNodesBool(List<LookupNode> nodes, CVUContext context, DatabaseController db) {
    if (lookupMockMode != null) {
      return lookupMockMode!.boolean;
    }
    LookupStep? lookupResult = resolve<LookupStep>(nodes: nodes, context: context, db: db);
    if (lookupResult == null) {
      return null;
    }
    switch (lookupResult.type) {
      case LookupStepType.databaseValues:
        List<PropertyDatabaseValue?>? values = lookupResult.value;
        return values ? [0]?.asBool();
      case LookupStepType.items:
        List<ItemRecord> items = lookupResult.value;
        return items.isNotEmpty;
      default:
        return null;
    }
  }

  /// Lookup using a CVU expression string and return the value as an item
  ItemRecord? _resolveNodesItemRecord(List<LookupNode> nodes, CVUContext context,
      DatabaseController db) {
    LookupStep? lookupResult = resolve<LookupStep>(nodes: nodes, context: context, db: db);
    if (lookupResult == null) {
      return null;
    }
    switch (lookupResult.type) {
      case LookupStepType.items:
        List<ItemRecord> items = lookupResult.value;
        return items.first;
      default:
        return null;
    }
  }

  /// Lookup using a CVU expression string and return the value as an array of items
  List<ItemRecord> _resolveNodesItemRecordArray(List<LookupNode> nodes, CVUContext context,
      DatabaseController db) {
    LookupStep? lookupResult = resolve<LookupStep>(nodes: nodes, context: context, db: db);
    if (lookupResult == null) {
      return [];
    }
    switch (lookupResult.type) {
      case LookupStepType.items:
        List<ItemRecord> items = lookupResult.value;
        return items;
      default:
        return [];
    }
  }

  ItemRecord? _resolveExpressionItemRecord(ExpressionNode expression, CVUContext context,
      DatabaseController db) {
    switch (expression.type) {
      case ExpressionNodeType.lookup:
        List<LookupNode> nodes = expression.value;
        return resolve<ItemRecord>(nodes: nodes, context: context, db: db);
      case ExpressionNodeType.conditional:
        ExpressionNode condition = expression.value;
        ExpressionNode trueExp = expression.secondArg;
        ExpressionNode falseExp = expression.thirdArg;
        bool conditionResolved = resolve<bool>(expression: condition, context: context, db: db) ?? false;
        if (conditionResolved) {
          return resolve<ItemRecord>(expression: trueExp, context: context, db: db);
        } else {
          return resolve<ItemRecord>(expression: falseExp, context: context, db: db);
        }
      case ExpressionNodeType.or:
        ExpressionNode a = expression.value;
        ExpressionNode b = expression.secondArg;
        return resolve<ItemRecord>(expression: a, context: context, db: db)
            ?? resolve<ItemRecord>(expression: b, context: context, db: db);
      default:
        return null;
    }
  }

  List<ItemRecord> _resolveExpressionItemRecordArray(ExpressionNode expression, CVUContext context,
      DatabaseController db) {
    switch (expression.type) {
      case ExpressionNodeType.lookup:
        List<LookupNode> nodes = expression.value;
        return resolve<List<ItemRecord>>(nodes: nodes, context: context, db: db)!;
      case ExpressionNodeType.conditional:
        ExpressionNode condition = expression.value;
        ExpressionNode trueExp = expression.secondArg;
        ExpressionNode falseExp = expression.thirdArg;
        bool conditionResolved = resolve<bool>(expression: condition, context: context, db: db) ?? false;
        if (conditionResolved) {
          return resolve<List<ItemRecord>>(expression: trueExp, context: context, db: db)!;
        } else {
          return resolve<List<ItemRecord>>(expression: falseExp, context: context, db: db)!;
        }
      case ExpressionNodeType.and:
        ExpressionNode a = expression.value;
        ExpressionNode b = expression.secondArg;
        return resolve<List<ItemRecord>>(expression: a, context: context, db: db)!
            + resolve<List<ItemRecord>>(expression: b, context: context, db: db)!;
      default:
        return [];
    }
  }

  double? _resolveExpressionDouble(ExpressionNode expression, CVUContext context,
      DatabaseController db) {
    switch (expression.type) {
      case ExpressionNodeType.lookup:
        List<LookupNode> nodes = expression.value;
        return resolve<double>(nodes: nodes, context: context, db: db);
      case ExpressionNodeType.conditional:
        ExpressionNode condition = expression.value;
        ExpressionNode trueExp = expression.secondArg;
        ExpressionNode falseExp = expression.thirdArg;
        bool conditionResolved = resolve<bool>(expression: condition, context: context, db: db) ?? false;
        if (conditionResolved) {
          return resolve<double>(expression: trueExp, context: context, db: db);
        } else {
          return resolve<double>(expression: falseExp, context: context, db: db);
        }
      case ExpressionNodeType.or:
        ExpressionNode a = expression.value;
        ExpressionNode b = expression.secondArg;
        return resolve<double>(expression: a, context: context, db: db)
            ?? resolve<double>(expression: b, context: context, db: db);
      case ExpressionNodeType.negation:
        print("CVU Expression error: Should not use ! operator on non-boolean value");
        return null;
      case ExpressionNodeType.addition:
        ExpressionNode a = expression.value;
        ExpressionNode b = expression.secondArg;
        return (resolve<double>(expression: a, context: context, db: db) ?? 0)
            + (resolve<double>(expression: b, context: context, db: db) ?? 0);
      case ExpressionNodeType.subtraction:
        ExpressionNode a = expression.value;
        ExpressionNode b = expression.secondArg;
        return (resolve<double>(expression: a, context: context, db: db) ?? 0)
            - (resolve<double>(expression: b, context: context, db: db) ?? 0);
      case ExpressionNodeType.constant:
        return expression.value.asNumber();
      case ExpressionNodeType.multiplication:
        ExpressionNode a = expression.value;
        ExpressionNode b = expression.secondArg;
        return (resolve<double>(expression: a, context: context, db: db) ?? 0)
            * (resolve<double>(expression: b, context: context, db: db) ?? 0);
      case ExpressionNodeType.division:
        ExpressionNode a = expression.value;
        ExpressionNode b = expression.secondArg;
        double? lhs = resolve<double>(expression: a, context: context, db: db);
        double? rhs = resolve<double>(expression: b, context: context, db: db);
        if (lhs != null && rhs != null && rhs != 0) {
          return lhs / rhs;
        } else {
          return null;
        }
      default:
        return null;
    }
  }

  String? _resolveExpressionString(ExpressionNode expression, CVUContext context,
      DatabaseController db) {
    switch (expression.type) {
      case ExpressionNodeType.lookup:
        List<LookupNode> nodes = expression.value;
        return resolve<String>(nodes: nodes, context: context, db: db);
      case ExpressionNodeType.conditional:
        ExpressionNode condition = expression.value;
        ExpressionNode trueExp = expression.secondArg;
        ExpressionNode falseExp = expression.thirdArg;
        bool conditionResolved = resolve<bool>(expression: condition, context: context, db: db) ?? false;
        if (conditionResolved) {
          return resolve<String>(expression: trueExp, context: context, db: db);
        } else {
          return resolve<String>(expression: falseExp, context: context, db: db);
        }
      case ExpressionNodeType.or:
        ExpressionNode a = expression.value;
        ExpressionNode b = expression.secondArg;
        return resolve<String>(expression: a, context: context, db: db) //TODO nilIfBlank?
            ?? resolve<String>(expression: b, context: context, db: db);
      case ExpressionNodeType.negation:
        print("CVU Expression error: Should not use ! operator on non-boolean value");
        return null;
      case ExpressionNodeType.addition:
        ExpressionNode a = expression.value;
        ExpressionNode b = expression.secondArg;
        return (resolve<String>(expression: a, context: context, db: db) ?? "")
            + (resolve<String>(expression: b, context: context, db: db) ?? "");
      case ExpressionNodeType.subtraction:
        print("CVU Expression error: Should not use - operator on string value");
        return null;
      case ExpressionNodeType.constant:
        return expression.value.asString();
      case ExpressionNodeType.stringMode:
        List<ExpressionNode> nodes = expression.value;
        return nodes.map(($0) => resolve<String>(expression: $0, context: context, db: db))
            .whereType<String>()
            .join("");
      default:
        return null;
    }
  }

  bool? _resolveExpressionBool(ExpressionNode expression, CVUContext context,
      DatabaseController db) {
    switch (expression.type) {
      case ExpressionNodeType.lookup:
        List<LookupNode> nodes = expression.value;
        return resolve<bool>(nodes: nodes, context: context, db: db);
      case ExpressionNodeType.conditional:
        ExpressionNode condition = expression.value;
        ExpressionNode trueExp = expression.secondArg;
        ExpressionNode falseExp = expression.thirdArg;
        bool conditionResolved = resolve<bool>(expression: condition, context: context, db: db) ?? false;
        if (conditionResolved) {
          return resolve<bool>(expression: trueExp, context: context, db: db);
        } else {
          return resolve<bool>(expression: falseExp, context: context, db: db);
        }
      case ExpressionNodeType.and:
        ExpressionNode a = expression.value;
        ExpressionNode b = expression.secondArg;
        return (resolve<bool>(expression: a, context: context, db: db) ?? false)
            && (resolve<bool>(expression: b, context: context, db: db) ?? false);
      case ExpressionNodeType.or:
        ExpressionNode a = expression.value;
        ExpressionNode b = expression.secondArg;
        return (resolve<bool>(expression: a, context: context, db: db) ?? false)
            || (resolve<bool>(expression: b, context: context, db: db) ?? false);
      case ExpressionNodeType.negation:
        bool? res = resolve<bool>(expression: expression.value, context: context, db: db);
        return res == null ? res : !res;
      case ExpressionNodeType.addition:
        print("CVU Expression error: Should not use + operator on bool value");
        return null;
      case ExpressionNodeType.subtraction:
        print("CVU Expression error: Should not use - operator on bool value");
        return null;
      case ExpressionNodeType.constant:
        return expression.value.asBool();
      case ExpressionNodeType.lessThan:
        ExpressionNode a = expression.value;
        ExpressionNode b = expression.secondArg;
        double? lhs = resolve<double>(expression: a, context: context, db: db);
        double? rhs = resolve<double>(expression: b, context: context, db: db);
        if (lhs == null || rhs == null) {
          return null;
        }
        return lhs < rhs;
      case ExpressionNodeType.greaterThan:
        ExpressionNode a = expression.value;
        ExpressionNode b = expression.secondArg;
        double? lhs = resolve<double>(expression: a, context: context, db: db);
        double? rhs = resolve<double>(expression: b, context: context, db: db);
        if (lhs == null || rhs == null) {
          return null;
        }
        return lhs > rhs;
      case ExpressionNodeType.lessThanOrEqual:
        ExpressionNode a = expression.value;
        ExpressionNode b = expression.secondArg;
        double? lhs = resolve<double>(expression: a, context: context, db: db);
        double? rhs = resolve<double>(expression: b, context: context, db: db);
        if (lhs == null || rhs == null) {
          return null;
        }
        return lhs <= rhs;
      case ExpressionNodeType.greaterThanOrEqual:
        ExpressionNode a = expression.value;
        ExpressionNode b = expression.secondArg;
        double? lhs = resolve<double>(expression: a, context: context, db: db);
        double? rhs = resolve<double>(expression: b, context: context, db: db);
        if (lhs == null || rhs == null) {
          return null;
        }
        return lhs >= rhs;
      case ExpressionNodeType.areEqual:
        ExpressionNode a = expression.value;
        ExpressionNode b = expression.secondArg;
        String? lhs = resolve<String>(expression: a, context: context, db: db );
        //TODO do we need to check by types as in swift? @anijanyan
        String? rhs = resolve<String>(expression: b, context: context, db: db);
        if (lhs == null || rhs == null) {
          return false;
        }
        return lhs == rhs;
      case ExpressionNodeType.areNotEqual:
        ExpressionNode a = expression.value;
        ExpressionNode b = expression.secondArg;
        String? lhs = resolve<String>(expression: a, context: context, db: db );
        //TODO do we need to check by types as in swift? @anijanyan
        String? rhs = resolve<String>(expression: b, context: context, db: db);
        if (lhs == null || rhs == null) {
          return true;
        }
        return lhs != rhs;
      default:
        return null;
    }
  }

  /*(ItemRecord item, String property) */
  List? _resolveToItemAndProperty(List<LookupNode> nodes, CVUContext context, DatabaseController db) {
    ItemRecord? currentItem;

    // Find the item referenced by the lookup
    LookupNode? last = nodes.removeLast();
    for (LookupNode node in nodes) {
      switch (node.type.type) {
        case LookupTypeType.defaultLookup:
          ItemRecord? defaultItem = context.currentItem;
          if (defaultItem == null) {
            return null;
          }
          currentItem = defaultItem;
          break;
        case (LookupTypeType.lookup):
          ExpressionNode? subexpression = node.type.value;
          ItemRecord? nextItem = currentItem;
          if (nextItem != null) {
            LookupStep? step = itemLookup(
                node: node,
                items: [nextItem],
                subexpression: subexpression,
                context: context,
                db: db
            );
            if (step != null && step.type == LookupStepType.items) {
              List<ItemRecord> items = step.value;
              currentItem = items[0];
            }
          }
          break;
        case LookupTypeType.function:
          return null;
      }
    }
    ItemRecord? targetItem = currentItem;
    LookupNode? propertyLookup = last;
    if (targetItem == null || propertyLookup == null) {
      return null;
    }

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

enum LookupStepType {
  items,
  databaseValues
}

class LookupStep {
  final LookupStepType type;
  final dynamic value;

  LookupStep.items(List<ItemRecord> this.value) : type = LookupStepType.items;

  LookupStep.values(List<PropertyDatabaseValue> this.value) : type = LookupStepType.databaseValues;
}