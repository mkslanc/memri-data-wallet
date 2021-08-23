import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUPropertyResolver.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import '../CVUUINodeResolver.dart';

/// A CVU element for displaying multiple children in a Horizontal Stack
/// - set the `alignment` property to `top`, `center`, or `bottom`
/// - set the `fillWidth` property to `true` if the stack should fill all available width

class CVUHStack extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUHStack({required this.nodeResolver});

  @override
  _CVUHStackState createState() => _CVUHStackState();
}

class _CVUHStackState extends State<CVUHStack> {
  AlignmentResolver? alignment;

  Point? spacing;

  bool fillWidth = false;

  late Future _init;

  @override
  initState() {
    super.initState();
    _init = init();
  }

  init() async {
    alignment = await widget.nodeResolver.propertyResolver.alignment("row");
    spacing = await widget.nodeResolver.propertyResolver.spacing;
    fillWidth = (await widget.nodeResolver.propertyResolver.boolean("fillWidth", false))!;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext builder, snapshot) {
          return Row(
            mainAxisAlignment: alignment?.mainAxis ?? MainAxisAlignment.start,
            crossAxisAlignment: alignment?.crossAxis ?? CrossAxisAlignment.center,
            children: space(spacing?.x.toDouble() ?? 10 /*TODO default spacing*/,
                widget.nodeResolver.childrenInForEach()),
          );
          /* TODO:
        .if(nodeResolver.propertyResolver.bool("fillWidth", defaultValue: false)) {
            $0.frame(maxWidth: .infinity, alignment: nodeResolver.propertyResolver.alignment())
        }
    }*/
        });
  }
}

/// A CVU element for displaying multiple children in a Vertical Stack
/// - set the `alignment` property to `leading`, `center`, or `trailing`
/// - set the `fillHeight` property to `true` if the stack should fill all available height
class CVUVStack extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUVStack({required this.nodeResolver});

  @override
  _CVUVStackState createState() => _CVUVStackState();
}

class _CVUVStackState extends State<CVUVStack> {
  AlignmentResolver? alignment;

  Point? spacing;

  late Future _init;

  @override
  initState() {
    super.initState();
    _init = init();
  }

  init() async {
    alignment = await widget.nodeResolver.propertyResolver.alignment("column");
    spacing = await widget.nodeResolver.propertyResolver.spacing;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext builder, snapshot) {
          return Column(
            mainAxisAlignment: alignment?.mainAxis ?? MainAxisAlignment.start,
            crossAxisAlignment: alignment?.crossAxis ?? CrossAxisAlignment.center,
            children: space(spacing?.y.toDouble() ?? 10, widget.nodeResolver.childrenInForEach(),
                Axis.vertical),
          );
          /* TODO:
        .if(nodeResolver.propertyResolver.bool("fillHeight", defaultValue: false)) {
            $0.frame(maxHeight: .infinity, alignment: nodeResolver.propertyResolver.alignment())
        }
    }*/
        });
  }
}

/// A CVU element for displaying multiple children overlayed on each-other
/// - set the `alignment` property to align to any corner, edge, or center
class CVUZStack extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUZStack({required this.nodeResolver});

  @override
  _CVUZStackState createState() => _CVUZStackState();
}

class _CVUZStackState extends State<CVUZStack> {
  Point? spacing;

  Alignment? alignment;

  late Future _init;

  @override
  initState() {
    super.initState();
    _init = init();
  }

  init() async {
    spacing = await widget.nodeResolver.propertyResolver.spacing;
    alignment = await widget.nodeResolver.propertyResolver.alignmentForStack("alignment");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext builder, snapshot) {
          return Stack(
            alignment: alignment ?? Alignment.center,
            children: widget.nodeResolver.childrenInForEach(),
          );
        });
  }
}
