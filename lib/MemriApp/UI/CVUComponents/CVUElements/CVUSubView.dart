import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';
import 'package:memri/MemriApp/UI/Components/Layout/FlowStack.dart';
import '../CVUUINodeResolver.dart';

class CVUSubView extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;
  late final List<ItemRecord>? items;
  late final String? content;
  late final Point spacing;

  CVUSubView({required this.nodeResolver, this.items, this.content});

  init() async {
    items = await nodeResolver.propertyResolver.items("query");
    content = await _content;
    /* CVUValue? def = nodeResolver.propertyResolver
        .value("view")
        ?.getSubdefinition()
        ?.definitions
        .compactMap((el) => el.parsed.properties["query"])
        .first;*/
    /*List<ItemRecord> res = await nodeResolver.lookup.resolve<List>(
        value: def!, context: nodeResolver.context, db: nodeResolver.db) as List<ItemRecord>;
    var defp = nodeResolver.propertyResolver.value("view")?.getSubdefinition();*/ //TODO:
    spacing = await nodeResolver.propertyResolver.spacing ?? Point(0, 0);
  }

  Future<String?> get _content async {
    return (await nodeResolver.propertyResolver.string("text"))?.nullIfBlank;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return FlowStack(
                  data: [nodeResolver.context.currentItem].compactMap((el) => el != null),
                  spacing: spacing,
                  content: (listItem) => [nodeResolver.firstChild()!]); //TODO:
            }
          }
          return Text("");
        });
  }
}
