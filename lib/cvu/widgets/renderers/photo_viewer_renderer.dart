import 'package:flutter/material.dart';
import 'package:memri/core/controllers/file_storage/file_storage_controller.dart';
import 'package:memri/core/models/item.dart';
import 'package:memri/cvu/controllers/view_context_controller.dart';
import 'package:memri/cvu/widgets/components/photo_viewer_view.dart';

/// The photo viewer renderer
/// This presents the data items in a photo viewer, that can page horizontally between images
/// The CVU for ItemType > map {...} must define a `file` expression pointing to a `File` item
class PhotoViewerRendererView extends StatefulWidget {
  final ViewContextController viewContext;

  PhotoViewerRendererView({required this.viewContext});

  @override
  State<PhotoViewerRendererView> createState() => _PhotoViewerRendererViewState();
}

class _PhotoViewerRendererViewState extends State<PhotoViewerRendererView> {
  Future<PhotoViewerControllerPhotoItem?> photoItemProvider(int index) async {
    Item? item = widget.viewContext.items.asMap()[index];
    if (item == null) return null;
    var fileURL = await widget.viewContext.nodePropertyResolver(item)?.fileURL("file");
    if (fileURL == null) return null;
    var imageProvider = await FileStorageController.getImage(fileURL: fileURL);
    if (imageProvider == null) return null;

    var overlay = widget.viewContext.render(item: item, blankIfNoDefinition: true);
    return PhotoViewerControllerPhotoItem(index, imageProvider, overlay);
  }

  onToggleOverlayVisibility(bool visible) {
    isFullScreen = !visible;
  }

  toggleFullscreen() {
    isFullScreen = !isFullScreen;
  }

  bool get isFullScreen => widget.viewContext.isFullScreen;

  set isFullScreen(bool newValue) => widget.viewContext.isFullScreen = newValue;

  @override
  Widget build(BuildContext context) {
    if (widget.viewContext.hasItems) {
      return Container(
        child: PhotoViewerView(
          onToggleOverlayVisibility: onToggleOverlayVisibility,
          viewContext: widget.viewContext,
          photoItemProvider: photoItemProvider,
          initialIndex: widget.viewContext.focusedIndex,
        ),
      );
    } else {
      return Center(
          child: Text(
            "No photos found",
            style: TextStyle(fontWeight: FontWeight.bold),
          ));
    }
  }
}
