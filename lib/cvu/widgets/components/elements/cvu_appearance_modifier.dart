import 'package:flutter/material.dart';
import 'package:memri/cvu/constants/cvu_color.dart';
import 'package:memri/cvu/models/cvu_ui_element_family.dart';
import 'package:memri/cvu/widgets/components/cvu_ui_node_resolver.dart';

/// Modifier used to apply common CVU properties (such as sizing, padding, colors, opacity, etc)
class CVUAppearanceModifier extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;
  final Widget child;

  CVUAppearanceModifier({required this.nodeResolver, required this.child});

  @override
  _CVUAppearanceModifierState createState() => _CVUAppearanceModifierState();
}

class _CVUAppearanceModifierState extends State<CVUAppearanceModifier> {
  late EdgeInsets padding;

  late Color? backgroundColor;

  late double minWidth;

  late double maxWidth;

  late double minHeight;

  late double maxHeight;

  late double cornerRadius;

  late List<double> cornerRadiusOnly;

  late double opacity;

  late double? shadow;

  late Color? border;

  late Offset offset;

  late Future _init;

  bool isInited = false;

  @override
  initState() {
    super.initState();
    _init = init();
  }

  @override
  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init = init();
  }

  init() async {
    padding = await widget.nodeResolver.propertyResolver.padding;
    backgroundColor =
        (await widget.nodeResolver.propertyResolver.backgroundColor) ?? null;
    minWidth = await widget.nodeResolver.propertyResolver.minWidth ?? 0;
    maxWidth =
        await widget.nodeResolver.propertyResolver.maxWidth ?? double.infinity;
    minHeight = await widget.nodeResolver.propertyResolver.minHeight ?? 0;
    maxHeight =
        await widget.nodeResolver.propertyResolver.maxHeight ?? double.infinity;
    cornerRadius = await widget.nodeResolver.propertyResolver.cornerRadius;
    cornerRadiusOnly =
        await widget.nodeResolver.propertyResolver.cornerRadiusOnly;
    opacity = await widget.nodeResolver.propertyResolver.opacity;
    shadow = await widget.nodeResolver.propertyResolver.shadow;
    border = await widget.nodeResolver.propertyResolver.borderColor;
    offset = await widget.nodeResolver.propertyResolver.offset;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext context, snapshot) {
          var childWidget = widget.child;
          isInited =
              isInited || snapshot.connectionState == ConnectionState.done;
          if (isInited) {
            if (widget.nodeResolver.node.type == CVUUIElementFamily.SubView) {
              //TODO this is a really bad workaround
              if (maxHeight == double.infinity) {
                return childWidget;
              }
              childWidget =
                  SizedBox.expand(child: Column(children: [childWidget]));
            }
            if (shadow != null) {
              childWidget = PhysicalModel(
                color: backgroundColor ?? CVUColor(color: "clear").value,
                elevation: shadow!,
                child: childWidget,
              );
            }
            if (offset != Offset.zero) {
              childWidget =
                  Transform.translate(offset: offset, child: childWidget);
            }
            childWidget = Container(
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
                  child: childWidget,
                ));
            if (cornerRadius > 0) {
              childWidget = ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(cornerRadius)),
                child: childWidget,
              );
            }
            if (cornerRadiusOnly.isNotEmpty) {
              childWidget = ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(cornerRadiusOnly[0]),
                  topRight: Radius.circular(cornerRadiusOnly[1]),
                  bottomRight: Radius.circular(cornerRadiusOnly[2]),
                  bottomLeft: Radius.circular(cornerRadiusOnly[3]),
                ),
                child: childWidget,
              );
            }
          }
          return childWidget;
        });

    /* TODO .ifLet(nodeResolver.propertyResolver.zIndex) { $0.zIndex($1) }*/
  }
}
