import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/core/models/item.dart';
import 'package:memri/cvu/widgets/components/cvu_ui_node_resolver.dart';
import 'package:memri/cvu/widgets/components/elements/cvu_for_each.dart';

class CVUGrid extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUGrid({required this.nodeResolver});

  @override
  _CVUGridState createState() => _CVUGridState();
}

class _CVUGridState extends State<CVUGrid> with StackWidget {
  late List<Item> items;

  late Axis axis;

  late String emptyText;

  late Point spacing;

  @override
  initState() {
    super.initState();
    nodeResolver = widget.nodeResolver;
    init();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() => init());
  }

  void init() {
    items = widget.nodeResolver.propertyResolver.items("items");
    axis = _axis;
    emptyText =
        widget.nodeResolver.propertyResolver.string("emptyResultText") ??
            "No results";
    spacing = widget.nodeResolver.propertyResolver.spacing ?? Point(0, 0);
    //TODO: minColumnHeight, maxColumnHeight
  }

  @override
  Widget build(BuildContext context) {
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

  @override
  Widget getWidget(List<Widget> children) {
    return GridView.count(
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      crossAxisCount: axis == Axis.horizontal ? 2 : 3,
      //TODO calculate from height/width?
      scrollDirection: axis,
      mainAxisSpacing: spacing.x.toDouble(),
      crossAxisSpacing: spacing.y.toDouble(),
      children: children,
    );
  }

  Axis get _axis {
    switch (widget.nodeResolver.propertyResolver.string("axis")) {
      case "vertical":
        return Axis.vertical;
      default:
        return Axis.horizontal;
    }
  }
}
