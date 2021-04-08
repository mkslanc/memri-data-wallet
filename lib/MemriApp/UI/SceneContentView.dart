//
//  SceneContentView.swift
//  Memri
//
//  Created by T Brennan on 23/1/21.
//

import 'package:flutter/cupertino.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import 'Chrome/BottomBarView.dart';
import 'Chrome/SearchView.dart';
import 'Renderers/GridRenderer.dart';
import 'Renderers/ListRenderer.dart';
import 'Renderers/NoteEditorRenderer.dart';
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

  _SceneContentViewState(this.sceneController, this.viewContext);

  /// Keep track of whether the search bar is currently open (keyboard shown)
  final searchBarOpen = ValueNotifier<bool>(false);

  /// Translates the rendererName to the correct Renderer view
  Widget get renderer {
    switch (viewContext.config.rendererName.toLowerCase()) {
      case "list":
        return ListRendererView(viewContext: viewContext, sceneController: sceneController);
      case "noteeditor":
        return NoteEditorRendererView(viewContext: viewContext, sceneController: sceneController);
      case "grid":
        return GridRendererView(viewContext: viewContext, sceneController: sceneController);
      /*case "map":
        MapRendererView(viewContext: viewContext);
      case "timeline":
        TimelineRendererView(viewContext: viewContext);
      case "calendar":
        CalendarRendererView(viewContext: viewContext);
      case "photoviewer":
        PhotoViewerRendererView(viewContext: viewContext);
      case "chart":
        ChartRendererView(viewContext: viewContext);
      case "singleitem":
        SingleItemRendererView(viewContext: viewContext);
      case "noteeditor":
        NoteEditorRendererView(viewContext: viewContext);
      case "labelannotation":
        LabelAnnotationRendererView(viewContext: viewContext);
      case "fileviewer":
        FileRendererView(viewContext: viewContext);
      case "generaleditor":
        GeneralEditorRendererView(viewContext: viewContext);*/
      default:
        return Text("No renderer selected", style: TextStyle(fontWeight: FontWeight.bold));
    }
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
                  : BottomBarView(
                      viewContext: viewContext,
                      onFilterButtonPressed: () {
                        sceneController.filterPanelIsVisible.value = true;
                      },
                      onSearchPressed: () {
                        searchBarOpen.value = true;
                      },
                    );
            },
            valueListenable: searchBarOpen)
      ],
    );
  }
}
