import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import '../ViewContextController.dart';

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
    return viewContext.hasItems
        ? Expanded(
            child: GridView.count(
            childAspectRatio: 4 / 5,
            shrinkWrap: true,
            primary: false,
            padding: const EdgeInsets.all(5),
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            crossAxisCount: 3,
            children: viewContext.items.map((item) {
              return Container(
                alignment: Alignment.bottomRight,
                child: viewContext.render(item),
              );
            }).toList(),
          ))
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [],
          );
  }
}
