import 'package:flutter/material.dart';
import 'package:memri/cvu/utilities/binding.dart';
import 'package:memri/cvu/widgets/renderers/renderer.dart';

import '../../../widgets/components/note_editor/memri_text_editor.dart';
import '../../../widgets/components/note_editor/memri_text_editor_model.dart';

/// The note editor renderer
/// This presents an editor for a single item
/// - for an item to be shown the CVU for ItemType > NoteEditor {...} must define both a `title` and `content` expression
/// - see the `Note.cvu` file for an example of this
/// - `File` items containing images can be referenced within the content HTML as `<img src="memriFile://fileUIDHere">`. The editor will look for a `file` edge from the item to a matching file, without this edge it will not be found (security measure)
class NoteEditorRendererView extends Renderer {
  NoteEditorRendererView({required viewContext}) : super(viewContext: viewContext);

  @override
  _NoteEditorRendererViewState createState() => _NoteEditorRendererViewState();
}

class _NoteEditorRendererViewState extends RendererViewState {
  Binding<String>? get noteTitle {
    var item = viewContext.focusedItem;
    if (item != null) {
      var resolver = viewContext.nodePropertyResolver(item);
      if (resolver != null) {
        var value = resolver.string("title");
        if (value != null) {
          return Binding(() => value, (value) => {});
        }
        /*var binding = await resolver.binding<String>("title");
        if (binding != null) {
          return binding;
        }*/
      }
    }
    return null;
  }

  Binding<String>? get noteContent {
    var item = viewContext.focusedItem;
    if (item != null) {
      var resolver = viewContext.nodePropertyResolver(item);
      if (resolver != null) {
        var value = resolver.string("content") ?? "";
        if (value != null) {
          return Binding(() => value, (value) => {});
        }
        /*var binding = await resolver.binding<String>("content", "");
        if (binding != null) {
          return binding;
        }*/
      }
    }
    return null;
  }

  MemriTextEditorModel getEditorModel() {
    return MemriTextEditorModel(title: noteTitle?.get(), body: noteContent?.get());
  }

  handleModelUpdate(MemriTextEditorModel newModel) {
    var newModelTitle = newModel.title;
    if (noteTitle?.get() != newModelTitle) {
      noteTitle?.set(newModelTitle ?? "");
    }
    var newModelBody = newModel.body;
    if (noteContent?.get() != newModelBody) {
      noteContent?.set(newModelBody);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MemriTextEditor(
      model: getEditorModel,
      onModelUpdate: handleModelUpdate,
      viewContext: viewContext,
    );
  }
}
