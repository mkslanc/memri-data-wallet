import 'package:flutter/material.dart';

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

  /*var body: some View {
            SwiftUI.RoundedRectangle(cornerRadius: nodeResolver.propertyResolver.cornerRadius())
                .fill(nodeResolver.propertyResolver.color()?.color ?? .clear)
        }*/
  @override
  Widget build(BuildContext context) {
    //TODO
    return Text("Place for RoundedRectangle");
  }
}
