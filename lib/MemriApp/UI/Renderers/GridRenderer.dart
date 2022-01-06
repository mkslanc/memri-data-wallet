import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import 'package:memri/MemriApp/UI/Components/ShapesAndProgress/Circle.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import 'Renderer.dart';

/// The grid renderer
/// This presents the data in a grid (aka collection view)
class GridRendererView extends Renderer {
  GridRendererView({required pageController, required viewContext})
      : super(pageController: pageController, viewContext: viewContext);

  @override
  _GridRendererViewState createState() => _GridRendererViewState();
}

class _GridRendererViewState extends RendererViewState {
  late EdgeInsets insets;

  late Future _init;

  @override
  initState() {
    super.initState();
    _init = init();

    pageController.isInEditMode.addListener(updateState);
    viewContext.addListener(updateState);
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
    var _scrollDirection =
        await widget.viewContext.rendererDefinitionPropertyResolver.string("scrollDirection");
    scrollDirection = () {
      switch (_scrollDirection) {
        case "horizontal":
          return Axis.horizontal;
        default:
          return Axis.vertical;
      }
    }();

    insets = await viewContext.rendererDefinitionPropertyResolver.edgeInsets ??
        EdgeInsets.fromLTRB(5, pageController.showTopBar ? 5 : 80, 5, 5);

    backgroundColor = await viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
        CVUColor.system("systemBackground");

    isInEditMode = (await viewContext.viewDefinitionPropertyResolver
        .boolean("editMode", pageController.isInEditMode.value))!;
    singleChoice =
        await viewContext.viewDefinitionPropertyResolver.boolean("singleChoice") ?? false;

    selectedIndicesBinding = viewContext.selectedIndicesBinding;
    selectedIndices = selectedIndicesBinding.get();
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
                        child: GridView.count(
                          //TODO layout
                          addRepaintBoundaries: false,
                          physics: AlwaysScrollableScrollPhysics(),
                          scrollDirection: scrollDirection,
                          childAspectRatio: 2,
                          shrinkWrap: true,
                          primary: false,
                          padding: insets,
                          //crossAxisSpacing: 5,
                          //mainAxisSpacing: 5,
                          crossAxisCount: 3,
                          children: viewContext.items.mapIndexed((index, item) {
                            var isSelected = selectedIndices.contains(index);
                            return GestureDetector(
                              onTap: selectionMode(index),
                              child: Stack(
                                alignment: Alignment.topLeft,
                                children: [
                                  MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: viewContext.render(item: item)),
                                  if (isInEditMode && !isSelected)
                                    SizedBox.expand(
                                      child: ColoredBox(color: Colors.white.withOpacity(0.15)),
                                    ),
                                  if (isSelected)
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
