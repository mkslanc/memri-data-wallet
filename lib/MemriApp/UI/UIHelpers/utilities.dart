import 'package:flutter/material.dart';

List<Widget> space(double gap, Iterable<Widget> children) => children
    .expand((item) sync* {
      yield SizedBox(width: gap);
      yield item;
    })
    .skip(1)
    .toList();
