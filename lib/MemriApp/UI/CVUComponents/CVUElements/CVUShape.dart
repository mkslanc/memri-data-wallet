import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';

import '../CVUUINodeResolver.dart';

/// A CVU element for displaying a circle
class CVUShapeCircle extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;
  late final Color color;

  CVUShapeCircle({required this.nodeResolver});

  init() async {
    color = await nodeResolver.propertyResolver.color() ?? CVUColor.system("clear");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init(),
        builder: (BuildContext builder, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            );
          }
          return Text("");
        });
  }
}

/// A CVU element for displaying a rectangle
class CVUShapeRectangle extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;

  late final double cornerRadius;
  late final Color color;

  CVUShapeRectangle({required this.nodeResolver});

  init() async {
    cornerRadius = await nodeResolver.propertyResolver.cornerRadius;
    color = await nodeResolver.propertyResolver.color() ?? CVUColor.system("clear");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init(),
        builder: (BuildContext builder, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                //borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
                color: color,
              ),
            );
          }
          return Text("");
        });
  }
}
