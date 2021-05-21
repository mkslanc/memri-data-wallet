import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import '../CVUUINodeResolver.dart';

/// Modifier used to apply common CVU properties (such as sizing, padding, colors, opacity, etc)
class CVUAppearanceModifier {
  CVUUINodeResolver nodeResolver;

  CVUAppearanceModifier({required this.nodeResolver});

  late EdgeInsets padding;
  late Color backgroundColor;
  late double minWidth;
  late double maxWidth;
  late double minHeight;
  late double maxHeight;
  late double cornerRadius;
  late double opacity;
  late double? shadow;
  late Color? border;
  late Offset offset;

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
    shadow = await nodeResolver.propertyResolver.shadow;
    border = await nodeResolver.propertyResolver.borderColor;
    offset = await nodeResolver.propertyResolver.offset;
  }

  Widget body(Widget child) {
    var widget = child;
    return FutureBuilder(
        future: init(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (shadow != null) {
              widget = PhysicalModel(
                color: backgroundColor,
                elevation: shadow!,
                child: widget,
              );
            }
            if (offset != Offset.zero) {
              widget = Transform.translate(offset: offset, child: widget);
            }
            widget = Container(
                constraints: BoxConstraints(
                    maxHeight: maxHeight,
                    minHeight: minHeight,
                    maxWidth: maxWidth,
                    minWidth: minWidth),
                padding: padding,
                decoration: BoxDecoration(
                    color: backgroundColor,
                    border: border != null ? Border.all(color: border!) : null),
                child: Opacity(
                  opacity: opacity,
                  child: widget,
                ));
            if (cornerRadius > 0) {
              widget = ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
                child: widget,
              );
            }
            return widget;
          } else {
            return Empty();
          }
        });

    /* TODO .ifLet(nodeResolver.propertyResolver.zIndex) { $0.zIndex($1) }*/
  }
}
