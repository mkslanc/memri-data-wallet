import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/core/models/item.dart';
import 'package:memri/cvu/widgets/components/cvu_ui_node_resolver.dart';
import 'package:memri/widgets/components/layout/flow_stack.dart';

class CVUFlowStack extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUFlowStack({required this.nodeResolver});

  @override
  _CVUFlowStackState createState() => _CVUFlowStackState();
}

class _CVUFlowStackState extends State<CVUFlowStack> {
  List<Item> content = [];

  Point spacing = Point(0, 0);

  Axis direction = Axis.horizontal;

  @override
  initState() {
    super.initState();
    init();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() => init());
  }

  void init() {
    content = _content;
    spacing = widget.nodeResolver.propertyResolver.spacing ?? Point(0, 0);
    direction = _direction;
  }

  Axis get _direction {
    switch (widget.nodeResolver.propertyResolver.string("axis")) {
      case "vertical":
        return Axis.vertical;
      default:
        return Axis.horizontal;
    }
  }

  List<Item> get _content {
    return widget.nodeResolver.propertyResolver.items("list");
  }

  @override
  Widget build(BuildContext context) {
    return FlowStack<Item>(
        direction: direction,
        data: content,
        spacing: spacing,
        content: (listItem) =>
            widget.nodeResolver.childrenInForEach(usingItem: listItem));
  }
}
