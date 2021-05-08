import 'dart:math';

import 'package:flutter/material.dart';

class FlowStack<T> extends StatelessWidget {
  final List<T> data;
  final Point spacing;
  final WrapCrossAlignment alignment;

  final List<Widget> Function(T) content;

  FlowStack(
      {required this.data,
      spacing,
      this.alignment = WrapCrossAlignment.start,
      required this.content})
      : this.spacing = Point(0, 0);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 0,
      child: Stack(
        children: [
          ColoredBox(color: Colors.transparent),
          SizedBox(
            width: 250,
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: alignment,
              spacing: spacing.y.toDouble(),
              runSpacing: spacing.x.toDouble(),
              children: data.map((e) => content(e)).expand((element) => element).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
