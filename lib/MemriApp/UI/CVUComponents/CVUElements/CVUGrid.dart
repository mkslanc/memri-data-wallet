import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import '../CVUUINodeResolver.dart';
import 'CVUForEach.dart';

class CVUGrid extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUGrid({required this.nodeResolver});

  @override
  _CVUGridState createState() => _CVUGridState();
}

class _CVUGridState extends State<CVUGrid> with StackWidget {
  late final List<ItemRecord> items;

  late final Axis axis;

  late final String emptyText;

  late final Point spacing;

  late final Future _init;

  @override
  initState() {
    super.initState();
    nodeResolver = widget.nodeResolver;
    _init = init();
  }

  init() async {
    items = await widget.nodeResolver.propertyResolver.items("items");
    axis = await _axis;
    emptyText =
        await widget.nodeResolver.propertyResolver.string("emptyResultText") ?? "No results";
    spacing = await widget.nodeResolver.propertyResolver.spacing ?? Point(0, 0);
    //TODO: minColumnHeight, maxColumnHeight
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
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
          return Empty();
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
    switch (await widget.nodeResolver.propertyResolver.string("axis")) {
      case "vertical":
        return Axis.vertical;
      default:
        return Axis.horizontal;
    }
  }
}
