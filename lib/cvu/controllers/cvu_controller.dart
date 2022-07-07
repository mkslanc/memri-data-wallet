//  Created by T Brennan on 7/12/20.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memri/core/models/item.dart';
import 'package:memri/cvu/services/parsing/cvu_parser.dart';
import 'package:memri/constants/app_logger.dart';
import 'package:memri/cvu/controllers/cvu_lookup_controller.dart';
import 'package:memri/cvu/models/cvu_lexer.dart';
import 'package:memri/cvu/models/cvu_parsed_definition.dart';
import 'package:memri/cvu/models/cvu_ui_node.dart';
import 'package:memri/cvu/models/cvu_value.dart';
import 'package:memri/cvu/models/cvu_view_arguments.dart';
import 'package:memri/utilities/extensions/collection.dart';
import 'package:memri/utilities/extensions/enum.dart';
import 'package:memri/utilities/extensions/string.dart';
import 'package:memri/cvu/widgets/components/cvu_element_view.dart';
import 'package:memri/cvu/widgets/components/cvu_ui_node_resolver.dart';
import 'package:memri/widgets/empty.dart';

import '../../core/services/pod_service.dart';
import '../services/resolving/cvu_context.dart';

class CVUController extends ChangeNotifier {
  late List<CVUParsedDefinition> definitions;

  List<Item> storedDefinitions = [];

  final PodService _podService;

  CVUController(this._podService);

  Future<void> init() async {
    try {
      await loadStoredDefinitions();
      if (definitions.isEmpty) {
        var _definitions = await parseCVU();
        await storeDefinitions(_definitions);
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

  Future<List<CVUParsedDefinition>> parseCVU([String? string]) async {
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

  void updateDefinition({String? content, List<CVUParsedDefinition>? parsed}) {
    parsed ??= CVUController.parseCVUString(content!);
    for (var definition in parsed) {
      var storedDefinition = storedDefinitions.firstWhereOrNull(
          (element) => element.get("queryStr") == definition.queryStr);

      if (storedDefinition == null) {
        AppLogger.err(
            "Error! Could not find valid stored definition for: ${definition.queryStr}");
        return;
      }

      storedDefinition.properties["definition"] =
          definition.toCVUString(0, "    ", true);
      _podService.updateItem(item: storedDefinition);

      replaceDefinitionByQuery(definition.queryStr, definition);
    }
    notifyListeners();
  }

  storeDefinitions(List<CVUParsedDefinition> _definitions) async {
    _definitions
        .forEach((definition) => storeDefinition(definition: definition));
  }

  Future<Item?> storeDefinition(
      {String? cvuString, CVUParsedDefinition? definition}) async {
    definition ??= parseCVUString(cvuString!).asMap()[0];
    if (definition == null) {
      return null;
    }

    var properties = {
      "name": definition.name ?? "",
      "domain": definition.domain.inString,
      "renderer": definition.renderer ?? "",
      "selector": definition.selector ?? "",
      "definitionType": definition.type.inString,
      "definition": definition.toCVUString(0, "    ", true),
      "queryStr": definition.queryStr,
    };

    var storedDefinition = await _podService.createItem(
        item: Item(type: "CVUStoredDefinition", properties: properties));
    storedDefinitions.add(storedDefinition);
    definitions.add(definition);
    return storedDefinition;
  }

  loadStoredDefinitions() async {
    if (storedDefinitions.isNotEmpty) {
      return;
    }
    definitions = [];
    var query = '''
      query {
        CVUStoredDefinition {
          id
          name
          domain
          renderer
          selector
          definitionType
          definition
          queryStr
        }
      }''';
    storedDefinitions = await _podService.graphql(query: query);

    if (storedDefinitions.isEmpty) {
      return;
    }
    definitions = storedDefinitions
        .map((storedDefinition) => CVUParsedDefinition(
            domain: EnumExtension.rawValue<CVUDefinitionDomain>(
                    CVUDefinitionDomain.values,
                    storedDefinition.get("domain")) ??
                CVUDefinitionDomain.user,
            selector:
                (storedDefinition.get("selector") as String?)?.nullIfBlank,
            name: (storedDefinition.get("name") as String?)?.nullIfBlank,
            renderer:
                (storedDefinition.get("renderer") as String?)?.nullIfBlank,
            type: EnumExtension.rawValue<CVUDefinitionType>(
                    CVUDefinitionType.values,
                    storedDefinition.get("definitionType")) ??
                CVUDefinitionType.other,
            parsed: parseCVUString(storedDefinition.get("definition"))
                .first
                .parsed))
        .toList();
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
        nodeResolver:
            CVUUINodeResolver(context: cvuContext, lookup: lookup, node: node),
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
