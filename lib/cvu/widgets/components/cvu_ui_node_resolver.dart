//  Created by T Brennan on 7/1/21.

import 'package:flutter/cupertino.dart';
import 'package:memri/cvu/controllers/cvu_lookup_controller.dart';
import 'package:memri/core/controllers/database_controller.dart';
import 'package:memri/cvu/models/cvu_ui_element_family.dart';
import 'package:memri/cvu/models/cvu_ui_node.dart';
import 'package:memri/cvu/models/cvu_value.dart';
import 'package:memri/core/models/database/item_record.dart';
import 'package:memri/cvu/services/resolving/cvu_property_resolver.dart';
import 'package:memri/cvu/widgets/components/cvu_element_view.dart';

import '../../services/resolving/cvu_context.dart';

/// This struct allows for a CVU node to be queried for the value of its properties.
class CVUUINodeResolver {
  CVUContext context;
  CVULookupController lookup;
  CVUUINode node;

  DatabaseController db;

  CVUUINodeResolver(
      {required this.context,
      required this.lookup,
      required this.node,
      required this.db});

  Widget childrenInForEachWithWrap({centered = false, ItemRecord? usingItem}) {
    return Wrap(
      children: childrenInForEach(usingItem: usingItem),
      alignment: centered ? WrapAlignment.center : WrapAlignment.start,
      runAlignment: centered ? WrapAlignment.center : WrapAlignment.start,
      crossAxisAlignment:
          centered ? WrapCrossAlignment.center : WrapCrossAlignment.start,
    );
  }

  List<Widget> childrenInForEach(
      {Map<String, dynamic>? additionalParams, ItemRecord? usingItem}) {
    var newContext =
        usingItem != null ? context.replacingItem(usingItem) : context.clone();
    var nodeChildren = node.children.asMap();

    return nodeChildren
        .map((index, child) {
          Widget widget = CVUElementView(
            nodeResolver: copyForNode(child, newContext),
            additionalParams: additionalParams,
          );
          if ((child.shouldExpandWidth &&
                  node.type == CVUUIElementFamily.HStack) ||
              (child.shouldExpandHeight &&
                  node.type == CVUUIElementFamily.VStack)) {
            widget = Expanded(child: widget);
          }
          if (child.type == CVUUIElementFamily.Spacer &&
              node.type == CVUUIElementFamily.HStack) {
            if (nodeChildren[index + 1]?.type == CVUUIElementFamily.Text ||
                nodeChildren[index - 1]?.type == CVUUIElementFamily.Text) {
              return MapEntry(index, null);
            }
          }
          if (node.type == CVUUIElementFamily.HStack) {
            if (child.type == CVUUIElementFamily.Text) {
              if (nodeChildren[index + 1]?.type == CVUUIElementFamily.Spacer ||
                  (nodeChildren[index - 1]?.type == CVUUIElementFamily.Spacer &&
                      nodeChildren[index - 2]?.type ==
                          CVUUIElementFamily.Text)) {
                if (nodeChildren[index - 1]?.type ==
                    CVUUIElementFamily.Spacer) {
                  widget = Align(
                      alignment: nodeChildren[index + 1]?.type ==
                              CVUUIElementFamily.Spacer
                          ? Alignment.center
                          : Alignment.centerRight,
                      child: widget);
                }
                widget = Expanded(child: widget);
              } else {
                widget = Flexible(
                  child: widget,
                  flex: 5,
                );
              }
            } else if (child.properties.containsKey("cols") &&
                child.properties["cols"] is CVUValueConstant) {
              widget = Flexible(
                child: widget,
                flex: (child.properties["cols"] as CVUValueConstant)
                        .value
                        .asInt() ??
                    1,
              );
            }
          }
          return MapEntry(index, widget);
        })
        .values
        .whereType<Widget>()
        .toList();
  }

  Widget? firstChild() {
    if (node.children.isNotEmpty) {
      var child = node.children.first;
      return CVUElementView(
        nodeResolver: copyForNode(child),
      );
    }
    return null;
  }

  CVUUINode? firstTextNode([List<CVUUINode>? children]) {
    children ??= node.children;
    if (children.isNotEmpty) {
      for (var childNode in children) {
        if (childNode.type == CVUUIElementFamily.Text) {
          return childNode;
        } else {
          var foundNode = firstTextNode(childNode.children);
          if (foundNode != null) {
            return foundNode;
          }
        }
      }
    }
    return null;
  }

  CVUUINodeResolver copyForNode(CVUUINode newNode, [CVUContext? newContext]) {
    return CVUUINodeResolver(
        context: newContext ?? context, lookup: lookup, node: newNode, db: db);
  }

  CVUPropertyResolver get propertyResolver {
    return CVUPropertyResolver(
        context: context, lookup: lookup, db: db, properties: node.properties);
  }
}
