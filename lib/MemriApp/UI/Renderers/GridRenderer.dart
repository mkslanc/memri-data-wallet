import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import '../ViewContextController.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

/// The grid renderer
/// This presents the data in a grid (aka collection view)
class GridRendererView extends StatefulWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  GridRendererView({required this.sceneController, required this.viewContext});

  @override
  _GridRendererViewState createState() => _GridRendererViewState(sceneController, viewContext);
}

class _GridRendererViewState extends State<GridRendererView> {
  final SceneController sceneController;
  final ViewContextController viewContext;

  _GridRendererViewState(this.sceneController, this.viewContext);

  late Axis scrollDirection;
  late Color backgroundColor;

  late bool isInEditMode;

  @override
  initState() {
    super.initState();
    viewContext.addListener(updateState);
  }

  dispose() {
    super.dispose();
    viewContext.removeListener(updateState);
  }

  updateState() {
    setState(() {});
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

    backgroundColor = await viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
        CVUColor.system("systemBackground");

    isInEditMode = (await viewContext.viewDefinitionPropertyResolver
        .boolean("editMode", sceneController.isInEditMode.value))!;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: init(),
      builder: (context, snapshot) => snapshot.connectionState == ConnectionState.done
          ? ValueListenableBuilder(
              valueListenable: viewContext.itemsValueNotifier,
              builder: (BuildContext context, List<ItemRecord> value, Widget? child) {
                return Expanded(
                  child: Column(
                    children: [
                      viewContext.hasItems
                          ? Expanded(
                              child: GridView.count(
                              //TODO layout
                              physics: AlwaysScrollableScrollPhysics(),
                              scrollDirection: scrollDirection,
                              childAspectRatio: 4 / 5,
                              shrinkWrap: true,
                              primary: false,
                              padding: const EdgeInsets.all(5),
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                              crossAxisCount: 3,
                              children: viewContext.items
                                  .mapIndexed((index, item) => GestureDetector(
                                        onTap: selectionMode(index),
                                        child: Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [viewContext.render(item: item)],
                                        ),
                                      ))
                                  .toList(),
                            ))
                          : Padding(
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
                            ),
                    ],
                  ),
                );
              })
          : Empty(),
    );
  }

  GestureTapCallback selectionMode(index) {
    if (isInEditMode) {
      return () {
        print(index); //TODO select
      };
    } else {
      return () {
        var item = viewContext.items.asMap()[index];

        if (item != null) {
          var presses = viewContext.rendererDefinitionPropertyResolver.actions("onPress") ??
              viewContext.nodePropertyResolver(item)?.actions("onPress");
          if (presses != null) {
            presses.forEach(
                (press) => press.execute(sceneController, viewContext.getCVUContext(item: item)));
          }
        }
      };
    }
  }
}
