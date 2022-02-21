//  Created by T Brennan on 7/1/21.

import 'package:flutter/cupertino.dart';
import 'package:memri/controllers/cvu_lookup_controller.dart';
import 'package:memri/controllers/database_controller.dart';
import 'package:memri/controllers/page_controller.dart' as memri;
import 'package:memri/core/cvu/resolving/cvu_context.dart';
import 'package:memri/core/cvu/resolving/cvu_property_resolver.dart';
import 'package:memri/models/cvu/cvu_ui_element_family.dart';
import 'package:memri/models/cvu/cvu_ui_node.dart';
import 'package:memri/models/database/item_record.dart';
import 'package:memri/widgets/components/cvu/cvu_element_view.dart';

/// This struct allows for a CVU node to be queried for the value of its properties.
class CVUUINodeResolver {
  CVUContext context;
  CVULookupController lookup;
  CVUUINode node;
  memri.PageController pageController;

  DatabaseController db;

  CVUUINodeResolver(
      {required this.context,
      required this.lookup,
      required this.node,
      required this.db,
      required this.pageController});

  Widget childrenInForEachWithWrap({centered = false, ItemRecord? usingItem}) {
    return Wrap(
      children: childrenInForEach(usingItem: usingItem),
      alignment: centered ? WrapAlignment.center : WrapAlignment.start,
      runAlignment: centered ? WrapAlignment.center : WrapAlignment.start,
      crossAxisAlignment: centered ? WrapCrossAlignment.center : WrapCrossAlignment.start,
    );
  }

  List<Widget> childrenInForEach({Map<String, dynamic>? additionalParams, ItemRecord? usingItem}) {
    var newContext = usingItem != null ? context.replacingItem(usingItem) : context.clone();
    var nodeChildren = node.children.asMap();

    return nodeChildren
        .map((index, child) {
          Widget widget = CVUElementView(
            nodeResolver: CVUUINodeResolver(
                context: newContext,
                lookup: lookup,
                node: child,
                db: db,
                pageController: pageController),
            additionalParams: additionalParams,
          );
          if ((child.shouldExpandWidth && node.type == CVUUIElementFamily.HStack) ||
              (child.shouldExpandHeight && node.type == CVUUIElementFamily.VStack)) {
            widget = Expanded(child: widget);
          }
          if (child.type == CVUUIElementFamily.Spacer) {
            if (nodeChildren[index + 1]?.type == CVUUIElementFamily.Text ||
                nodeChildren[index - 1]?.type == CVUUIElementFamily.Text) {
              return MapEntry(index, null);
            }
          }
          if (child.type == CVUUIElementFamily.Text && node.type == CVUUIElementFamily.HStack) {
            if (nodeChildren[index + 1]?.type == CVUUIElementFamily.Spacer ||
                (nodeChildren[index - 1]?.type == CVUUIElementFamily.Spacer &&
                    nodeChildren[index - 2]?.type == CVUUIElementFamily.Text)) {
              if (nodeChildren[index - 1]?.type == CVUUIElementFamily.Spacer) {
                widget = Align(
                    alignment: nodeChildren[index + 1]?.type == CVUUIElementFamily.Spacer
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
        nodeResolver: CVUUINodeResolver(
            context: context, lookup: lookup, node: child, db: db, pageController: pageController),
      );
    }
    return null;
  }

  CVUPropertyResolver get propertyResolver {
    return CVUPropertyResolver(
        context: context, lookup: lookup, db: db, properties: node.properties);
  }
}
