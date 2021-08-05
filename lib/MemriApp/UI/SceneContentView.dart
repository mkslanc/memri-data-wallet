//
//  SceneContentView.swift
//  Memri
//
//  Created by T Brennan on 23/1/21.
//

import 'package:flutter/cupertino.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import 'Chrome/BottomBarView.dart';
import 'Chrome/SearchView.dart';
import 'Renderers/CalendarRenderer.dart';
import 'Renderers/ChartRenderer.dart';
import 'Renderers/FileRenderer.dart';
import 'Renderers/GeneralEditorRenderer.dart';
import 'Renderers/GridRenderer.dart';
import 'Renderers/LabelAnnotationRenderer.dart';
import 'Renderers/ListRenderer.dart';
import 'Renderers/MapRenderer.dart';
import 'Renderers/CustomRenderer.dart';
import 'Renderers/NoteEditorRenderer.dart';
import 'Renderers/PhotoViewerRenderer.dart';
import 'Renderers/SingleItemRenderer.dart';
import 'Renderers/TimelineRenderer.dart';
import 'UIHelpers/utilities.dart';
import 'ViewContextController.dart';

class SceneContentView extends StatefulWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  SceneContentView({required this.sceneController, required this.viewContext});

  @override
  _SceneContentViewState createState() => _SceneContentViewState(sceneController, viewContext);
}

class _SceneContentViewState extends State<SceneContentView> {
  SceneController sceneController;
  ViewContextController viewContext;
  late final Future _init;
  late bool showBottomBar;
  late bool showContextualBottomBar;

  _SceneContentViewState(this.sceneController, this.viewContext);

  /// Keep track of whether the search bar is currently open (keyboard shown)
  final searchBarOpen = ValueNotifier<bool>(false);

  @override
  initState() {
    super.initState();
    viewContext.onAppear();
    viewContext.addListener(updateState);
    _init = init();
  }

  init() async {
    showBottomBar = await _showBottomBar;
    showContextualBottomBar = await _showContextualBottomBar;
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
        return ListRendererView(viewContext: viewContext, sceneController: sceneController);
      case "grid":
        return GridRendererView(viewContext: viewContext, sceneController: sceneController);
      case "map":
        return MapRendererView(viewContext: viewContext, sceneController: sceneController);
      case "timeline":
        return TimelineRendererView(viewContext: viewContext, sceneController: sceneController);
      case "calendar":
        return CalendarRendererView(viewContext: viewContext, sceneController: sceneController);
      case "photoviewer":
        return PhotoViewerRendererView(viewContext: viewContext, sceneController: sceneController);
      case "chart":
        return ChartRendererView(viewContext: viewContext, sceneController: sceneController);
      case "singleitem":
        return SingleItemRendererView(viewContext: viewContext, sceneController: sceneController);
      case "noteeditor":
        return NoteEditorRendererView(viewContext: viewContext, sceneController: sceneController);
      case "labelannotation":
        return LabelAnnotationRendererView(
            viewContext: viewContext, sceneController: sceneController);
      case "custom":
        return CustomRendererView(viewContext: viewContext, sceneController: sceneController);
      case "fileviewer":
        return FileRendererView(viewContext: viewContext, sceneController: sceneController);
      case "generaleditor":
        return GeneralEditorRendererView(
            viewContext: viewContext, sceneController: sceneController);
      default:
        return Expanded(
            child: Text("No renderer selected", style: TextStyle(fontWeight: FontWeight.bold)));
    }
  }

  //TODO onAppear, onDisappear

  Future<bool> get _showContextualBottomBar async {
    return await viewContext.viewDefinitionPropertyResolver.boolean("showContextualBottomBar") ??
        true;
  }

  Future<bool> get _showBottomBar async {
    var subViewShowBottomBar = await viewContext.viewDefinitionPropertyResolver
        .subdefinition("arguments")
        ?.boolean("showBottomBar");
    return await viewContext.viewDefinitionPropertyResolver.boolean("showBottomBar") ??
        subViewShowBottomBar ??
        true;
  }

  CVUDefinitionContent? get bottomBar {
    var bottomBarDef = viewContext.cvuController
        .viewDefinitionFor(viewName: viewContext.config.viewName ?? viewContext.config.rendererName)
        ?.properties["bottomBar"];

    var bottomBarSubdef = bottomBarDef?.getSubdefinition();

    return bottomBarSubdef;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        renderer,
        ValueListenableBuilder<bool>(
            builder: (BuildContext context, value, Widget? child) {
              return value
                  ? SearchView(viewContext: viewContext, isActive: searchBarOpen)
                  : FutureBuilder(
                      future: _init,
                      builder: (BuildContext builder, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (showBottomBar) {
                            var nodeDefinition = bottomBar;
                            if (nodeDefinition == null) {
                              return BottomBarView(
                                viewContext: viewContext,
                                onSearchPressed: () {
                                  searchBarOpen.value = true;
                                },
                              );
                            } else {
                              return viewContext.render(nodeDefinition: nodeDefinition);
                            }
                          }
                        }
                        return Empty();
                      });
            },
            valueListenable: searchBarOpen)
      ],
    );
  }
}
