import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/constants/cvu/cvu_color.dart';
import 'package:memri/core/models/cvu/cvu_value.dart';
import 'package:memri/core/models/cvu/cvu_value_constant.dart';
import 'package:memri/core/models/cvu/cvu_view_arguments.dart';
import 'package:memri/core/models/database/item_record.dart';
import 'package:memri/utilities/extensions/collection.dart';
import 'package:memri/widgets/components/shapes/circle.dart';
import 'package:memri/widgets/empty.dart';
import 'package:memri/widgets/renderers/grid_renderer_flow.dart';
import 'package:memri/widgets/renderers/grid_renderer_simple.dart';
import 'package:memri/widgets/renderers/renderer.dart';

/// The grid renderer
/// This presents the data in a grid (aka collection view)
class GridRendererView extends Renderer {
  GridRendererView({required pageController, required viewContext})
      : super(pageController: pageController, viewContext: viewContext);

  @override
  GridRendererViewState createState() => GridRendererViewState();
}

class GridRendererViewState extends RendererViewState {
  late EdgeInsets insets;
  late Point spacing;

  late Future _init;
  bool isInited = false;
  late String layout;

  @override
  initState() {
    super.initState();
    _init = init();

    pageController.isInEditMode.addListener(updateState);
    viewContext.addListener(updateState);
  }

  @override
  void didUpdateWidget(covariant Renderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init = init();
  }

  dispose() {
    super.dispose();
    pageController.isInEditMode.removeListener(updateState);
    viewContext.removeListener(updateState);
  }

  late Axis scrollDirection;
  late Color backgroundColor;

  updateState() async {
    await init();
  }

  init() async {
    super.init();
    layout = await widget.viewContext.rendererDefinitionPropertyResolver
            .string("layout") ??
        "simple";
    singleChoice = await viewContext.viewDefinitionPropertyResolver
            .boolean("singleChoice") ??
        false;
    insets = await viewContext.rendererDefinitionPropertyResolver.edgeInsets ??
        EdgeInsets.fromLTRB(5, pageController.showTopBar ? 5 : 80, 5, 5);

    var _scrollDirection = await widget
        .viewContext.rendererDefinitionPropertyResolver
        .string("scrollDirection");
    scrollDirection = () {
      switch (_scrollDirection) {
        case "horizontal":
          return Axis.horizontal;
        default:
          return Axis.vertical;
      }
    }();

    spacing = await viewContext.rendererDefinitionPropertyResolver.spacing ??
        Point(10, 10);
    backgroundColor =
        await viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
            CVUColor.system("systemBackground");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) {
        isInited = isInited || snapshot.connectionState == ConnectionState.done;
        return isInited
            ? ValueListenableBuilder(
                valueListenable: viewContext.itemsValueNotifier,
                builder: (BuildContext context, List<ItemRecord> value,
                    Widget? child) {
                  if (!viewContext.isLoaded) {
                    return Empty();
                  }
                  List<Widget> elements = [];

                  if (viewContext.hasItems) {
                    elements = viewContext.items.mapIndexed((index, item) {
                      var isSelected = selectedIndices.contains(index);
                      return GestureDetector(
                        onTap: selectionMode(index),
                        child: Stack(
                          alignment: Alignment.topLeft,
                          children: [
                            MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: viewContext.render(
                                    item: item,
                                    viewArguments: CVUViewArguments(args: {
                                      "isSelected": CVUValueConstant(
                                          CVUConstantBool(isSelected))
                                    }))),
                            if (isSelected &&
                                isInEditMode &&
                                showDefaultSelections)
                              Container(
                                height: 30,
                                width: 30,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Circle(
                                        color: Colors.blue,
                                        border: Border.all(
                                            color: Colors.white, width: 2)),
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

                  return RefreshIndicator(
                    onRefresh: () async => setState(() =>
                        pageController.topMostContext?.setupQueryObservation()),
                    child: elements.isNotEmpty
                        ? layout == "flow"
                            ? GridRendererFlowView(
                                elements: elements, spacing: spacing)
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
                            ),
                  );
                })
            : Empty();
      },
    );
  }
}

abstract class GridRenderer extends StatelessWidget {
  late final Point spacing;
  late final List<Widget> elements;

  GridRenderer({required this.spacing, required this.elements});
}
