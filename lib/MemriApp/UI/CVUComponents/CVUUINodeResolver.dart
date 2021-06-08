//
//  CVUUINodeResolver.swift
//  MemriDatabase
//
//  Created by T Brennan on 7/1/21.
//

import 'package:flutter/cupertino.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUUIElementFamily.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUUINode.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/CVU/resolving/CVULookupController.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUPropertyResolver.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';

import 'CVUElementView.dart';

/// This struct allows for a CVU node to be queried for the value of its properties.
class CVUUINodeResolver {
  CVUContext context;
  CVULookupController lookup;
  CVUUINode node;

  DatabaseController db;

  CVUUINodeResolver(
      {required this.context, required this.lookup, required this.node, required this.db});

  Widget childrenInForEachWithWrap() {
    return Wrap(children: childrenInForEach());
  }

  List<Widget> childrenInForEach({Map<String, dynamic>? additionalParams, ItemRecord? usingItem}) {
    var newContext = usingItem != null ? context.replacingItem(usingItem) : context;
    var nodeChildren = node.children.asMap();

    return nodeChildren
        .map((index, child) {
          Widget widget = CVUElementView(
            nodeResolver:
                CVUUINodeResolver(context: newContext, lookup: lookup, node: child, db: db),
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
        nodeResolver: CVUUINodeResolver(context: context, lookup: lookup, node: child, db: db),
      );
    }
  }

  CVUPropertyResolver get propertyResolver {
    return CVUPropertyResolver(
        context: context, lookup: lookup, db: db, properties: node.properties);
  }
}
