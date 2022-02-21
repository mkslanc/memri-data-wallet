import 'package:flutter/material.dart';
import 'package:memri/models/cvu/cvu_value.dart';
import 'package:memri/models/cvu/cvu_value_constant.dart';
import 'package:memri/models/cvu/cvu_view_arguments.dart';
import 'package:memri/models/database/item_record.dart';
import 'package:memri/utils/extensions/collection.dart';
import 'package:memri/widgets/components/shapes/circle.dart';
import 'package:memri/widgets/empty.dart';
import 'package:memri/widgets/renderers/grid_renderer.dart';

/// The grid renderer simple layout
/// This presents the data in a grid (aka collection view)
class GridRendererSimpleView extends GridRendererView {
  GridRendererSimpleView({required pageController, required viewContext})
      : super(pageController: pageController, viewContext: viewContext);

  @override
  _GridRendererSimpleViewState createState() => _GridRendererSimpleViewState();
}

class _GridRendererSimpleViewState extends GridRendererViewState {
  late Future _init;

  @override
  initState() {
    super.initState();
    _init = init();
  }

  @override
  init() async {
    super.init();

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
                                      child: viewContext.render(
                                          item: item,
                                          viewArguments: CVUViewArguments(args: {
                                            "isSelected": CVUValueConstant(
                                                CVUConstantBool(isSelected)) //TODO:
                                          }))),
                                  if (isInEditMode && !isSelected)
                                    SizedBox.expand(
                                      child: ColoredBox(color: Colors.white.withOpacity(0.15)),
                                    ),
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
