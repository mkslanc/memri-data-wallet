//
//  CVUController.swift
//  MemriDatabase
//
//  Created by T Brennan on 7/12/20.
//

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memri/MemriApp/CVU/parsing/CVULexer.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUParser.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/CVU/resolving/CVULookupController.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/Controllers/PageController.dart' as memri;
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Enum.dart';
import 'package:memri/MemriApp/Model/Database.dart';
import 'package:memri/MemriApp/UI/CVUComponents/CVUElementView.dart';
import 'package:memri/MemriApp/UI/CVUComponents/CVUUINodeResolver.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import 'definitions/CVUParsedDefinition.dart';
import 'definitions/CVUUINode.dart';

class CVUController {
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
      print(error);
      definitions = [];
    }
  }

  resetToDefault() async {
    reset();
    try {
      definitions = await CVUController.parseCVU();
      await Future.forEach<CVUParsedDefinition>(
          definitions, (definition) async => await updateDefinition(definition, definition.parsed));
    } catch (error) {
      print(error);
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
    var manifestJson = await rootBundle.loadString('AssetManifest.json', cache: false);
    List<String> cvus = json
        .decode(manifestJson)
        .keys
        .where((String key) => key.startsWith('assets/defaultCVU'))
        .toList();

    cvus = await Future.wait(
        cvus.map((cvu) async => await rootBundle.loadString(cvu, cache: false)).toList());

    return cvus.join("\n").replaceAll("\r", "");
  }

  Future updateDefinition(CVUParsedDefinition definition, CVUDefinitionContent content) async {
    definition.parsed = content;
    var storedDefinitionItems = await databaseController.databasePool
        .itemPropertyRecordsSelect("querystr", value: definition.querystr);
    var storedDefinitionIds =
        storedDefinitionItems.compactMap<int>((item) => item is StringDb ? item.item : null);
    var validStoredDefinitions = (await ItemRecord.fetchWithRowIDs(storedDefinitionIds))
        .where((item) => item.type == "CVUStoredDefinition");
    if (validStoredDefinitions.length != 1) {
      print("Error! Could not find valid stored definition for: ${definition.querystr}");
      return;
    }
    var storedDefinition = validStoredDefinitions.first;
    await storedDefinition.setPropertyValue(
        "definition", PropertyDatabaseValueString(definition.toCVUString(0, "    ", true)));
  }

  storeDefinitions() async {
    await databaseController.databasePool.transaction(() async {
      await Future.forEach<CVUParsedDefinition>(definitions, (definition) async {
        var storedDefinition = ItemRecord(type: "CVUStoredDefinition");
        storedDefinitions.add(storedDefinition);
        await storedDefinition.save();
        await storedDefinition.setPropertyValue(
            "domain", PropertyDatabaseValueString(definition.domain.inString));
        await storedDefinition.setPropertyValue(
            "name", PropertyDatabaseValueString(definition.name ?? ""));
        await storedDefinition.setPropertyValue(
            "renderer", PropertyDatabaseValueString(definition.renderer ?? ""));
        await storedDefinition.setPropertyValue(
            "selector", PropertyDatabaseValueString(definition.selector ?? ""));
        await storedDefinition.setPropertyValue(
            "type", PropertyDatabaseValueString(definition.type.inString));
        await storedDefinition.setPropertyValue(
            "definition", PropertyDatabaseValueString(definition.toCVUString(0, "    ", true)));
        await storedDefinition.setPropertyValue(
            "querystr", PropertyDatabaseValueString(definition.querystr));
      });
    });
  }

  loadStoredDefinitions() async {
    if (storedDefinitions.isNotEmpty) {
      return;
    }
    storedDefinitions = await ItemRecord.fetchWithType("CVUStoredDefinition", databaseController);
    if (storedDefinitions.isEmpty) {
      return;
    }
    var rowIds = storedDefinitions.map((item) => item.rowId);
    var properties = await databaseController.databasePool
        .itemPropertyRecordsCustomSelect("item IN (${rowIds.join(", ")})");
    var groupedProperties = properties.groupListsBy((property) => property.item);
    definitions = (await Future.wait(storedDefinitions.map((storedDefinition) async {
      var properties = groupedProperties[storedDefinition.rowId]!
          .toMapByKey((property) => property.name, (property) => property.value);
      var definition = (await CVUController.parseCVU(properties["definition"])).first;
      return CVUParsedDefinition(
          domain: EnumExtension.rawValue<CVUDefinitionDomain>(
                  CVUDefinitionDomain.values, properties["domain"]) ??
              CVUDefinitionDomain.user,
          selector: properties["selector"],
          name: properties["name"],
          renderer: properties["renderer"],
          type: EnumExtension.rawValue<CVUDefinitionType>(
                  CVUDefinitionType.values, properties["type"]) ??
              CVUDefinitionType.other,
          parsed: definition.parsed);
    })));
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
      {required ItemRecord item, String? selector, String? renderer}) {
    return definitionFor(
        type: CVUDefinitionType.uiNode, selector: item.type, rendererName: renderer);
  }

  CVUDefinitionContent? viewDefinitionFor(
      {required String viewName, CVUDefinitionContent? customDefinition}) {
    var definition = definitionFor(type: CVUDefinitionType.view, viewName: viewName)?.parsed;
    return definition?.merge(customDefinition) ?? customDefinition;
  }

  CVUDefinitionContent? viewDefinitionForItemRecord({ItemRecord? itemRecord}) {
    var definition =
        definitionFor(type: CVUDefinitionType.view, selector: itemRecord?.type)?.parsed;
    return definition;
  }

  CVUDefinitionContent? edgeDefinitionFor(ItemRecord itemRecord) {
    var definition =
        definitionFor(type: CVUDefinitionType.view, selector: "${itemRecord.type}[]")?.parsed;
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
    var globalDefinition =
        definitionFor(type: CVUDefinitionType.renderer, viewName: context.rendererName);
    if (globalDefinition != null) {
      return globalDefinition.merge(specificDefinition);
    } else {
      return specificDefinition;
    }
  }

  CVUDefinitionContent? rendererDefinitionForSelector({String? selector, String? viewName}) {
    var definition =
        definitionFor(type: CVUDefinitionType.renderer, selector: selector, viewName: viewName)
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
          definitionFor(type: CVUDefinitionType.view, selector: selector)?.parsed;
      if (globalDefinition != null) {
        if (globalDefinition.children.length > 0) {
          return globalDefinition;
        }
        var rendererDefinition = globalDefinition.definitions
            .where((el) => el.name == context.rendererName && el.parsed.children.length > 0)
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
      if (lhs.selector == "*" || lhs.selector == "*[]" || lhs.selector == null) {
        return -1;
      } else if (rhs.selector == "*" || rhs.selector == "*[]" || rhs.selector == null) {
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
      required memri.PageController pageController,
      Key? key}) {
    CVUUINode? node = nodeFor(cvuContext, nodeDefinition);
    if (node != null) {
      return CVUElementView(
        nodeResolver: CVUUINodeResolver(
            context: cvuContext,
            lookup: lookup,
            node: node,
            db: db,
            pageController: pageController),
        key: key,
      );
    } else if (!blankIfNoDefinition && cvuContext.currentItem?.type != null) {
      var type = cvuContext.currentItem!.type;
      return Text("No definition for displaying a `$type` in this context",
          style: TextStyle(fontFamily: "caption"));
    }
    return Empty();
  }

  CVUUINode? nodeFor(CVUContext cvuContext, [CVUDefinitionContent? nodeDefinition]) {
    nodeDefinition ??= nodeDefinitionFor(cvuContext);
    return nodeDefinition?.children.asMap()[0] ??
        defaultViewDefinitionFor(cvuContext)?.children.asMap()[0];
  }
}
