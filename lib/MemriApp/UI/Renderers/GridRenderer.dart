import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import '../ViewContextController.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';

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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
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
                  children: viewContext.items
                      .mapIndexed((index, item) => GestureDetector(
                            onTap: selectionMode(index),
                            child: Container(
                              alignment: Alignment.bottomRight,
                              child: viewContext.render(item),
                            ),
                          ))
                      .toList(),
                ))
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [],
                );
        });
  }

  GestureTapCallback selectionMode(index) {
    if (sceneController.isInEditMode) {
      return () {
        print(index); //TODO select
      };
    } else {
      return () {
        var item = viewContext.items.asMap()[index];

        if (item != null) {
          var press = viewContext.nodePropertyResolver(item)?.action("onPress");
          if (press != null) {
            press.execute(sceneController, viewContext.getCVUContext(item));
          }
        }
      };
    }
  }
}
