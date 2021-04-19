import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';

import '../CVUUINodeResolver.dart';

/// Modifier used to apply common CVU properties (such as sizing, padding, colors, opacity, etc)
class CVUAppearanceModifier {
  CVUUINodeResolver nodeResolver;

  CVUAppearanceModifier({required this.nodeResolver});

  /*var shape: some InsettableShape {
        RoundedRectangle(cornerRadius: nodeResolver.propertyResolver.cornerRadius())
    }*/

  late EdgeInsets padding;
  late Color backgroundColor;
  late double minWidth;
  late double maxWidth;
  late double minHeight;
  late double maxHeight;
  late double cornerRadius;
  late double opacity;

  init() async {
    padding = await nodeResolver.propertyResolver.padding;
    backgroundColor =
        (await nodeResolver.propertyResolver.backgroundColor) ?? CVUColor.system("clear");
    minWidth = await nodeResolver.propertyResolver.minWidth ?? 0;
    maxWidth = await nodeResolver.propertyResolver.maxWidth ?? double.infinity;
    minHeight = await nodeResolver.propertyResolver.minHeight ?? 0;
    maxHeight = await nodeResolver.propertyResolver.maxHeight ?? double.infinity;
    cornerRadius = await nodeResolver.propertyResolver.cornerRadius;
    opacity = await nodeResolver.propertyResolver.opacity;
  }

  Widget body(Widget child) {
    var widget = child;
    return FutureBuilder(
        future: init(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (cornerRadius > 0) {
              widget = ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
                child: widget,
              );
            }
            return ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: maxHeight,
                  minHeight: minHeight,
                  maxWidth: maxWidth,
                  minWidth: minWidth),
              child: ColoredBox(
                color: backgroundColor,
                child: Opacity(
                  opacity: opacity,
                  child: Padding(
                    padding: padding,
                    child: widget,
                  ),
                ),
              ),
            );
          } else {
            return Text("");
          }
        });

    /* TODO
            .foregroundColor(nodeResolver.propertyResolver.color()?.color)
            .font(nodeResolver.propertyResolver.font().font)
            .multilineTextAlignment(nodeResolver.propertyResolver.textAlignment())
            .lineLimit(nodeResolver.propertyResolver.lineLimit)
            .background(
                shape
                    .fill(nodeResolver.propertyResolver.backgroundColor?.color ?? .clear)
                    .ifLet(nodeResolver.propertyResolver.shadow) { $0.shadow(radius: $1) }
            )
            .overlay(
                shape
                    .strokeBorder(nodeResolver.propertyResolver.borderColor?.color ?? .clear)
            )
            .offset(nodeResolver.propertyResolver.offset)
            .ifLet(nodeResolver.propertyResolver.zIndex) { $0.zIndex($1) }*/
  }
}
