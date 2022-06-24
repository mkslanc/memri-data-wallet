//  Created by T Brennan on 23/1/21.

import 'package:flutter/cupertino.dart';
import 'package:memri/core/controllers/page_controller.dart' as memri;
import 'package:memri/core/controllers/view_context_controller.dart';
import 'package:memri/widgets/renderers/calendar_renderer.dart';
import 'package:memri/widgets/renderers/chart_renderer.dart';
import 'package:memri/widgets/renderers/custom_renderer.dart';
import 'package:memri/widgets/renderers/cvu_editor_renderer.dart';
import 'package:memri/widgets/renderers/file_renderer.dart';
import 'package:memri/widgets/renderers/general_editor_renderer.dart';
import 'package:memri/widgets/renderers/grid_renderer.dart';
import 'package:memri/widgets/renderers/label_annotation_renderer.dart';
import 'package:memri/widgets/renderers/list_renderer.dart';
import 'package:memri/widgets/renderers/map_renderer.dart';
import 'package:memri/widgets/renderers/note_editor_renderer.dart';
import 'package:memri/widgets/renderers/photo_viewer_renderer.dart';
import 'package:memri/widgets/renderers/plugin_config_renderer.dart';
import 'package:memri/widgets/renderers/scene_view_renderer.dart';
import 'package:memri/widgets/renderers/single_item_renderer.dart';
import 'package:memri/widgets/renderers/timeline_renderer.dart';

class SceneContentView extends StatefulWidget {
  final memri.PageController pageController;
  final ViewContextController viewContext;

  SceneContentView(
      {required this.pageController, required this.viewContext, Key? key})
      : super(key: key);

  @override
  _SceneContentViewState createState() =>
      _SceneContentViewState(pageController, viewContext);
}

class _SceneContentViewState extends State<SceneContentView> {
  memri.PageController pageController;
  ViewContextController viewContext;

  _SceneContentViewState(this.pageController, this.viewContext);

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
        return ListRendererView(
            viewContext: viewContext, pageController: pageController);
      case "grid":
        return GridRendererView(
            viewContext: viewContext, pageController: pageController);
      case "map":
        return MapRendererView(
            viewContext: viewContext, pageController: pageController);
      case "timeline":
        return TimelineRendererView(
            viewContext: viewContext, pageController: pageController);
      case "calendar":
        return CalendarRendererView(
            viewContext: viewContext, pageController: pageController);
      case "photoviewer":
        return PhotoViewerRendererView(
            viewContext: viewContext, pageController: pageController);
      case "chart":
        return ChartRendererView(
            viewContext: viewContext, pageController: pageController);
      case "singleitem":
        return SingleItemRendererView(
            viewContext: viewContext, pageController: pageController);
      case "noteeditor":
        return NoteEditorRendererView(
            viewContext: viewContext, pageController: pageController);
      case "cvueditor":
        return CVUEditorRendererView(
            viewContext: viewContext, pageController: pageController);
      case "labelannotation":
        return LabelAnnotationRendererView(
            viewContext: viewContext, pageController: pageController);
      case "custom":
        return CustomRendererView(
            viewContext: viewContext, pageController: pageController);
      case "fileviewer":
        return FileRendererView(
            viewContext: viewContext, pageController: pageController);
      case "generaleditor":
        return GeneralEditorRendererView(
            viewContext: viewContext, pageController: pageController);
      case "scene":
        return SceneViewRendererView(
            viewContext: viewContext, pageController: pageController);
      case "pluginconfig":
        return PluginConfigRendererView(
            viewContext: viewContext, pageController: pageController);
      default:
        return Text("No renderer selected",
            style: TextStyle(fontWeight: FontWeight.bold));
    }
  }

  //TODO onAppear, onDisappear

  @override
  Widget build(BuildContext context) {
    return renderer;
  }
}
