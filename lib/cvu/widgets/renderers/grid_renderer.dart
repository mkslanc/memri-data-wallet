import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:memri/core/models/item.dart';
import 'package:memri/cvu/constants/cvu_color.dart';
import 'package:memri/cvu/models/cvu_value.dart';
import 'package:memri/cvu/models/cvu_value_constant.dart';
import 'package:memri/cvu/models/cvu_view_arguments.dart';
import 'package:memri/widgets/components/shapes/circle.dart';
import 'package:memri/widgets/empty.dart';
import 'package:memri/cvu/widgets/renderers/grid_renderer_flow.dart';
import 'package:memri/cvu/widgets/renderers/grid_renderer_simple.dart';
import 'package:memri/cvu/widgets/renderers/renderer.dart';

/// The grid renderer
/// This presents the data in a grid (aka collection view)
class GridRendererView extends Renderer {
  GridRendererView({required viewContext}) : super(viewContext: viewContext);

  @override
  GridRendererViewState createState() => GridRendererViewState();
}

class GridRendererViewState extends RendererViewState {
  late EdgeInsets insets;
  late Point spacing;

  late String layout;

  @override
  initState() {
    super.initState();
    init();

    viewContext.addListener(updateState);
  }

  @override
  void didUpdateWidget(covariant Renderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() => init());
  }

  dispose() {
    super.dispose();
    viewContext.removeListener(updateState);
  }

  late Axis scrollDirection;
  late Color backgroundColor;

  updateState() {
    setState(() => init());
  }

  void init() {
    super.init();
    layout = widget.viewContext.rendererDefinitionPropertyResolver
            .string("layout") ??
        "simple";
    singleChoice =
        viewContext.viewDefinitionPropertyResolver.boolean("singleChoice") ??
            false;
    insets = viewContext.rendererDefinitionPropertyResolver.edgeInsets ??
        EdgeInsets.fromLTRB(10, 10, 10, 10);

    var _scrollDirection = widget.viewContext.rendererDefinitionPropertyResolver
        .string("scrollDirection");
    scrollDirection = () {
      switch (_scrollDirection) {
        case "horizontal":
          return Axis.horizontal;
        default:
          return Axis.vertical;
      }
    }();

    spacing =
        viewContext.rendererDefinitionPropertyResolver.spacing ?? Point(10, 10);
    backgroundColor =
        viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
            CVUColor.system("systemBackground");
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: viewContext.itemsValueNotifier,
        builder: (BuildContext context, List<Item> value, Widget? child) {
          if (!viewContext.isLoaded) {
            return Empty();
          }
          List<Widget> elements = [];

          if (viewContext.hasItems) {
            elements = viewContext.items.mapIndexed((index, item) {
              var isSelected = selectedIndices.contains(index);
              return GestureDetector(
                onTap: selectionMode(index, context),
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: viewContext.render(
                            item: item,
                            viewArguments: CVUViewArguments(args: {
                              "isSelected":
                                  CVUValueConstant(CVUConstantBool(isSelected))
                            }))),
                    if (isSelected && showDefaultSelections)
                      Container(
                        height: 30,
                        width: 30,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Circle(
                                color: Colors.blue,
                                border:
                                    Border.all(color: Colors.white, width: 2)),
                            Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 15,
                            )
                          ],
                        ),
                      )
                  ],
                ),
              );
            }).toList();
          }
          if (startingElement != null) {
            elements.insert(
                0,
                GestureDetector(
                  child: startingElement!,
                ));
          }
          if (trailingElement != null) {
            elements.add(GestureDetector(child: trailingElement!));
          }

          return elements.isNotEmpty
              ? layout == "flow"
                  ? GridRendererFlowView(elements: elements, spacing: spacing)
                  : GridRendererSimpleView(
                      elements: elements,
                      spacing: spacing,
                      insets: insets,
                      scrollDirection: scrollDirection,
                    )
              : emptyResult ??
                  Padding(
                    padding: EdgeInsets.all(30),
                    child: Center(
                      child: Text(
                        "No items",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Color.fromRGBO(0, 0, 0, 0.7),
                            backgroundColor: backgroundColor),
                      ),
                    ),
                  );
        });
  }
}

abstract class GridRenderer extends StatelessWidget {
  late final Point spacing;
  late final List<Widget> elements;

  GridRenderer({required this.spacing, required this.elements});
}
