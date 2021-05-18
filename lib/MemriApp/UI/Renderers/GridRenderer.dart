import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';
import 'package:memri/MemriApp/UI/Components/ShapesAndProgress/Circle.dart';
import '../ViewContextController.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';

/// The grid renderer
/// This presents the data in a grid (aka collection view)
class GridRendererView extends StatefulWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  GridRendererView({required this.sceneController, required this.viewContext});

  @override
  _GridRendererViewState createState() => _GridRendererViewState();
}

class _GridRendererViewState extends State<GridRendererView> {
  late final SceneController sceneController;
  late final ViewContextController viewContext;
  late bool isInEditMode;

  late Binding<Set<int>> selectedIndicesBinding;
  late Set<int> selectedIndices;

  late Future _init;

  initState() {
    super.initState();
    sceneController = widget.sceneController;
    viewContext = widget.viewContext;
    _init = init();

    sceneController.isInEditMode.addListener(updateIsInEditMode);
  }

  updateIsInEditMode() async {
    await init();
    setState(() {});
  }

  dispose() {
    super.dispose();
    sceneController.isInEditMode.removeListener(updateIsInEditMode);
  }

  Future init() async {
    isInEditMode = (await viewContext.viewDefinitionPropertyResolver
        .boolean("editMode", sceneController.isInEditMode.value))!;

    selectedIndicesBinding = viewContext.selectedIndicesBinding;
    selectedIndices = selectedIndicesBinding.get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (BuildContext context, AsyncSnapshot snapshot) => snapshot.connectionState ==
              ConnectionState.done
          ? ValueListenableBuilder(
              valueListenable: viewContext.itemsValueNotifier,
              builder: (BuildContext context, List<ItemRecord> value, Widget? child) {
                return viewContext.hasItems
                    ? Expanded(
                        child: GridView.count(
                        physics: AlwaysScrollableScrollPhysics(),
                        childAspectRatio: 4 / 5,
                        shrinkWrap: true,
                        primary: false,
                        padding: const EdgeInsets.all(5),
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                        crossAxisCount: 3,
                        children: viewContext.items.mapIndexed((index, item) {
                          var isSelected = selectedIndices.contains(index);
                          return GestureDetector(
                            onTap: selectionMode(index),
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                viewContext.render(item: item),
                                if (isInEditMode && !isSelected)
                                  SizedBox.expand(
                                    child: ColoredBox(color: Colors.white.withOpacity(0.15)),
                                  ),
                                if (isSelected)
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Container(
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
                                    ),
                                  )
                              ],
                            ),
                          );
                        }).toList(),
                      ))
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [],
                      );
              })
          : SizedBox.shrink(),
    );
  }

  selectionMode(index) {
    if (isInEditMode) {
      return () {
        setState(() {
          if (!selectedIndices.remove(index)) {
            selectedIndices.add(index);
          }
          selectedIndicesBinding.set(selectedIndices);
        });
      };
    } else {
      return () {
        var item = viewContext.items.asMap()[index];

        if (item != null) {
          var press = viewContext.nodePropertyResolver(item)?.action("onPress");
          if (press != null) {
            press.execute(sceneController, viewContext.getCVUContext(item: item));
          }
        }
      };
    }
  }
}
