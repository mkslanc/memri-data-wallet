import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/UI/Components/Layout/FlowStack.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import '../CVUUINodeResolver.dart';

class CVUFlowStack extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;
  late final List<ItemRecord> content;
  late final Point spacing;

  CVUFlowStack({required this.nodeResolver});

  init() async {
    content = await _content;
    spacing = await nodeResolver.propertyResolver.spacing ?? Point(0, 0);
  }

  Future<List<ItemRecord>> get _content async {
    return nodeResolver.propertyResolver.items("list");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return FlowStack<ItemRecord>(
                data: content,
                spacing: spacing,
                content: (listItem) => nodeResolver.childrenInForEach(usingItem: listItem));
          }
          return Empty();
        });
  }
}
