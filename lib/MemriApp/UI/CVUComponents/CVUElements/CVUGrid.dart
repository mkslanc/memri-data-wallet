import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';

import '../CVUUINodeResolver.dart';
import 'CVUForEach.dart';

class CVUGrid extends StatelessWidget with StackWidget {
  final CVUUINodeResolver nodeResolver;
  late final List<ItemRecord> items;
  late final Axis axis;
  late final String emptyText;
  late final Point spacing;

  CVUGrid({required this.nodeResolver});

  init() async {
    items = await nodeResolver.propertyResolver.items("items");
    axis = await _axis;
    emptyText = await nodeResolver.propertyResolver.string("emptyResultText") ?? "No results";
    spacing = await nodeResolver.propertyResolver.spacing ?? Point(0, 0);
    //TODO: minColumnHeight, maxColumnHeight
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init(),
        builder: (BuildContext builder, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (items.isNotEmpty) {
              return initWidget();
            } else {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Spacer(),
                    Opacity(
                      opacity: 0.7,
                      child: Text(
                        emptyText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    Spacer()
                  ],
                ),
              );
            }
          }
          return Text("");
        });
  }

  @override
  Widget getWidget(List<Widget> children) {
    return GridView.count(
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      crossAxisCount: 2,
      scrollDirection: axis,
      mainAxisSpacing: spacing.x.toDouble(),
      crossAxisSpacing: spacing.y.toDouble(),
      children: children,
    );
  }

  Future<Axis> get _axis async {
    switch (await nodeResolver.propertyResolver.string("axis")) {
      case "vertical":
        return Axis.vertical;
      default:
        return Axis.horizontal;
    }
  }
}
