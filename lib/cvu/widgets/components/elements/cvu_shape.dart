import 'package:flutter/material.dart';
import 'package:memri/cvu/constants/cvu_color.dart';
import 'package:memri/cvu/widgets/components/cvu_ui_node_resolver.dart';
import 'package:memri/widgets/components/shapes/circle.dart';

/// A CVU element for displaying a circle
class CVUShapeCircle extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUShapeCircle({required this.nodeResolver});

  @override
  _CVUShapeCircleState createState() => _CVUShapeCircleState();
}

class _CVUShapeCircleState extends State<CVUShapeCircle> {
  late Color color;

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
    color = widget.nodeResolver.propertyResolver.color() ??
        CVUColor.system("clear");
  }

  @override
  Widget build(BuildContext context) {
    return Circle(color: color);
  }
}

/// A CVU element for displaying a rectangle
class CVUShapeRectangle extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUShapeRectangle({required this.nodeResolver});

  @override
  _CVUShapeRectangleState createState() => _CVUShapeRectangleState();
}

class _CVUShapeRectangleState extends State<CVUShapeRectangle> {
  late double cornerRadius;

  late Color color;

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
    cornerRadius = widget.nodeResolver.propertyResolver.cornerRadius;
    color = widget.nodeResolver.propertyResolver.color() ??
        CVUColor.system("clear");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
        color: color,
      ),
    );
  }
}
