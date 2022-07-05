import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/cvu/widgets/components/cvu_ui_node_resolver.dart';
import 'package:memri/widgets/space.dart';

import '../../../services/resolving/cvu_property_resolver.dart';

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

  @override
  initState() {
    super.initState();
    init();
  }

  @override
  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() => init());
  }

  void init() {
    alignment = widget.nodeResolver.propertyResolver.alignment("row");
    spacing = widget.nodeResolver.propertyResolver.spacing;
    fillWidth =
        (widget.nodeResolver.propertyResolver.boolean("fillWidth", false))!;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment?.mainAxis ?? MainAxisAlignment.start,
      crossAxisAlignment: alignment?.crossAxis ?? CrossAxisAlignment.center,
      children: space(spacing?.x.toDouble() ?? 10 /*TODO default spacing*/,
          widget.nodeResolver.childrenInForEach()),
    );
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

  @override
  initState() {
    super.initState();
    init();
  }

  @override
  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() => init());
  }

  void init() {
    alignment = widget.nodeResolver.propertyResolver.alignment("column");
    spacing = widget.nodeResolver.propertyResolver.spacing;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: alignment?.mainAxis ?? MainAxisAlignment.start,
      crossAxisAlignment: alignment?.crossAxis ?? CrossAxisAlignment.center,
      children: space(spacing?.y.toDouble() ?? 10,
          widget.nodeResolver.childrenInForEach(), Axis.vertical),
    );
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

  @override
  initState() {
    super.initState();
    init();
  }

  @override
  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() => init());
  }

  void init() {
    spacing = widget.nodeResolver.propertyResolver.spacing;
    alignment =
        widget.nodeResolver.propertyResolver.alignmentForStack("alignment");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: alignment ?? Alignment.center,
      children: widget.nodeResolver.childrenInForEach(),
    );
  }
}

class CVUWrap extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUWrap({required this.nodeResolver});

  @override
  _CVUWrapState createState() => _CVUWrapState();
}

class _CVUWrapState extends State<CVUWrap> {
  Point? spacing;

  @override
  initState() {
    super.initState();
    init();
  }

  @override
  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() => init());
  }

  void init() {
    spacing = widget.nodeResolver.propertyResolver.spacing;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing?.x.toDouble() ?? 0,
      runSpacing: spacing?.y.toDouble() ?? 0,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: widget.nodeResolver.childrenInForEach(),
    );
  }
}
