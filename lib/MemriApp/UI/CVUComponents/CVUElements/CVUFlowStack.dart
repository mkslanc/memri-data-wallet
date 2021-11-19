import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/UI/Components/Layout/FlowStack.dart';

import '../CVUUINodeResolver.dart';

class CVUFlowStack extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUFlowStack({required this.nodeResolver});

  @override
  _CVUFlowStackState createState() => _CVUFlowStackState();
}

class _CVUFlowStackState extends State<CVUFlowStack> {
  List<ItemRecord> content = [];

  Point spacing = Point(0, 0);

  late Future _init;

  @override
  initState() {
    super.initState();
    _init = init();
  }

  init() async {
    content = await _content;
    spacing = await widget.nodeResolver.propertyResolver.spacing ?? Point(0, 0);
  }

  @override
  void didUpdateWidget(oldWidget) {
    _init = init();
    super.didUpdateWidget(oldWidget);
  }

  Future<List<ItemRecord>> get _content async {
    return widget.nodeResolver.propertyResolver.items("list");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return FlowStack<ItemRecord>(
              data: content,
              spacing: spacing,
              content: (listItem) => widget.nodeResolver.childrenInForEach(usingItem: listItem));
        });
  }
}
