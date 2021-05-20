import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';
import 'package:memri/MemriApp/UI/Components/NoteEditor/MemriTextEditor.dart';
import 'package:memri/MemriApp/UI/Components/NoteEditor/MemriTextEditorModel.dart';

import '../ViewContextController.dart';

/// The note editor renderer
/// This presents an editor for a single item
/// - for an item to be shown the CVU for ItemType > NoteEditor {...} must define both a `title` and `content` expression
/// - see the `Note.cvu` file for an example of this
/// - `File` items containing images can be referenced within the content HTML as `<img src="memriFile://fileUIDHere">`. The editor will look for a `file` edge from the item to a matching file, without this edge it will not be found (security measure)
class NoteEditorRendererView extends StatelessWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  NoteEditorRendererView({required this.sceneController, required this.viewContext});

  Future<FutureBinding<String>?> get noteTitle async {
    var item = viewContext.focusedItem;
    if (item != null) {
      var resolver = viewContext.nodePropertyResolver(item);
      if (resolver != null) {
        var binding = await resolver.binding<String>("title");
        if (binding != null) {
          return binding;
        }
      }
    }
    return null;
  }

  Future<FutureBinding<String>?> get noteContent async {
    var item = viewContext.focusedItem;
    if (item != null) {
      var resolver = viewContext.nodePropertyResolver(item);
      if (resolver != null) {
        var binding = await resolver.binding<String>("content", "");
        if (binding != null) {
          return binding;
        }
      }
    }
    return null;
  }

  Future<MemriTextEditorModel> getEditorModel() async {
    return MemriTextEditorModel(title: (await noteTitle)?.get(), body: (await noteContent)?.get());
  }

  handleModelUpdate(MemriTextEditorModel newModel) async {
    FutureBinding<String>? titleBinding = await noteTitle;
    var newModelTitle = await newModel.title;
    if (await titleBinding?.get() != newModelTitle) {
      titleBinding?.set(newModelTitle ?? "");
    }
    FutureBinding<String>? contentBinding = await noteContent;
    var newModelBody = await newModel.body;
    if (await contentBinding?.get() != newModelBody) {
      contentBinding?.set(newModelBody);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MemriTextEditor(model: getEditorModel, onModelUpdate: handleModelUpdate),
    );
  }
}
