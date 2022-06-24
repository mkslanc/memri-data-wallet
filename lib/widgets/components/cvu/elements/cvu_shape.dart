import 'package:flutter/material.dart';
import 'package:memri/constants/cvu/cvu_color.dart';
import 'package:memri/widgets/components/cvu/cvu_ui_node_resolver.dart';
import 'package:memri/widgets/components/shapes/circle.dart';
import 'package:memri/widgets/empty.dart';

/// A CVU element for displaying a circle
class CVUShapeCircle extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUShapeCircle({required this.nodeResolver});

  @override
  _CVUShapeCircleState createState() => _CVUShapeCircleState();
}

class _CVUShapeCircleState extends State<CVUShapeCircle> {
  late final Color color;

  late final Future _init;

  @override
  initState() {
    super.initState();
    _init = init();
  }

  init() async {
    color = await widget.nodeResolver.propertyResolver.color() ??
        CVUColor.system("clear");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext builder, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Circle(color: color);
          }
          return Empty();
        });
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
  late final double cornerRadius;

  late final Color color;

  late final Future _init;

  @override
  initState() {
    super.initState();
    _init = init();
  }

  init() async {
    cornerRadius = await widget.nodeResolver.propertyResolver.cornerRadius;
    color = await widget.nodeResolver.propertyResolver.color() ??
        CVUColor.system("clear");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext builder, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
                color: color,
              ),
            );
          }
          return Empty();
        });
  }
}
