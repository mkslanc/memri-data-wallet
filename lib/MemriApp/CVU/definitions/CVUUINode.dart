//
// UINode.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:memri/MemriApp/CVU/parsing/CVUStringConvertible.dart';
import 'package:uuid/uuid.dart';

import 'CVUUIElementFamily.dart';
import 'CVUValue.dart';

/// This represents a CVU definition of how to show a data item. It can contain properties (eg. onPress action), and children (eg. UI elements to show)
class CVUUINode extends CVUStringConvertible {
  final CVUUIElementFamily type;
  List<CVUUINode> children = [];
  Map<String, CVUValue> properties = {};

  var id = Uuid();

  CVUUINode(
      {required this.type, required this.children, required this.properties});

  String toCVUString(int depth, String tab, bool includeInitialTab) {
    String tabs = tab * depth;

    if (properties.isEmpty && children.isEmpty) {
      return '${includeInitialTab ? tabs : ""}${type.inString}';
    }

    String propertiesString = properties.isEmpty ? "" : properties.toCVUString(depth + 1, tab, true);
    if (propertiesString.isNotEmpty) {propertiesString += "\n";}

    String childrenString = children.isEmpty ? "" : children.map((node) =>
      node.toCVUString(depth + 1, tab, true)
    ).join("\n\n");
    if (childrenString.isNotEmpty) {childrenString += "\n";}

    bool includeNewLineBetweenPropertiesAndChildren = propertiesString.isNotEmpty && childrenString.isNotEmpty;

    return '${includeInitialTab ? tabs : ""}${type.inString} {\n$propertiesString${includeNewLineBetweenPropertiesAndChildren ? "\n" : ""}$childrenString$tabs}';
  }

  String get description {
    return toCVUString(0, "    ", true);
  }
}
