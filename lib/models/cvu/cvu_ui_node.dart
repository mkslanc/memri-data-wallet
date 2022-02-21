// Copyright © 2020 memri. All rights reserved.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:memri/core/cvu/parsing/cvu_string_convertible.dart';
import 'package:memri/models/cvu/cvu_lexer.dart';
import 'package:memri/models/cvu/cvu_ui_element_family.dart';
import 'package:memri/models/cvu/cvu_value.dart';
import 'package:uuid/uuid.dart';

part 'cvu_ui_node.g.dart';

/// This represents a CVU definition of how to show a data item. It can contain properties (eg. onPress action), and children (eg. UI elements to show)
@JsonSerializable()
class CVUUINode extends CVUStringConvertible with EquatableMixin {
  final CVUUIElementFamily type;
  List<CVUUINode> children = [];
  Map<String, CVUValue> properties = {};
  CVUTokenLocation? tokenLocation;

  bool shouldExpandWidth =
      false; //TODO maybe there is a better way to handle flutter layout constraints and expands?
  bool shouldExpandHeight = false;

  String id = Uuid().v4();

  CVUUINode(
      {required this.type, required this.children, required this.properties, this.tokenLocation}) {
    children.forEach((element) {
      if (element.shouldExpandWidth ||
          ((element.type == CVUUIElementFamily.Spacer || element.type == CVUUIElementFamily.Text) &&
              type == CVUUIElementFamily.HStack)) {
        shouldExpandWidth = true;
      }
      if (element.shouldExpandHeight ||
          ((element.type == CVUUIElementFamily.Spacer ||
                  element.type == CVUUIElementFamily.SubView) &&
              type == CVUUIElementFamily.VStack)) {
        shouldExpandHeight = true;
      }
    });

    if (type == CVUUIElementFamily.FlowStack || type == CVUUIElementFamily.Textfield) {
      shouldExpandWidth = true;
    }
  }

  String toCVUString(int depth, String tab, bool includeInitialTab) {
    String tabs = tab * depth;

    if (properties.isEmpty && children.isEmpty) {
      return '${includeInitialTab ? tabs : ""}${type.inString}';
    }

    String propertiesString =
        properties.isEmpty ? "" : properties.toCVUString(depth + 1, tab, true);
    if (propertiesString.isNotEmpty) {
      propertiesString += "\n";
    }

    String childrenString = children.isEmpty
        ? ""
        : children.map((node) => node.toCVUString(depth + 1, tab, true)).join("\n\n");
    if (childrenString.isNotEmpty) {
      childrenString += "\n";
    }

    bool includeNewLineBetweenPropertiesAndChildren =
        propertiesString.isNotEmpty && childrenString.isNotEmpty;

    return '${includeInitialTab ? tabs : ""}${type.inString} {\n$propertiesString${includeNewLineBetweenPropertiesAndChildren ? "\n" : ""}$childrenString$tabs}';
  }

  String get description {
    return toCVUString(0, "    ", true);
  }

  factory CVUUINode.fromJson(Map<String, dynamic> json) => _$CVUUINodeFromJson(json);

  Map<String, dynamic> toJson() => _$CVUUINodeToJson(this);

  @override
  List<Object?> get props => [type, children, properties];
}
