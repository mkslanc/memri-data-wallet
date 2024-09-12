//  Created by T Brennan on 23/1/21.

import 'package:flutter/material.dart';
import 'package:memri/cvu/controllers/view_context_controller.dart';
import 'package:memri/cvu/widgets/renderers/chart_renderer.dart';
import 'package:memri/cvu/widgets/renderers/custom_renderer.dart';
import 'package:memri/cvu/widgets/renderers/general_editor_renderer.dart';
import 'package:memri/cvu/widgets/renderers/grid_renderer.dart';
import 'package:memri/cvu/widgets/renderers/list_renderer.dart';
import 'package:memri/cvu/widgets/renderers/map_renderer.dart';
import 'package:memri/cvu/widgets/renderers/note_editor_renderer.dart';
import 'package:memri/cvu/widgets/renderers/photo_viewer_renderer.dart';
import 'package:memri/cvu/widgets/renderers/single_item_renderer.dart';
import 'package:memri/cvu/widgets/renderers/timeline_renderer.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';

class SceneContentView extends StatefulWidget {
  final ViewContextController viewContext;

  SceneContentView({required this.viewContext, Key? key}) : super(key: key);

  @override
  _SceneContentViewState createState() => _SceneContentViewState(viewContext);
}

class _SceneContentViewState extends State<SceneContentView> {
  ViewContextController viewContext;

  _SceneContentViewState(this.viewContext);

  @override
  initState() {
    super.initState();
    viewContext.onAppear();
    viewContext.addListener(updateState);
  }

  @override
  dispose() {
    super.dispose();
    viewContext.onDisappear();
    viewContext.removeListener(updateState);
  }

  updateState() {
    setState(() {});
  }

  /// Translates the rendererName to the correct Renderer view
  Widget get renderer {
    switch (viewContext.config.rendererName.toLowerCase()) {
      case "list":
        return ListRendererView(viewContext: viewContext);
      case "grid":
        return GridRendererView(viewContext: viewContext);
      // case "map":
      //   return MapRendererView(viewContext: viewContext);
      case "timeline":
        return TimelineRendererView(viewContext: viewContext);
      case "photoviewer":
        return PhotoViewerRendererView(viewContext: viewContext);
      case "chart":
        return ChartRendererView(viewContext: viewContext);
      case "singleitem":
        return SingleItemRendererView(viewContext: viewContext);
      case "noteeditor":
        return NoteEditorRendererView(viewContext: viewContext);
      case "custom":
        return CustomRendererView(viewContext: viewContext);
      case "generaleditor":
        return GeneralEditorRendererView(viewContext: viewContext);
      default:
        return Center(
            child: Text("No renderer selected", style: TextStyle(fontWeight: FontWeight.bold)));
    }
  }

  //TODO onAppear, onDisappear

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          viewContext.getItems(viewContext.config.query);
        },
        child: renderer
    );
  }
}
