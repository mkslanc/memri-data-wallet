//
// CVUParsedDefinition.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:memri/MemriApp/CVU/parsing/CVUStringConvertible.dart';

import 'CVUUINode.dart';
import 'CVUValue.dart';

/// An enum describing the different types of definition in CVU.
/// These have different ways of being expressed in CVU eg. [renderer = ...], Text, .someViewName
enum CVUDefinitionType {
  view,
  views,
  uiNode,
  sessions,
  renderer,
  datasource,
  language,
  other
}

enum CVUDefinitionDomain { user }

/// A struct holding the content of a CVUDefinition
/// Contains properties, children, and sub-definitions
class CVUDefinitionContent {
  List<CVUParsedDefinition> definitions = [];
  List<CVUUINode> children = [];
  Map<String, CVUValue> properties = {};

/*  CVUPropertyResolver propertyResolver({//TODO @anijanyan
    CVUContext context,
    CVULookupController lookup,
    DatabaseController db:
  }) {
    return CVUPropertyResolver(context: context, lookup: lookup, db: db, properties: properties);
  }*/

  String toCVUString(int depth, String tab, bool includeInitialTab) {
    String tabs = tab * depth;
    String propertiesString = properties.isEmpty ? "" : properties.toCVUString(depth + 1, tab, true);
    if (propertiesString.isNotEmpty) {
      propertiesString += "\n";
    }

    String childrenString =
        children.isEmpty ? "" : children.map((node) => node.toCVUString(depth + 1, tab, true)).join("\n");
    if (childrenString.isNotEmpty) {
      childrenString += "\n";
    }

    String nestedDefinitions =
        definitions.isEmpty ? "" : definitions.map((element) => element.toCVUString(depth + 1, tab, true)).join("\n\n");
    if (nestedDefinitions.isNotEmpty) {
      nestedDefinitions += "\n";
    }

    bool newLineA = propertiesString.isNotEmpty && childrenString.isNotEmpty;
    bool newLineB = nestedDefinitions.isNotEmpty && (propertiesString.isNotEmpty || childrenString.isNotEmpty);

    return '${includeInitialTab ? tabs : ""}{\n$propertiesString${newLineA ? "\n" : ""}$childrenString${newLineB ? "\n" : ""}$nestedDefinitions$tabs}';
  }

  CVUDefinitionContent merge([CVUDefinitionContent? other]) {
    if (other == null) { return this; }
    var result = this;
    for (var definition in other.definitions) {
      int index = result.definitions.indexWhere((element) => element.selector == definition.selector);
      if (index > -1) {
        result.definitions[index] = result.definitions[index].merge(definition);
      } else {
        result.definitions.add(definition);
      }
    }
    for (var entry in other.properties.entries) {
      result.properties.putIfAbsent(entry.key, () {
        var lhs = result.properties[entry.key]?.getSubdefinition();
        var rhs = entry.value.getSubdefinition();
        if (lhs != null && rhs != null) {
          return CVUValueSubdefinition(lhs.merge(rhs));
        } else {
          return entry.value; // Prefer rhs properties
        }
      });
    }
    if (other.children.isNotEmpty) {
      result.children = other.children; // Override children if defined
    }

    return result;
  }
}

/// A swift representation of a CVU definition
class CVUParsedDefinition {
  CVUDefinitionType type = CVUDefinitionType.other;
  CVUDefinitionDomain domain = CVUDefinitionDomain.user;

  /// The original selector for this definition (optional)
  String? selector;

  /// The name of this definition (optional)
  String? name;

  /// The renderer for which this definition is valid (optional)
  String? renderer;

  CVUDefinitionContent parsed = CVUDefinitionContent();

  CVUParsedDefinition({
    this.type = CVUDefinitionType.other,
    this.domain = CVUDefinitionDomain.user,
    this.selector,
    this.renderer,
    this.name
  });

  get(propName) {
    return parsed.properties[propName];
  }
  set(String propName, value) {
    parsed.properties[propName] = value;
  }

  bool get selectorIsForList {
    return selector?.startsWith("[]") ?? false;
  }

  String get description {
    return toCVUString(0, "   ", true);
  }

  String toCVUString(int depth, String tab, bool includeInitialTab) {
    String tabs = tab * depth;
    String body = parsed.toCVUString(depth, tab, false);
    return '${includeInitialTab ? tabs : ""}${(selector!.isNotEmpty) ? selector! + " " : ""}${(renderer != null && renderer!.isNotEmpty) ? "> " + renderer! + " " : ""}$body';
  }

  CVUParsedDefinition merge(CVUParsedDefinition? other) {
    if (other == null) { return this; }
    var result = this;
    result.parsed = parsed.merge(other.parsed);
    return result;
  }
}
