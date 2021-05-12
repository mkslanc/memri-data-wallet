import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/Components/ImagesAndFiles/PhotoViewController.dart';

import '../ViewContextController.dart';

/// The photo viewer renderer
/// This presents the data items in a photo viewer, that can page horizontally between images
/// The CVU for ItemType > map {...} must define a `file` expression pointing to a `File` item
class PhotoViewerRendererView extends StatelessWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  PhotoViewerRendererView({required this.sceneController, required this.viewContext});

  Future<PhotoViewerControllerPhotoItem?> photoItemProvider(int index) async {
    ItemRecord? item = viewContext.items.asMap()[index];
    if (item == null) return null;
    var fileURL = await viewContext.nodePropertyResolver(item)?.fileURL("file");
    if (fileURL == null) return null;

    var overlay = viewContext.render(item, null, true);
    return PhotoViewerControllerPhotoItem(index, fileURL, overlay);
  }

  onToggleOverlayVisibility(bool visible) {
    isFullScreen = !visible;
  }

  toggleFullscreen() {
    isFullScreen = !isFullScreen;
  }

  bool get isFullScreen => viewContext.isFullScreen;

  set isFullScreen(bool newValue) => viewContext.isFullScreen = newValue;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: viewContext.itemsValueNotifier,
        builder: (BuildContext context, List<ItemRecord> value, Widget? child) {
          if (viewContext.hasItems) {
            return Container(
              child: PhotoViewerView(
                onToggleOverlayVisibility: onToggleOverlayVisibility,
                viewContext: viewContext,
                photoItemProvider: photoItemProvider,
                initialIndex: viewContext.focusedIndex,
              ),
            );
          } else {
            return Text(
              "No photos found",
              style: TextStyle(fontWeight: FontWeight.bold),
            );
          }
        });
  }
}
