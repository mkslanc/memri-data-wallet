import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUPropertyResolver.dart';

import '../CVUUINodeResolver.dart';

List<Widget> space(double gap, Iterable<Widget> children) =>
    children //TODO: move to utilities and use in static views
        .expand((item) sync* {
          yield SizedBox(width: gap);
          yield item;
        })
        .skip(1)
        .toList();

/// A CVU element for displaying multiple children in a Horizontal Stack
/// - set the `alignment` property to `top`, `center`, or `bottom`
/// - set the `fillWidth` property to `true` if the stack should fill all available width

class CVUHStack extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;
  late final AlignmentResolver alignment;
  late final Point? spacing;

  CVUHStack({required this.nodeResolver});

  init(String alignType) async {
    alignment = await nodeResolver.propertyResolver.alignment(alignType);
    spacing = await nodeResolver.propertyResolver.spacing;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init("row"),
        builder: (BuildContext builder, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done: //TODO: spacing
              return Row(
                mainAxisAlignment: alignment.mainAxis,
                crossAxisAlignment: alignment.crossAxis,
                children: space(spacing?.x.toDouble() ?? 0,
                    nodeResolver.childrenInForEach()),
              );
            /* TODO:
        .if(nodeResolver.propertyResolver.bool("fillWidth", defaultValue: false)) {
            $0.frame(maxWidth: .infinity, alignment: nodeResolver.propertyResolver.alignment())
        }
    }*/
            default:
              return SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              );
          }
        });
  }
}

/// A CVU element for displaying multiple children in a Vertical Stack
/// - set the `alignment` property to `leading`, `center`, or `trailing`
/// - set the `fillHeight` property to `true` if the stack should fill all available height
class CVUVStack extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;
  late final AlignmentResolver alignment;
  late final Point? spacing;

  CVUVStack({required this.nodeResolver});

  init(String alignType) async {
    alignment = await nodeResolver.propertyResolver.alignment(alignType);
    spacing = await nodeResolver.propertyResolver.spacing;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init("column"),
        builder: (BuildContext builder, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done: //TODO: spacing
              return Column(
                mainAxisAlignment: alignment.mainAxis,
                crossAxisAlignment: alignment.crossAxis,
                children: space(spacing?.y.toDouble() ?? 0,
                    nodeResolver.childrenInForEach()),
              );
            /* TODO:
        .if(nodeResolver.propertyResolver.bool("fillHeight", defaultValue: false)) {
            $0.frame(maxHeight: .infinity, alignment: nodeResolver.propertyResolver.alignment())
        }
    }*/
            default:
              return SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              );
          }
        });
  }
}

/// A CVU element for displaying multiple children overlayed on each-other
/// - set the `alignment` property to align to any corner, edge, or center
class CVUZStack extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;

  //late final AlignmentResolver alignment;
  late final Point? spacing;

  CVUZStack({required this.nodeResolver});

  init() async {
    //alignment = await nodeResolver.propertyResolver.alignment();
    spacing = await nodeResolver.propertyResolver.spacing;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init(),
        builder: (BuildContext builder, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Container(
                child: nodeResolver.childrenInForEachWithWrap(),
              );
            default:
              return SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              );
          }
        });
  }
}
