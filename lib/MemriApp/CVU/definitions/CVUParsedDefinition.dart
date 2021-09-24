//
// CVUParsedDefinition.swift
// Copyright © 2020 memri. All rights reserved.

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUStringConvertible.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/CVU/resolving/CVULookupController.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUPropertyResolver.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';

import 'CVUUINode.dart';
import 'CVUValue.dart';

import 'package:json_annotation/json_annotation.dart';

part 'CVUParsedDefinition.g.dart';

/// An enum describing the different types of definition in CVU.
/// These have different ways of being expressed in CVU eg. [renderer = ...], Text, .someViewName
enum CVUDefinitionType { view, views, uiNode, sessions, renderer, datasource, language, other }

enum CVUDefinitionDomain { user }

/// A struct holding the content of a CVUDefinition
/// Contains properties, children, and sub-definitions
@JsonSerializable()
class CVUDefinitionContent extends CVUStringConvertible with EquatableMixin {
  List<CVUParsedDefinition> definitions;
  List<CVUUINode> children;
  Map<String, CVUValue> properties;

  CVUDefinitionContent(
      {List<CVUParsedDefinition>? definitions,
      List<CVUUINode>? children,
      Map<String, CVUValue>? properties})
      : this.definitions = definitions ?? List<CVUParsedDefinition>.of([]),
        this.children = children ?? List<CVUUINode>.of([]),
        this.properties = properties ?? Map<String, CVUValue>();

  CVUDefinitionContent clone() {
    return CVUDefinitionContent(
      definitions:
          definitions.map((e) => CVUParsedDefinition.fromJson(jsonDecode(jsonEncode(e)))).toList(),
      children: children.map((e) => CVUUINode.fromJson(jsonDecode(jsonEncode(e)))).toList(),
      properties: Map<String, CVUValue>.from(properties),
    );
  }

  CVUPropertyResolver propertyResolver(
      {required CVUContext context,
      required CVULookupController lookup,
      required DatabaseController db}) {
    return CVUPropertyResolver(context: context, lookup: lookup, db: db, properties: properties);
  }

  String toCVUString(int depth, String tab, bool includeInitialTab) {
    String tabs = tab * depth;
    String propertiesString =
        properties.isEmpty ? "" : properties.toCVUString(depth + 1, tab, true);
    if (propertiesString.isNotEmpty) {
      propertiesString += "\n";
    }

    String childrenString = children.isEmpty
        ? ""
        : children.map((node) => node.toCVUString(depth + 1, tab, true)).join("\n");
    if (childrenString.isNotEmpty) {
      childrenString += "\n";
    }

    String nestedDefinitions = definitions.isEmpty
        ? ""
        : definitions.map((element) => element.toCVUString(depth + 1, tab, true)).join("\n\n");
    if (nestedDefinitions.isNotEmpty) {
      nestedDefinitions += "\n";
    }

    bool newLineA = propertiesString.isNotEmpty && childrenString.isNotEmpty;
    bool newLineB =
        nestedDefinitions.isNotEmpty && (propertiesString.isNotEmpty || childrenString.isNotEmpty);

    return '${includeInitialTab ? tabs : ""}{\n$propertiesString${newLineA ? "\n" : ""}$childrenString${newLineB ? "\n" : ""}$nestedDefinitions$tabs}';
  }

  CVUDefinitionContent merge([CVUDefinitionContent? other]) {
    if (other == null) {
      return this;
    }
    var result = clone();
    for (var definition in other.definitions) {
      int index =
          result.definitions.indexWhere((element) => element.selector == definition.selector);
      if (index > -1) {
        result.definitions[index] = result.definitions[index].merge(definition);
      } else {
        result.definitions.add(definition);
      }
    }
    var allProps = {};
    allProps.addAll(result.properties);
    allProps.addAll(other.properties);

    for (var entry in allProps.entries) {
      var lhs = result.properties[entry.key]?.getSubdefinition();
      var rhs = entry.value.getSubdefinition();
      if (lhs != null && rhs != null) {
        //TODO: need to check
        result.properties.update(entry.key, (value) => CVUValueSubdefinition(lhs.merge(rhs)));
      } else {
        // Prefer rhs properties
        if (result.properties.containsKey(entry.key)) {
          if (other.properties.containsKey(entry.key)) {
            result.properties.update(entry.key, (value) => (other.properties[entry.key])!);
          }
        } else {
          result.properties[entry.key] = entry.value;
        }
      }
    }

    if (other.children.isNotEmpty) {
      result.children = other.children; // Override children if defined
    }

    return result;
  }

  factory CVUDefinitionContent.fromJson(Map<String, dynamic> json) =>
      _$CVUDefinitionContentFromJson(json);

  Map<String, dynamic> toJson() => _$CVUDefinitionContentToJson(this);

  @override
  List<Object?> get props => [definitions, children, properties];
}

/// A swift representation of a CVU definition
@JsonSerializable()
class CVUParsedDefinition extends CVUStringConvertible with EquatableMixin {
  CVUDefinitionType type = CVUDefinitionType.other;
  CVUDefinitionDomain domain = CVUDefinitionDomain.user;

  /// The original selector for this definition (optional)
  String? selector;

  /// The name of this definition (optional)
  String? name;

  /// The renderer for which this definition is valid (optional)
  String? renderer;

  CVUDefinitionContent parsed;

  CVUParsedDefinition(
      {this.type = CVUDefinitionType.other,
      this.domain = CVUDefinitionDomain.user,
      this.selector,
      this.renderer,
      this.name,
      CVUDefinitionContent? parsed})
      : this.parsed = parsed ?? CVUDefinitionContent();

  CVUParsedDefinition clone() {
    //TODO find better way to clone object
    return CVUParsedDefinition(
        type: type,
        domain: domain,
        selector: selector,
        renderer: renderer,
        name: name,
        parsed: parsed);
  }

  CVUValue? get(propName) {
    return parsed.properties[propName];
  }

  set(String propName, CVUValue value) {
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
    return '${includeInitialTab ? tabs : ""}${(selector != null && selector!.isNotEmpty) ? selector! + " " : ""}${(renderer != null && renderer!.isNotEmpty) ? "> " + renderer! + " " : ""}$body';
  }

  CVUParsedDefinition merge(CVUParsedDefinition? other) {
    if (other == null) {
      return this;
    }
    var result = clone();
    result.parsed = parsed.merge(other.parsed);
    return result;
  }

  factory CVUParsedDefinition.fromJson(Map<String, dynamic> json) =>
      _$CVUParsedDefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$CVUParsedDefinitionToJson(this);

  @override
  List<Object?> get props => [type, domain, selector, name, renderer, parsed];
}
