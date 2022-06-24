import 'package:flutter/material.dart';

List<Widget> space(double gap, Iterable<Widget> children,
        [Axis axis = Axis.horizontal]) =>
    children
        .expand((item) sync* {
          yield SizedBox(
              width: axis == Axis.horizontal ? gap : null,
              height: axis == Axis.vertical ? gap : null);

          yield item;
        })
        .skip(1)
        .toList();
