import 'dart:math';

import 'package:flutter/material.dart';

class FlowStack<T> extends StatelessWidget {
  final List<T> data;
  final Point spacing;
  final WrapCrossAlignment alignment;
  final Axis direction;

  final List<Widget> Function(T) content;

  FlowStack(
      {required this.data,
      spacing,
      this.alignment = WrapCrossAlignment.start,
      this.direction = Axis.horizontal,
      required this.content})
      : this.spacing = spacing ?? Point(0, 0);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Stack(
        children: [
          ColoredBox(color: Colors.transparent),
          Wrap(
            direction: direction,
            alignment: WrapAlignment.center,
            crossAxisAlignment: alignment,
            spacing: spacing.y.toDouble(),
            runSpacing: spacing.x.toDouble(),
            children: data.map((e) => content(e)).expand((element) => element).toList(),
          ),
        ],
      ),
    );
  }
}
