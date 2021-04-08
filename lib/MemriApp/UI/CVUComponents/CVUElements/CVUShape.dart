import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';

import '../CVUUINodeResolver.dart';

/// A CVU element for displaying a circle
class CVUShapeCircle extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;

  CVUShapeCircle({required this.nodeResolver});

  /*var body: some View {
            SwiftUI.Circle().fill(nodeResolver.propertyResolver.color()?.color ?? .clear)
        }*/

  @override
  Widget build(BuildContext context) {
    //TODO
    return Text("Place for circle");
  }
}

/// A CVU element for displaying a rectangle
class CVUShapeRectangle extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;

  CVUShapeRectangle({required this.nodeResolver});

  late final double cornerRadius;
  late final Color color;

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
