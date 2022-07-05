//  Created by T Brennan on 7/12/20.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memri/core/models/item.dart';
import 'package:memri/cvu/services/parsing/cvu_parser.dart';
import 'package:memri/constants/app_logger.dart';
import 'package:memri/core/controllers/app_controller.dart';
import 'package:memri/cvu/controllers/cvu_lookup_controller.dart';
import 'package:memri/core/controllers/database_controller.dart';
import 'package:memri/cvu/models/cvu_lexer.dart';
import 'package:memri/cvu/models/cvu_parsed_definition.dart';
import 'package:memri/cvu/models/cvu_ui_node.dart';
import 'package:memri/cvu/models/cvu_value.dart';
import 'package:memri/cvu/models/cvu_view_arguments.dart';
import 'package:memri/core/models/database/database.dart' as database;
import 'package:memri/core/models/database/item_property_record.dart';
import 'package:memri/core/models/database/item_record.dart';
import 'package:memri/core/services/database/property_database_value.dart';
import 'package:memri/utilities/extensions/collection.dart';
import 'package:memri/utilities/extensions/enum.dart';
import 'package:memri/utilities/extensions/string.dart';
import 'package:memri/cvu/widgets/components/cvu_element_view.dart';
import 'package:memri/cvu/widgets/components/cvu_ui_node_resolver.dart';
import 'package:memri/widgets/empty.dart';

import '../services/resolving/cvu_context.dart';

class CVUController extends ChangeNotifier {
  late List<CVUParsedDefinition> definitions;
  final DatabaseController databaseController;

  List<ItemRecord> storedDefinitions = [];

  CVUController(this.databaseController);

  init() async {
    try {
      definitions = [];
      await loadStoredDefinitions();
      if (definitions.isEmpty) {
        definitions = await CVUController.parseCVU();
      }
    } catch (error) {
      AppLogger.err(error);
      definitions = [];
    }
  }

  resetToDefault([List<CVUParsedDefinition>? revertingDefinitions]) async {
    try {
      var definitionsToRevert = revertingDefinitions ?? definitions;
      var defaultDefinitions = await CVUController.parseCVU();
      for (var definition in definitionsToRevert) {
        var defaultDefinition = defaultDefinitions.firstWhereOrNull(
            (element) => element.queryStr == definition.queryStr);
        if (defaultDefinition != null &&
            defaultDefinition.parsed != definition.parsed) {
          await updateDefinition(parsed: [defaultDefinition]);
        }
        defaultDefinitions.remove(defaultDefinition);
      }
      if (revertingDefinitions == null) {
        for (var defaultDefinition in defaultDefinitions) {
          await storeDefinition(databaseController,
              definition: defaultDefinition);
        }
      }
    } catch (error) {
      AppLogger.err(error);
      definitions = [];
    }
  }

  reset() {
    definitions = [];
    storedDefinitions = [];
  }

  static Future<List<CVUParsedDefinition>> parseCVU([String? string]) async {
    string ??= await CVUController.readCVUString();
    return CVUController.parseCVUString(string);
  }

  static List<CVUParsedDefinition> parseCVUString(String string) {
    var lexer = CVULexer(string);
    var tokens = lexer.tokenize();
    var parser = CVUParser(tokens);
    return parser.parse();
  }

  static Future<String> readCVUString() async {
    var manifestJson =
        await rootBundle.loadString('AssetManifest.json', cache: false);
    List<String> cvus = json
        .decode(manifestJson)
        .keys
        .where((String key) => key.startsWith('assets/defaultCVU'))
        .toList();

    cvus = await Future.wait(cvus
        .map((cvu) async => await rootBundle.loadString(cvu, cache: false))
        .toList());

    return cvus.join("\n").replaceAll("\r", "");
  }

  Future updateDefinition(
      {String? content, List<CVUParsedDefinition>? parsed}) async {
    parsed ??= CVUController.parseCVUString(content!);
    for (var definition in parsed) {
      var storedDefinitionItems = await databaseController.databasePool
          .itemPropertyRecordsSelect("queryStr", value: definition.queryStr);
      var storedDefinitionIds = storedDefinitionItems.compactMap<int>(
          (item) => item is database.StringDb ? item.item : null);
      var validStoredDefinitions =
          (await ItemRecord.fetchWithRowIDs(storedDefinitionIds))
              .where((item) => item.type == "CVUStoredDefinition");
      if (validStoredDefinitions.length != 1) {
        AppLogger.err(
            "Error! Could not find valid stored definition for: ${definition.queryStr}");
        return;
      }
      var storedDefinition = validStoredDefinitions.first;
      await storedDefinition.setPropertyValue("definition",
          PropertyDatabaseValueString(definition.toCVUString(0, "    ", true)));
      replaceDefinitionByQuery(definition.queryStr, definition);
    }
    notifyListeners();
  }

  storeDefinitions() async {
    await databaseController.databasePool.transaction(() async {
      List<ItemPropertyRecord> properties = [];
      Map<String, CVUParsedDefinition> definitionsByUID = {};

      definitions.forEach((definition) {
        var storedDefinition = ItemRecord(type: "CVUStoredDefinition");
        storedDefinitions.add(storedDefinition);
        definitionsByUID[storedDefinition.uid] = definition;
      });
      await ItemRecord.insertList(storedDefinitions,
          db: databaseController.databasePool);

      List<ItemRecord> newItemList = (await ItemRecord.fetchWithUIDs(
          storedDefinitions.map((e) => e.uid).toList(),
          databaseController.databasePool));
      newItemList.forEach((item) {
        properties.add(ItemPropertyRecord(
            itemRowID: item.rowId!,
            name: "domain",
            value: PropertyDatabaseValueString(
                definitionsByUID[item.uid]!.domain.inString)));
        properties.add(ItemPropertyRecord(
            itemRowID: item.rowId!,
            name: "name",
            value: PropertyDatabaseValueString(
                definitionsByUID[item.uid]!.name ?? "")));
        properties.add(ItemPropertyRecord(
            itemRowID: item.rowId!,
            name: "renderer",
            value: PropertyDatabaseValueString(
                definitionsByUID[item.uid]!.renderer ?? "")));
        properties.add(ItemPropertyRecord(
            itemRowID: item.rowId!,
            name: "selector",
            value: PropertyDatabaseValueString(
                definitionsByUID[item.uid]!.selector ?? "")));
        properties.add(ItemPropertyRecord(
            itemRowID: item.rowId!,
            name: "definitionType",
            value: PropertyDatabaseValueString(
                definitionsByUID[item.uid]!.type.inString)));
        properties.add(ItemPropertyRecord(
            itemRowID: item.rowId!,
            name: "definition",
            value: PropertyDatabaseValueString(
                definitionsByUID[item.uid]!.toCVUString(0, "    ", true))));
        properties.add(ItemPropertyRecord(
            itemRowID: item.rowId!,
            name: "queryStr",
            value: PropertyDatabaseValueString(
                definitionsByUID[item.uid]!.queryStr)));
      });
      await ItemPropertyRecord.insertList(properties,
          db: databaseController.databasePool);
    });
  }

  static Future<int?> storeDefinition(DatabaseController databaseController,
      {String? cvuString, CVUParsedDefinition? definition}) async {
    definition ??= parseCVUString(cvuString!).asMap()[0];
    if (definition == null) {
      return null;
    }
    AppController.shared.cvuController.definitions.add(definition);
    List<ItemPropertyRecord> properties = [];
    var storedDefinition = ItemRecord(type: "CVUStoredDefinition");
    await storedDefinition.save(databaseController.databasePool);
    properties.add(ItemPropertyRecord(
        name: "domain",
        value: PropertyDatabaseValueString(definition.domain.inString)));
    properties.add(ItemPropertyRecord(
        name: "name",
        value: PropertyDatabaseValueString(definition.name ?? "")));
    properties.add(ItemPropertyRecord(
        name: "renderer",
        value: PropertyDatabaseValueString(definition.renderer ?? "")));
    properties.add(ItemPropertyRecord(
        name: "selector",
        value: PropertyDatabaseValueString(definition.selector ?? "")));
    properties.add(ItemPropertyRecord(
        name: "definitionType",
        value: PropertyDatabaseValueString(definition.type.inString)));
    properties.add(ItemPropertyRecord(
        name: "definition",
        value: PropertyDatabaseValueString(
            definition.toCVUString(0, "    ", true))));
    properties.add(ItemPropertyRecord(
        name: "queryStr",
        value: PropertyDatabaseValueString(definition.queryStr)));

    await storedDefinition.setPropertyValueList(properties,
        db: databaseController);
    return storedDefinition.rowId;
  }

  loadStoredDefinitions() async {
    if (storedDefinitions.isNotEmpty) {
      return;
    }
    storedDefinitions = await ItemRecord.fetchWithType(
        "CVUStoredDefinition", databaseController.databasePool);
    if (storedDefinitions.isEmpty) {
      return;
    }
    var rowIds = storedDefinitions.map((item) => item.rowId);
    var properties = await databaseController.databasePool
        .itemPropertyRecordsCustomSelect("item IN (${rowIds.join(", ")})");
    var groupedProperties =
        properties.groupListsBy((property) => property.item);
    definitions =
        (await Future.wait(storedDefinitions.map((storedDefinition) async {
      var properties = groupedProperties[storedDefinition.rowId]!.toMapByKey(
          (property) => property.name, (property) => property.value);
      var definition =
          (await CVUController.parseCVU(properties["definition"])).first;
      return CVUParsedDefinition(
          domain: EnumExtension.rawValue<CVUDefinitionDomain>(
                  CVUDefinitionDomain.values, properties["domain"]) ??
              CVUDefinitionDomain.user,
          selector: (properties["selector"] as String?)?.nullIfBlank,
          name: (properties["name"] as String?)?.nullIfBlank,
          renderer: (properties["renderer"] as String?)?.nullIfBlank,
          type: EnumExtension.rawValue<CVUDefinitionType>(
                  CVUDefinitionType.values, properties["definitionType"]) ??
              CVUDefinitionType.other,
          parsed: definition.parsed);
    })));
  }

  CVUParsedDefinition? definitionByQuery(String queryStr) =>
      definitions.firstWhereOrNull((element) => element.queryStr == queryStr);

  replaceDefinitionByQuery(String queryStr, CVUParsedDefinition newDefinition) {
    var definition = definitionByQuery(queryStr);
    if (definition != null) {
      var index = definitions.indexOf(definition);
      definitions.replaceRange(index, index + 1, [newDefinition]);
    }
  }

  CVUParsedDefinition? definitionFor(
      {required CVUDefinitionType type,
      String? selector,
      String? viewName,
      String? rendererName,
      bool exactSelector = false,
      List<CVUParsedDefinition>? specifiedDefinitions}) {
    return CVUController._definitionFrom(
        definitions: specifiedDefinitions ?? definitions,
        type: type,
        selector: selector,
        exactSelector: exactSelector,
        viewName: viewName,
        rendererName: rendererName);
  }

  CVUParsedDefinition? nodeDefinitionForItem(
      {required Item item, String? selector, String? renderer}) {
    return definitionFor(
        type: CVUDefinitionType.uiNode,
        selector: item.type,
        rendererName: renderer);
  }

  CVUDefinitionContent? viewDefinitionFor(
      {required String viewName, CVUDefinitionContent? customDefinition}) {
    var definition =
        definitionFor(type: CVUDefinitionType.view, viewName: viewName)?.parsed;
    return definition?.merge(customDefinition) ?? customDefinition;
  }

  CVUDefinitionContent? viewDefinitionForItemRecord({Item? item}) {
    var definition =
        definitionFor(type: CVUDefinitionType.view, selector: item?.type)
            ?.parsed;
    return definition;
  }

  CVUDefinitionContent? edgeDefinitionFor(Item item) {
    var definition =
        definitionFor(type: CVUDefinitionType.view, selector: "${item.type}[]")
            ?.parsed;
    return definition;
  }

  CVUParsedDefinition? rendererDefinitionFor(CVUContext context) {
    var specificDefinition = CVUController._definitionFrom(
        definitions: context.viewDefinition.definitions,
        type: CVUDefinitionType.renderer,
        viewName: context.rendererName);
    if (specificDefinition == null) {
      return null;
    }
    var globalDefinition = definitionFor(
        type: CVUDefinitionType.renderer, viewName: context.rendererName);
    if (globalDefinition != null) {
      return globalDefinition.merge(specificDefinition);
    } else {
      return specificDefinition;
    }
  }

  CVUDefinitionContent? rendererDefinitionForSelector(
      {String? selector, String? viewName}) {
    var definition = definitionFor(
            type: CVUDefinitionType.renderer,
            selector: selector,
            viewName: viewName)
        ?.parsed;
    return definition;
  }

  CVUDefinitionContent? defaultViewDefinitionFor(CVUContext context) {
    var currentItem = context.currentItem;
    if (currentItem == null) {
      return null;
    }

    for (var selector in ["${currentItem.type}[]", "*[]"]) {
      var globalDefinition =
          definitionFor(type: CVUDefinitionType.view, selector: selector)
              ?.parsed;
      if (globalDefinition != null) {
        if (globalDefinition.children.length > 0) {
          return globalDefinition;
        }
        var rendererDefinition = globalDefinition.definitions
            .where((el) =>
                el.name == context.rendererName &&
                el.parsed.children.length > 0)
            .toList()
            .asMap()[0];
        if (rendererDefinition != null) {
          return rendererDefinition.parsed;
        }
      }
    }
    return null;
  }

  CVUDefinitionContent? nodeDefinitionFor(CVUContext context) {
    var currentItem = context.currentItem;
    if (currentItem == null) {
      return null;
    }

    var globalDefinition = definitionFor(
            type: CVUDefinitionType.uiNode,
            selector: currentItem.type,
            rendererName: context.rendererName)
        ?.parsed;
    var specificDefinition = definitionFor(
            specifiedDefinitions: context.viewDefinition.definitions,
            type: CVUDefinitionType.uiNode,
            selector: currentItem.type,
            rendererName: context.rendererName)
        ?.parsed;

    return globalDefinition?.merge(specificDefinition) ?? specificDefinition;
  }

  static CVUParsedDefinition? _definitionFrom(
      {required List<CVUParsedDefinition> definitions,
      required CVUDefinitionType type,
      String? selector,
      bool exactSelector = false,
      String? viewName,
      String? rendererName}) {
    var relevantDefinitions = definitions.where((def) {
      // Find a definition of the requested type
      if (def.type != type) {
        return false;
      }

      // with matching name
      if (viewName != null) {
        if (def.name?.toLowerCase() != viewName.toLowerCase()) {
          return false;
        }
      }

      // with matching rendererName
      if (rendererName != null) {
        if (def.renderer?.toLowerCase() != rendererName.toLowerCase()) {
          return false;
        }
      }

      // with matching selector or wildcard selector
      if (selector != null) {
        if (def.selector?.toLowerCase() == selector.toLowerCase() ||
            (!exactSelector && (def.selector == "*" || def.selector == null))) {
          return true;
        } else {
          return false;
        }
      }
      return true;
    }).toList();
    relevantDefinitions.sort((lhs, rhs) {
      if (lhs.selector == "*" ||
          lhs.selector == "*[]" ||
          lhs.selector == null) {
        return -1;
      } else if (rhs.selector == "*" ||
          rhs.selector == "*[]" ||
          rhs.selector == null) {
        return 0;
      } else {
        // TODO: Improve this VERY crude way of determining selector specificity
        return (lhs.selector?.length ?? 0) - (rhs.selector?.length ?? 0);
      }
    });
    if (relevantDefinitions.isEmpty) {
      return null;
    }

    var mergedDefinition = relevantDefinitions.reduce((old, latest) {
      return old.merge(latest);
    });
    return mergedDefinition;
  }

  Widget render(
      {required CVUContext cvuContext,
      required CVUDefinitionContent? nodeDefinition,
      required CVULookupController lookup,
      required DatabaseController db,
      required bool blankIfNoDefinition,
      Key? key}) {
    nodeDefinition ??= nodeDefinitionFor(cvuContext);
    CVUUINode? node = nodeFor(cvuContext, nodeDefinition);

    if (node != null) {
      var viewArgs = nodeDefinition!.properties["viewArguments"];
      if (viewArgs is CVUValueSubdefinition) {
        cvuContext.viewArguments ??= CVUViewArguments();
        cvuContext.viewArguments!.argumentItem = cvuContext.currentItem;
        cvuContext.viewArguments!.args.addAll(viewArgs.value.properties);
      }

      return CVUElementView(
        nodeResolver: CVUUINodeResolver(
            context: cvuContext, lookup: lookup, node: node, db: db),
        key: key,
      );
    } else if (!blankIfNoDefinition && cvuContext.currentItem?.type != null) {
      var type = cvuContext.currentItem!.type;
      return Text("No definition for displaying a `$type` in this context",
          style: TextStyle(fontFamily: "caption"));
    }
    return Empty();
  }

  CVUUINode? nodeFor(CVUContext cvuContext,
      [CVUDefinitionContent? nodeDefinition]) {
    nodeDefinition ??= nodeDefinitionFor(cvuContext);
    return nodeDefinition?.children.asMap()[0] ??
        defaultViewDefinitionFor(cvuContext)?.children.asMap()[0];
  }
}
