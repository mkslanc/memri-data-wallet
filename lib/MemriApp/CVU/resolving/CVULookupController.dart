import 'package:html/parser.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Expression.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_LookupNode.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/Controllers/Database/Schema.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/DateTime.dart';
import 'package:moor/moor.dart';
import 'CVUContext.dart';
import 'CVUViewArguments.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';

/// This struct can be used to _resolve CVU values to a final value of the desired type.
/// For lookups you must provide a CVUContext which contains required information on the default item, viewArguments, etc to be used in the lookup.
class CVULookupController {
  LookupMock? lookupMockMode;

  CVULookupController([this.lookupMockMode]);

  Future<T?> resolve<T>(
      {CVUValue? value,
      List<CVULookupNode>? nodes,
      String? edge,
      ItemRecord? item,
      String? property,
      CVUExpressionNode? expression,
      CVUContext? context,
      dynamic defaultValue,
      DatabaseController? db,
      Type? additionalType}) async {
    switch (T) {
      case double:
        if (nodes != null) {
          return await _resolveNodesDouble(nodes, context!, db!) as T?;
        } else if (expression != null) {
          return await _resolveExpressionDouble(expression, context!, db!) as T?;
        }
        return await _resolveDouble(value!, context!, db!) as T?;
      case int:
        if (nodes != null) {
          return await _resolveNodesInt(nodes, context!, db!) as T?;
        } else if (expression != null) {
          return await _resolveExpressionInt(expression, context!, db!) as T?;
        }
        return await _resolveInt(value!, context!, db!) as T?;
      case String:
        if (nodes != null) {
          return await _resolveNodesString(nodes, context!, db!) as T?;
        } else if (expression != null) {
          return await _resolveExpressionString(expression, context!, db!) as T?;
        }
        return await _resolveString(value!, context!, db!) as T?;
      case bool:
        if (nodes != null) {
          return await _resolveNodesBool(nodes, context!, db!) as T?;
        } else if (expression != null) {
          return await _resolveExpressionBool(expression, context!, db!) as T?;
        }
        return await _resolveBool(value!, context!, db!) as T?;
      case DateTime:
        return await _resolveDate(value!, context!, db!) as T?;
      case ItemRecord:
        if (edge != null) {
          return await _resolveEdgeItemRecord(edge, item!, db!) as T?;
        } else if (nodes != null) {
          return await _resolveNodesItemRecord(nodes, context!, db!) as T?;
        } else if (expression != null) {
          return await _resolveExpressionItemRecord(expression, context!, db!) as T?;
        }
        return await _resolveItemRecord(value!, context!, db!) as T?;
      case List:
        if (edge != null) {
          return await _resolveEdgeItemRecordArray(edge, item!, db!) as T?;
        } else if (nodes != null) {
          return await _resolveNodesItemRecordArray(nodes, context!, db!) as T?;
        } else if (expression != null) {
          return await _resolveExpressionItemRecordArray(expression, context!, db!) as T?;
        }
        if (additionalType == CVUValue) {
          return await _resolveCVUValueArray(value!, context!, db!) as T?;
        } else if (additionalType == CVUConstant) {
          return await _resolveCVUConstantArray(value!, context!, db!) as T?;
        } else if (additionalType == Map) {
          return await _resolveArrayOfCVUConstantMap(value!, context!, db!) as T?;
        }
        return await _resolveItemRecordArray(value!, context!, db!) as T?;
      case FutureBinding:
        return await _resolveBinding(value!, context!, db!, defaultValue, additionalType!) as T?;
      case LookupStep:
        return await _resolveLookupStep(nodes!, context!, db!) as T?;
      case PropertyDatabaseValue:
        return await _resolvePropertyDatabaseValue(property!, item!, db!) as T?;
      default:
        throw Exception("Type is required");
    }
  }

  Future<int?> _resolveInt(CVUValue value, CVUContext context, DatabaseController db) async {
    if (value is CVUValueConstant) {
      return value.value.asInt();
    } else if (value is CVUValueExpression) {
      return await resolve<int>(expression: value.value, context: context, db: db);
    } else {
      return null;
    }
  }

  Future<double?> _resolveDouble(CVUValue value, CVUContext context, DatabaseController db) async {
    if (value is CVUValueConstant) {
      return value.value.asNumber();
    } else if (value is CVUValueExpression) {
      return await resolve<double>(expression: value.value, context: context, db: db);
    } else {
      return null;
    }
  }

  Future<String?> _resolveString(CVUValue value, CVUContext context, DatabaseController db) async {
    if (value is CVUValueConstant) {
      return value.value.asString();
    } else if (value is CVUValueExpression) {
      return await resolve<String>(expression: value.value, context: context, db: db);
    } else {
      return null;
    }
  }

  Future<bool?> _resolveBool(CVUValue value, CVUContext context, DatabaseController db) async {
    if (value is CVUValueConstant) {
      return value.value.asBool();
    } else if (value is CVUValueExpression) {
      return await resolve<bool>(expression: value.value, context: context, db: db);
    } else {
      return null;
    }
  }

  Future<DateTime?> _resolveDate(CVUValue value, CVUContext context, DatabaseController db) async {
    if (value is CVUValueConstant) {
      return DateTime.fromMillisecondsSinceEpoch(int.parse(value.value.asNumber().toString()));
    } else if (value is CVUValueExpression) {
      return await resolve<DateTime>(expression: value.value, context: context, db: db);
    } else {
      return null;
    }
  }

  Future<ItemRecord?> _resolveItemRecord(
      CVUValue value, CVUContext context, DatabaseController db) async {
    if (value is CVUValueConstant) {
      return null;
    } else if (value is CVUValueItem) {
      return ItemRecord.fetchWithRowID(value.value, db);
    } else if (value is CVUValueExpression) {
      return await resolve<ItemRecord>(expression: value.value, context: context, db: db);
    } else {
      return null;
    }
  }

  Future<List<ItemRecord>> _resolveItemRecordArray(
      CVUValue value, CVUContext context, DatabaseController db) async {
    if (value is CVUValueItem) {
      int itemRowID = value.value;
      ItemRecord? itemRecord = await ItemRecord.fetchWithRowID(itemRowID, db);
      return (itemRecord != null) ? [itemRecord] : [];
    } else if (value is CVUValueExpression) {
      CVUExpressionNode expression = value.value;
      return (await resolve<List>(
          expression: expression,
          context: context,
          db: db,
          additionalType: ItemRecord)) as List<ItemRecord>;
    } else {
      return [];
    }
  }

  Future<List<CVUValue>> _resolveCVUValueArray(
      CVUValue value, CVUContext context, DatabaseController db) async {
    if (value is CVUValueArray) {
      var values = value.value;
      return values;
    } else {
      return [];
    }
  }

  Future<List<Map<String, List<CVUConstant>>>> _resolveArrayOfCVUConstantMap(
      CVUValue value, CVUContext context, DatabaseController db) async {
    if (value is CVUValueArray) {
      var values = value.value;
      return (await Future.wait(values.map((el) async => Map.fromEntries((await Future.wait(
                  (el.getSubdefinition()?.properties.entries.toList() ?? []).map((entry) async =>
                      MapEntry(entry.key, await resolve<List<CVUConstant>>(value: entry.value)))))
              .where((element) => element.value != null)))))
          .whereType<Map<String, List<CVUConstant>>>()
          .where((element) => element.isNotEmpty)
          .toList();
    } else {
      return [];
    }
  }

  Future<List<CVUConstant>?> _resolveCVUConstantArray(
      CVUValue value, CVUContext context, DatabaseController db) async {
    if (value is CVUValueConstant) {
      var constant = value.value;
      return [constant];
    } else if (value is CVUValueArray) {
      var values = value.value;
      return (await Future.wait(values.map((element) async =>
              (await resolve<List>(value: element, additionalType: CVUConstant) ?? [])
                  as List<CVUConstant>)))
          .expand((element) => element)
          .toList();
    } else {
      return null;
    }
  }

  Future<FutureBinding?> _resolveBinding(CVUValue value, CVUContext context, DatabaseController db,
      dynamic defaultValue, Type type) async {
    if (value is CVUValueExpression) {
      var expression = value.value;
      if (expression is CVUExpressionNodeLookup) {
        List<CVULookupNode> nodes = []..addAll(expression.nodes);
        List? res = await _resolveToItemAndProperty(nodes, context, db);
        ItemRecord? item = res?[0];
        String? property = res?[1];
        if (res != null && item != null && property != null) {
          return await item.propertyBinding(name: property, defaultValue: defaultValue, type: type);
        }
      }
      return null;
    } else {
      return null;
    }
  }

  /// Lookup an edge from an ItemRecord
  Future<ItemRecord?> _resolveEdgeItemRecord(
      String edge, ItemRecord item, DatabaseController db) async {
    return await item.edgeItem(edge, db: db);
  }

  /// Lookup an edge array from an ItemRecord
  Future<List<ItemRecord>> _resolveEdgeItemRecordArray(
      String edge, ItemRecord item, DatabaseController db) async {
    return await item.edgeItems(edge, db: db);
  }

  /// Lookup a property from an ItemRecord
  Future<PropertyDatabaseValue?> _resolvePropertyDatabaseValue(
      String property, ItemRecord item, DatabaseController db) async {
    return await item.propertyValue(property, db);
  }

  Future<LookupStep?> _resolveLookupStep(
      List<CVULookupNode> nodes, CVUContext context, DatabaseController db) async {
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
            var exp = nodeType.args.asMap()[0];
            if (exp == null) {
              return null;
            }
            int? itemRowId = await resolve<int>(expression: exp, context: context, db: db);
            if (itemRowId == null) {
              return null;
            }
            ItemRecord? item = await ItemRecord.fetchWithRowID(itemRowId, db);
            if (item == null) {
              return null;
            }
            currentValue = LookupStepItems([item]);
            break;
          case "joined":
            if (currentValue == null || currentValue is! LookupStepValues) {
              return null;
            }
            var exp = args.asMap()[0];
            if (exp == null) {
              return null;
            }
            String? separator;
            separator = await resolve<String>(expression: exp, context: context, db: db);

            if (separator != null && separator.isNotEmpty) {
              String joined = currentValue.values
                  .map((element) => element.asString())
                  .where((element) => element != null && element.isNotEmpty)
                  .join(separator);
              currentValue = LookupStepValues([PropertyDatabaseValueString(joined)]);
            } else {
              String joined = currentValue.values
                  .map((element) => element.asString())
                  .where((element) => element != null && element.isNotEmpty)
                  .join(", "); //TODO @anijanyan String.localizedString(strings);
              currentValue = LookupStepValues([PropertyDatabaseValueString(joined)]);
            }
            break;
          case "joinwithcomma":
            String joined = (await Future.wait(args.map((element) async =>
                    (await resolve<String>(expression: element, context: context, db: db)))))
                .where((element) => element != null && element.isNotEmpty)
                .join(", ");
            currentValue = LookupStepValues([PropertyDatabaseValueString(joined)]);
            break;
          case "joinnatural":
            List<String> strings = (await Future.wait(args.map((element) async =>
                    (await resolve<String>(expression: element, context: context, db: db))
                        .toString())))
                .where((element) => element.isNotEmpty)
                .toList();
            var joined = strings.join(", "); //TODO @anijanyan String.localizedString(strings);
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
                  var strippedText = parse(parse(htmlstring).body!.text).documentElement!.text;
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

            if (currentValue is LookupStepValues && currentValue.values.isNotEmpty) {
              currentValue = LookupStepValues([currentValue.values.first]);
            } else if (currentValue is LookupStepItems && currentValue.items.isNotEmpty) {
              currentValue = LookupStepItems([currentValue.items.first]);
            } else {
              return null;
            }
            break;
          case "last":
            if (currentValue == null) {
              return null;
            }

            if (currentValue is LookupStepValues && currentValue.values.isNotEmpty) {
              currentValue = LookupStepValues([currentValue.values.last]);
            } else if (currentValue is LookupStepItems && currentValue.items.isNotEmpty) {
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
              currentValue =
                  LookupStepValues([PropertyDatabaseValueInt(currentValue.values.length)]);
            } else if (currentValue is LookupStepItems) {
              currentValue =
                  LookupStepValues([PropertyDatabaseValueInt(currentValue.items.length)]);
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
                  await resolve<PropertyDatabaseValue>(property: "firstName", item: first, db: db),
                  await resolve<PropertyDatabaseValue>(property: "lastName", item: first, db: db)
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
                  .map((element) => element.asString()?[0])
                  .where((element) => element != null && element.isNotEmpty)
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
                  await resolve<PropertyDatabaseValue>(property: "firstName", item: first, db: db),
                  await resolve<PropertyDatabaseValue>(property: "lastName", item: first, db: db)
                ]
                    .map((element) => element?.asString()?[0])
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
          case "describechangelog":
            if (currentValue is LookupStepItems) {
              if (currentValue.items.isEmpty) {
                return null;
              }
              ItemRecord first = currentValue.items[0];
              if (first.type == "Person") {
                var dateCreated = first.dateCreated.formatted();
                var timeSinceCreated = first.dateCreated.timeDelta;
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
          default:
            return null;
        }
      } else if (nodeType is CVULookupTypeLookup) {
        if (currentValue is LookupStepItems) {
          currentValue = await itemLookup(
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
                currentValue = LookupStepValues([PropertyDatabaseValueString(constant.value)]);
              } else if (constant is CVUConstantNumber) {
                currentValue = LookupStepValues([PropertyDatabaseValueDouble(constant.value)]);
              } else if (constant is CVUConstantInt) {
                currentValue = LookupStepValues([PropertyDatabaseValueInt(constant.value)]);
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
              var context = CVUContext(
                  currentItem: viewArgs.argumentItem, viewArguments: viewArgs.parentArguments);
              ItemRecord? item =
                  await resolve<ItemRecord>(expression: expression, context: context, db: db);
              double? number =
                  await resolve<double>(expression: expression, context: context, db: db);
              String? string =
                  await resolve<String>(expression: expression, context: context, db: db);

              if (item != null) {
                currentValue = LookupStepItems([item]);
              } else if (number != null) {
                currentValue = LookupStepValues([PropertyDatabaseValueDouble(number)]);
              } else if (string != null) {
                currentValue = LookupStepValues([PropertyDatabaseValueString(string)]);
              } else {
                var items = await resolve<List>(
                    expression: expression,
                    context: context,
                    db: db,
                    additionalType: ItemRecord) as List<ItemRecord>;
                if (items.isNotEmpty) {
                  currentValue = LookupStepItems(items);
                } else {
                  return null;
                }
              }
            } else {
              return null;
            }
          } else if (node.name == "me") {
            var me = await ItemRecord.me();
            if (me != null) {
              currentValue = LookupStepItems([me]);
            }
          } else if (node.name == "uid") {
            var item = context.currentItem;
            if (item != null && item.rowId != null) {
              currentValue = LookupStepValues([PropertyDatabaseValueInt(item.rowId!)]);
            }
          } else if (node.name == "items") {
            List<ItemRecord>? items = context.items;
            if (items == null) {
              return null;
            }
            currentValue = LookupStepItems(items);
          } else if (node.name == "currentIndex") {
            currentValue = LookupStepValues([PropertyDatabaseValueInt(context.currentIndex + 1)]);
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

  Future<List<ItemRecord>> filter(
      List<ItemRecord> items, CVUExpressionNode? exp, DatabaseController? db) async {
    if (exp == null) {
      return items;
    }

    List<ItemRecord> resultItems = <ItemRecord>[];
    Future.forEach<ItemRecord>(items, (item) async {
      CVUContext context = CVUContext(currentItem: item);
      if (await resolve<bool>(expression: exp, context: context, db: db) ?? false) {
        resultItems.add(item);
      }
    }); //TODO check if there is a better way to filter async

    return resultItems;
  }

  Future<T?> _resolveNamedExpression<T>(List<CVUExpressionNode> expressions, String name,
      DatabaseController db, CVUContext context) async {
    var expression = _getNamedExpression(expressions, name);
    if (expression == null) {
      return null;
    }

    return await resolve<T>(expression: expression, context: context, db: db);
  }

  CVUExpressionNode? _getNamedExpression(List<CVUExpressionNode> expressions, String name) {
    return expressions.firstWhereOrNull(
        (expression) => expression is CVUExpressionNodeNamed && expression.key == name);
  }

  Future<List<Map<String, dynamic>>> getSort(List<CVUExpressionNode> expressions, String edgeType,
      DatabaseController db, CVUContext context) async {
    var sortData = await _resolveNamedExpression<String>(expressions, "sort", db, context);
    var sort = <Map<String, dynamic>>[];

    if (sortData != null && sortData.isNotEmpty) {
      var sortProperties = sortData.split(",");
      sortProperties.forEach((sortProperty) {
        var sortData = sortProperty.trim().split(" ");
        SchemaValueType schemaValueType = db.schema.expectedPropertyType(edgeType, sortData[0])!;
        ItemRecordPropertyTable itemRecordPropertyTable =
            PropertyDatabaseValue.toDBTableName(schemaValueType);
        TableInfo table = db.databasePool.getItemPropertyRecordTable(itemRecordPropertyTable);
        sort.add({
          "table": table,
          "property": sortData[0],
          "order": sortData.length > 1 ? sortData.last : null
        });
      });
    }

    return sort;
  }

  Future<LookupStep?> itemLookup(
      {required CVULookupNode node,
      required List<ItemRecord> items,
      List<CVUExpressionNode>? subexpressions,
      required CVUContext context,
      required DatabaseController db}) async {
    if (items.isEmpty) {
      return null;
    }
    var nodePath = node.toCVUString();
    var cached = context.getCache(nodePath);
    if (cached != null) {
      return cached;
    }

    String trimmedName = node.name.replaceAll(RegExp(r"(^~)|(~$)"), "");
    CVUExpressionNode? filterExpression;
    if (subexpressions != null && subexpressions.isNotEmpty) {
      filterExpression = subexpressions.first is! CVUExpressionNodeNamed
          ? subexpressions.first
          : _getNamedExpression(subexpressions, "filter");
    }
    switch (node.name[0]) {
      case "~":

        /// LOOKUP REVERSE EDGE FOR EACH ITEM
        String itemType = items[0].type;
        var expectedTypes = db.schema.expectedSourceTypes(itemType, trimmedName);
        if (expectedTypes.isEmpty) return null;

        var sort = <Map<String, dynamic>>[];
        int? limit;
        if (subexpressions != null) {
          sort = await getSort(subexpressions, expectedTypes[0], db, context);
          limit = await _resolveNamedExpression<int>(subexpressions, "limit", db, context);
        }
        List<ItemRecord> result;
        if (node.isArray) {
          result = (await Future.wait(items.map((item) async =>
                  await item.reverseEdgeItems(trimmedName, db: db, sort: sort, limit: limit))))
              .expand((element) => element)
              .toList();
        } else {
          result = (await Future.wait(items.map(
                  (item) async => await item.reverseEdgeItem(trimmedName, db: db, sort: sort))))
              .whereType<ItemRecord>()
              .toList();
        }
        cached = LookupStepItems(await filter(result, filterExpression, db));
        context.setCache(nodePath, cached);
        return cached;
      default:

        /// CHECK IF WE'RE EXPECTING EDGES OR PROPERTIES
        String itemType = items[0].type;

        /// Check if this is an intrinsic property
        switch (node.name) {
          case "uid":
            return LookupStepValues(
                items.map((element) => PropertyDatabaseValueInt(element.rowId!)).toList());
          case "id":
            return LookupStepValues(
                items.map((element) => PropertyDatabaseValueString(element.uid)).toList());
          case "dateModified":
            return LookupStepValues(items
                .map((element) => PropertyDatabaseValueDatetime(element.dateModified))
                .toList());
          case "dateCreated":
            return LookupStepValues(items
                .map((element) => PropertyDatabaseValueDatetime(element.dateCreated))
                .toList());
          case "label":
            return LookupStepItems(await items.asMap()[0]?.edgeItems("label") ?? []);
          default:
            break;
        }

        /// Find out if it is a property or an edge (according to schema)
        var expectedType = db.schema.expectedType(itemType, node.name);
        if (expectedType is ResolvedTypeProperty) {
          /// LOOKUP PROPERTY FOR EACH ITEM
          List<PropertyDatabaseValue> result = [];
          await Future.forEach(items, (ItemRecord item) async {
            PropertyDatabaseValue? value = await item.propertyValue(node.name, db);
            if (value == null) {
              return null;
            }
            result.add(value);
          });
          return LookupStepValues(result);
        } else if (expectedType is ResolvedTypeEdge) {
          /// LOOKUP EDGE FOR EACH ITEM

          var sort = <Map<String, dynamic>>[];
          int? limit;
          if (subexpressions != null) {
            sort = await getSort(subexpressions, expectedType.value, db, context);
            limit = await _resolveNamedExpression<int>(subexpressions, "limit", db, context);
          }

          List<ItemRecord> result;
          if (node.isArray) {
            result = (await Future.wait(items.map((item) async =>
                    await item.edgeItems(trimmedName, db: db, sort: sort, limit: limit))))
                .expand((element) => element)
                .toList();
          } else {
            result = [];
            await Future.forEach(items, (ItemRecord item) async {
              var itemRecord = await item.edgeItem(trimmedName, db: db, sort: sort);
              if (itemRecord != null) result.add(itemRecord);
            });
          }
          cached = LookupStepItems(await filter(result, filterExpression, db));
          context.setCache(nodePath, cached);
          return cached;
        } else {
          return null;
        }
    }
  }

  /// Lookup a variable using its CVU string and return the value as a double
  Future<double?> _resolveNodesDouble(
      List<CVULookupNode> nodes, CVUContext context, DatabaseController db) async {
    if (lookupMockMode != null) {
      return lookupMockMode!.number;
    }
    var lookupResult = await resolve<LookupStep>(nodes: nodes, context: context, db: db);
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
  Future<int?> _resolveNodesInt(
      List<CVULookupNode> nodes, CVUContext context, DatabaseController db) async {
    if (lookupMockMode != null) {
      return lookupMockMode!.integer;
    }
    var lookupResult = await resolve<LookupStep>(nodes: nodes, context: context, db: db);
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
  Future<String?> _resolveNodesString(
      List<CVULookupNode> nodes, CVUContext context, DatabaseController db) async {
    if (lookupMockMode != null) {
      return lookupMockMode!.string;
    }
    LookupStep? lookupResult = await resolve<LookupStep>(nodes: nodes, context: context, db: db);
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
  Future<bool?> _resolveNodesBool(
      List<CVULookupNode> nodes, CVUContext context, DatabaseController db) async {
    if (lookupMockMode != null) {
      return lookupMockMode!.boolean;
    }
    LookupStep? lookupResult = await resolve<LookupStep>(nodes: nodes, context: context, db: db);
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
  Future<ItemRecord?> _resolveNodesItemRecord(
      List<CVULookupNode> nodes, CVUContext context, DatabaseController db) async {
    LookupStep? lookupResult = await resolve<LookupStep>(nodes: nodes, context: context, db: db);
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
  Future<List<ItemRecord>> _resolveNodesItemRecordArray(
      List<CVULookupNode> nodes, CVUContext context, DatabaseController db) async {
    LookupStep? lookupResult = await resolve<LookupStep>(nodes: nodes, context: context, db: db);
    if (lookupResult == null) {
      return [];
    }
    if (lookupResult is LookupStepItems) {
      return lookupResult.items;
    } else {
      return [];
    }
  }

  Future<ItemRecord?> _resolveExpressionItemRecord(
      CVUExpressionNode expression, CVUContext context, DatabaseController db) async {
    if (expression is CVUExpressionNodeLookup) {
      return await resolve<ItemRecord>(nodes: expression.nodes, context: context, db: db);
    } else if (expression is CVUExpressionNodeConditional) {
      bool conditionResolved =
          await resolve<bool>(expression: expression.condition, context: context, db: db) ?? false;
      if (conditionResolved) {
        return await resolve<ItemRecord>(expression: expression.trueExp, context: context, db: db);
      } else {
        return await resolve<ItemRecord>(expression: expression.falseExp, context: context, db: db);
      }
    } else if (expression is CVUExpressionNodeOr) {
      return await resolve<ItemRecord>(expression: expression.lhs, context: context, db: db) ??
          await resolve<ItemRecord>(expression: expression.rhs, context: context, db: db);
    } else {
      return null;
    }
  }

  Future<List<ItemRecord>> _resolveExpressionItemRecordArray(
      CVUExpressionNode expression, CVUContext context, DatabaseController db) async {
    if (expression is CVUExpressionNodeLookup) {
      return (await resolve<List>(
          nodes: expression.nodes,
          context: context,
          db: db,
          additionalType: ItemRecord)) as List<ItemRecord>;
    } else if (expression is CVUExpressionNodeConditional) {
      bool conditionResolved =
          await resolve<bool>(expression: expression.condition, context: context, db: db) ?? false;
      if (conditionResolved) {
        return (await resolve<List>(
            expression: expression.trueExp,
            context: context,
            db: db,
            additionalType: ItemRecord)) as List<ItemRecord>;
      } else {
        return (await resolve<List>(
            expression: expression.falseExp,
            context: context,
            db: db,
            additionalType: ItemRecord)) as List<ItemRecord>;
      }
    } else if (expression is CVUExpressionNodeAnd) {
      return ((await resolve<List>(
              expression: expression.lhs,
              context: context,
              db: db,
              additionalType: ItemRecord)) as List<ItemRecord>) +
          ((await resolve<List>(
              expression: expression.rhs,
              context: context,
              db: db,
              additionalType: ItemRecord)) as List<ItemRecord>);
    } else if (expression is CVUExpressionNodeOr) {
      var resolvedA = (await resolve<List>(
          expression: expression.lhs,
          context: context,
          db: db,
          additionalType: ItemRecord)) as List<ItemRecord>;
      return resolvedA.length > 0
          ? resolvedA
          : (await resolve<List>(
              expression: expression.rhs,
              context: context,
              db: db,
              additionalType: ItemRecord)) as List<ItemRecord>;
    } else if (expression is CVUExpressionNodeStringMode) {
      var first = expression.nodes.asMap()[0];
      var last = expression.nodes.asMap()[expression.nodes.length - 1];
      if (first is CVUExpressionNodeConstant && last is CVUExpressionNodeLookup) {
        var query = first.value;
        var lookupNodes = last.nodes;
        List? res = await _resolveToItemAndProperty(lookupNodes, context, db);
        ItemRecord? item = res?[0];
        String? property = res?[1];
        if (item != null && property != null) {
          var value = property == "uid"
              ? PropertyDatabaseValue.createFromDBValue(Value(item.uid), SchemaValueType.string)
              : await resolve<PropertyDatabaseValue>(property: property, item: item, db: db);
          if (value != null && value is PropertyDatabaseValueString) {
            var valueString = value.value;
            return await db.search("${query.asString()} $valueString");
          }
        }
      }
      return [];
    } else {
      return [];
    }
  }

  Future<double?> _resolveExpressionDouble(
      CVUExpressionNode expression, CVUContext context, DatabaseController db) async {
    if (expression is CVUExpressionNodeLookup) {
      return await resolve<double>(nodes: expression.nodes, context: context, db: db);
    } else if (expression is CVUExpressionNodeConditional) {
      bool conditionResolved =
          await resolve<bool>(expression: expression.condition, context: context, db: db) ?? false;
      if (conditionResolved) {
        return await resolve<double>(expression: expression.trueExp, context: context, db: db);
      } else {
        return await resolve<double>(expression: expression.falseExp, context: context, db: db);
      }
    } else if (expression is CVUExpressionNodeOr) {
      return await resolve<double>(expression: expression.lhs, context: context, db: db) ??
          await resolve<double>(expression: expression.rhs, context: context, db: db);
    } else if (expression is CVUExpressionNodeNegation) {
      print("CVU Expression error: Should not use ! operator on non-boolean value");
      return null;
    } else if (expression is CVUExpressionNodeAddition) {
      return (await resolve<double>(expression: expression.lhs, context: context, db: db) ?? 0) +
          (await resolve<double>(expression: expression.rhs, context: context, db: db) ?? 0);
    } else if (expression is CVUExpressionNodeSubtraction) {
      return (await resolve<double>(expression: expression.lhs, context: context, db: db) ?? 0) -
          (await resolve<double>(expression: expression.rhs, context: context, db: db) ?? 0);
    } else if (expression is CVUExpressionNodeConstant) {
      return expression.value.asNumber();
    } else if (expression is CVUExpressionNodeMultiplication) {
      return (await resolve<double>(expression: expression.lhs, context: context, db: db) ?? 0) *
          (await resolve<double>(expression: expression.rhs, context: context, db: db) ?? 0);
    } else if (expression is CVUExpressionNodeDivision) {
      double? lhs = await resolve<double>(expression: expression.lhs, context: context, db: db);
      double? rhs = await resolve<double>(expression: expression.rhs, context: context, db: db);
      if (lhs != null && rhs != null && rhs != 0) {
        return lhs / rhs;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<int?> _resolveExpressionInt(
      CVUExpressionNode expression, CVUContext context, DatabaseController db) async {
    if (expression is CVUExpressionNodeLookup) {
      return await resolve<int>(nodes: expression.nodes, context: context, db: db);
    } else if (expression is CVUExpressionNodeConditional) {
      bool conditionResolved =
          await resolve<bool>(expression: expression.condition, context: context, db: db) ?? false;
      if (conditionResolved) {
        return await resolve<int>(expression: expression.trueExp, context: context, db: db);
      } else {
        return await resolve<int>(expression: expression.falseExp, context: context, db: db);
      }
    } else if (expression is CVUExpressionNodeOr) {
      return await resolve<int>(expression: expression.lhs, context: context, db: db) ??
          await resolve<int>(expression: expression.rhs, context: context, db: db);
    } else if (expression is CVUExpressionNodeNegation) {
      print("CVU Expression error: Should not use ! operator on non-boolean value");
      return null;
    } else if (expression is CVUExpressionNodeAddition) {
      return (await resolve<int>(expression: expression.lhs, context: context, db: db) ?? 0) +
          (await resolve<int>(expression: expression.rhs, context: context, db: db) ?? 0);
    } else if (expression is CVUExpressionNodeSubtraction) {
      return (await resolve<int>(expression: expression.lhs, context: context, db: db) ?? 0) -
          (await resolve<int>(expression: expression.rhs, context: context, db: db) ?? 0);
    } else if (expression is CVUExpressionNodeConstant) {
      return expression.value.asInt();
    } else if (expression is CVUExpressionNodeMultiplication) {
      return (await resolve<int>(expression: expression.lhs, context: context, db: db) ?? 0) *
          (await resolve<int>(expression: expression.rhs, context: context, db: db) ?? 0);
    } else if (expression is CVUExpressionNodeDivision) {
      int? lhs = await resolve<int>(expression: expression.lhs, context: context, db: db);
      int? rhs = await resolve<int>(expression: expression.rhs, context: context, db: db);
      if (lhs != null && rhs != null && rhs != 0) {
        return (lhs / rhs).floor();
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<String?> _resolveExpressionString(
      CVUExpressionNode expression, CVUContext context, DatabaseController db) async {
    if (expression is CVUExpressionNodeLookup) {
      return await resolve<String>(nodes: expression.nodes, context: context, db: db);
    } else if (expression is CVUExpressionNodeConditional) {
      bool conditionResolved =
          await resolve<bool>(expression: expression.condition, context: context, db: db) ?? false;
      if (conditionResolved) {
        return await resolve<String>(expression: expression.trueExp, context: context, db: db);
      } else {
        return await resolve<String>(expression: expression.falseExp, context: context, db: db);
      }
    } else if (expression is CVUExpressionNodeOr) {
      return await resolve<String>(
              expression: expression.lhs, context: context, db: db) //TODO nilIfBlank?
          ??
          await resolve<String>(expression: expression.rhs, context: context, db: db);
    } else if (expression is CVUExpressionNodeNegation) {
      print("CVU Expression error: Should not use ! operator on non-boolean value");
      return null;
    } else if (expression is CVUExpressionNodeAddition) {
      return (await resolve<String>(expression: expression.lhs, context: context, db: db) ?? "") +
          (await resolve<String>(expression: expression.rhs, context: context, db: db) ?? "");
    } else if (expression is CVUExpressionNodeSubtraction) {
      print("CVU Expression error: Should not use - operator on string value");
      return null;
    } else if (expression is CVUExpressionNodeConstant) {
      return expression.value.asString();
    } else if (expression is CVUExpressionNodeStringMode) {
      return (await Future.wait(expression.nodes.map((element) async =>
              await resolve<String>(expression: element, context: context, db: db))))
          .whereType<String>()
          .join();
    } else {
      return null;
    }
  }

  Future<bool?> _resolveExpressionBool(
      CVUExpressionNode expression, CVUContext context, DatabaseController db) async {
    if (expression is CVUExpressionNodeLookup) {
      return await resolve<bool>(nodes: expression.nodes, context: context, db: db);
    } else if (expression is CVUExpressionNodeConditional) {
      bool conditionResolved =
          await resolve<bool>(expression: expression.condition, context: context, db: db) ?? false;
      if (conditionResolved) {
        return await resolve<bool>(expression: expression.trueExp, context: context, db: db);
      } else {
        return await resolve<bool>(expression: expression.falseExp, context: context, db: db);
      }
    } else if (expression is CVUExpressionNodeAnd) {
      return (await resolve<bool>(expression: expression.lhs, context: context, db: db) ?? false) &&
          (await resolve<bool>(expression: expression.rhs, context: context, db: db) ?? false);
    } else if (expression is CVUExpressionNodeOr) {
      return (await resolve<bool>(expression: expression.lhs, context: context, db: db) ?? false) ||
          (await resolve<bool>(expression: expression.rhs, context: context, db: db) ?? false);
    } else if (expression is CVUExpressionNodeNegation) {
      bool? res = await resolve<bool>(expression: expression.expression, context: context, db: db);
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
      double? lhs = await resolve<double>(expression: expression.lhs, context: context, db: db);
      double? rhs = await resolve<double>(expression: expression.rhs, context: context, db: db);
      if (lhs == null || rhs == null) {
        return null;
      }
      return lhs < rhs;
    } else if (expression is CVUExpressionNodeGreaterThan) {
      double? lhs = await resolve<double>(expression: expression.lhs, context: context, db: db);
      double? rhs = await resolve<double>(expression: expression.rhs, context: context, db: db);
      if (lhs == null || rhs == null) {
        return null;
      }
      return lhs > rhs;
    } else if (expression is CVUExpressionNodeLessThanOrEqual) {
      double? lhs = await resolve<double>(expression: expression.lhs, context: context, db: db);
      double? rhs = await resolve<double>(expression: expression.rhs, context: context, db: db);
      if (lhs == null || rhs == null) {
        return null;
      }
      return lhs <= rhs;
    } else if (expression is CVUExpressionNodeGreaterThanOrEqual) {
      double? lhs = await resolve<double>(expression: expression.lhs, context: context, db: db);
      double? rhs = await resolve<double>(expression: expression.rhs, context: context, db: db);
      if (lhs == null || rhs == null) {
        return null;
      }
      return lhs >= rhs;
    } else if (expression is CVUExpressionNodeAreEqual) {
      dynamic lhs = await resolve<double>(expression: expression.lhs, context: context, db: db);
      dynamic rhs = await resolve<double>(expression: expression.rhs, context: context, db: db);
      if (lhs == null || rhs == null) {
        lhs = await resolve<ItemRecord>(expression: expression.lhs, context: context, db: db);
        rhs = await resolve<ItemRecord>(expression: expression.rhs, context: context, db: db);
        if (lhs != null && rhs != null) {
          return lhs.rowId == rhs.rowId;
        }
      }
      if (lhs == null || rhs == null) {
        lhs = await resolve<String>(expression: expression.lhs, context: context, db: db);
        rhs = await resolve<String>(expression: expression.rhs, context: context, db: db);
      }
      if (lhs == null || rhs == null) {
        lhs = await resolve<bool>(expression: expression.lhs, context: context, db: db);
        rhs = await resolve<bool>(expression: expression.rhs, context: context, db: db);
      }
      if (lhs == null || rhs == null) {
        return false;
      }
      return lhs == rhs;
    } else if (expression is CVUExpressionNodeAreNotEqual) {
      dynamic lhs = await resolve<double>(expression: expression.lhs, context: context, db: db);
      dynamic rhs = await resolve<double>(expression: expression.rhs, context: context, db: db);
      if (lhs == null || rhs == null) {
        lhs = await resolve<ItemRecord>(expression: expression.lhs, context: context, db: db);
        rhs = await resolve<ItemRecord>(expression: expression.rhs, context: context, db: db);
        if (lhs != null && rhs != null) {
          return lhs.rowId != rhs.rowId;
        }
      }
      if (lhs == null || rhs == null) {
        lhs = await resolve<String>(expression: expression.lhs, context: context, db: db);
        rhs = await resolve<String>(expression: expression.rhs, context: context, db: db);
      }
      if (lhs == null || rhs == null) {
        lhs = await resolve<bool>(expression: expression.lhs, context: context, db: db);
        rhs = await resolve<bool>(expression: expression.rhs, context: context, db: db);
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
  Future<List?> _resolveToItemAndProperty(
      List<CVULookupNode> nodes, CVUContext context, DatabaseController db) async {
    ItemRecord? currentItem;
    if (nodes.isEmpty) {
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
          LookupStep? step = await itemLookup(
              node: node,
              items: [nextItem],
              subexpressions: nodeType.subexpressions,
              context: context,
              db: db);
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
  final int integer;

  LookupMock(this.boolean, this.string, this.number, this.integer);
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
