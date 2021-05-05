import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/UI/Components/Layout/FlowStack.dart';

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
        builder: (BuildContext context, AsyncSnapshot<List<ItemRecord>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return FlowStack(
                  data: snapshot.data!,
                  spacing: spacing,
                  content: (listItem) => nodeResolver.childrenInForEachUsingItem(listItem));
            }
          }
          return Text("");
        });
  }

/*
  var body: some View {
        FlowStack(
            data: self.content,
            spacing: self.nodeResolver.propertyResolver.spacing ?? CGPoint.zero
        ) { listItem in
            return nodeResolver.childrenInForEach(usingItem: listItem)
        }
    }
   */

}
