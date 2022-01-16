import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUViewArguments.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/UI/Components/ShapesAndProgress/Circle.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';
import 'package:memri/MemriApp/UI/Renderers/GridRenderer.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

/// The grid renderer flow layout
/// This presents the data in a one-after-each-other order
class GridRendererFlowView extends GridRendererView {
  GridRendererFlowView({required pageController, required viewContext})
      : super(pageController: pageController, viewContext: viewContext);

  @override
  _GridRendererFlowViewState createState() => _GridRendererFlowViewState();
}

class _GridRendererFlowViewState extends GridRendererViewState {
  late Future _init;
  late Point spacing;

  @override
  initState() {
    super.initState();
    _init = init();
  }

  @override
  init() async {
    super.init();
    spacing = await viewContext.rendererDefinitionPropertyResolver.spacing ?? Point(10, 10);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) => snapshot.connectionState == ConnectionState.done
          ? ValueListenableBuilder(
              valueListenable: viewContext.itemsValueNotifier,
              builder: (BuildContext context, List<ItemRecord> value, Widget? child) {
                if (!viewContext.isLoaded) {
                  return Empty();
                }
                return viewContext.hasItems
                    ? RefreshIndicator(
                        onRefresh: () async =>
                            setState(() => pageController.topMostContext?.setupQueryObservation()),
                        child: Wrap(
                          spacing: spacing.x.toDouble(),
                          runSpacing: spacing.y.toDouble(),
                          children: viewContext.items.mapIndexed((index, item) {
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
                                              border: Border.all(color: Colors.white, width: 2)),
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
                          }).toList(),
                        ),
                      )
                    : emptyResult ??
                        Padding(
                          padding: EdgeInsets.fromLTRB(30, 40, 30, 30),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Spacer(),
                              Text(
                                "No results",
                                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                              Spacer()
                            ],
                          ),
                        );
              })
          : Empty(),
    );
  }
}
