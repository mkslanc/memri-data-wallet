import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import '../ViewContextController.dart';

/// The note editor renderer
/// This presents an editor for a single item
/// - for an item to be shown the CVU for ItemType > NoteEditor {...} must define both a `title` and `content` expression
/// - see the `Note.cvu` file for an example of this
/// - `File` items containing images can be referenced within the content HTML as `<img src="memriFile://fileUIDHere">`. The editor will look for a `file` edge from the item to a matching file, without this edge it will not be found (security measure)
class NoteEditorRendererView extends StatefulWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  NoteEditorRendererView({required this.sceneController, required this.viewContext});

  @override
  _NoteEditorRendererViewState createState() =>
      _NoteEditorRendererViewState(sceneController, viewContext);
}

class _NoteEditorRendererViewState extends State<NoteEditorRendererView> {
  final SceneController sceneController;
  final ViewContextController viewContext;

  // bool _showingImagePicker = false;
  // bool _showingImagePicker_shouldUseCamera = false;
  // void Function()? _imagePickerPromise;

  _NoteEditorRendererViewState(this.sceneController, this.viewContext);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Text(viewContext.focusedItem.toString())); //TODO
  }
}
