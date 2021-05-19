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
import 'Renderers/CalendarRenderer.dart';
import 'Renderers/ChartRenderer.dart';
import 'Renderers/FileRenderer.dart';
import 'Renderers/GeneralEditorRenderer.dart';
import 'Renderers/GridRenderer.dart';
import 'Renderers/LabelAnnotationRenderer.dart';
import 'Renderers/ListRenderer.dart';
import 'Renderers/MapRenderer.dart';
import 'Renderers/NoteEditorRenderer.dart';
import 'Renderers/PhotoViewerRenderer.dart';
import 'Renderers/SingleItemRenderer.dart';
import 'Renderers/TimelineRenderer.dart';
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
    return ValueListenableBuilder(
        valueListenable: viewContext.config.rendererName,
        builder: (BuildContext context, String value, Widget? child) {
          switch (value.toLowerCase()) {
            case "list":
              return ListRendererView(viewContext: viewContext, sceneController: sceneController);
            case "grid":
              return GridRendererView(viewContext: viewContext, sceneController: sceneController);
            case "map":
              return MapRendererView(viewContext: viewContext, sceneController: sceneController);
            case "timeline":
              return TimelineRendererView(
                  viewContext: viewContext, sceneController: sceneController);
            case "calendar":
              return CalendarRendererView(
                  viewContext: viewContext, sceneController: sceneController);
            case "photoviewer":
              return PhotoViewerRendererView(
                  viewContext: viewContext, sceneController: sceneController);
            case "chart":
              return ChartRendererView(viewContext: viewContext, sceneController: sceneController);
            case "singleitem":
              return SingleItemRendererView(
                  viewContext: viewContext, sceneController: sceneController);
            case "noteeditor":
              return NoteEditorRendererView(
                  viewContext: viewContext, sceneController: sceneController);
            case "labelannotation":
              return LabelAnnotationRendererView(
                  viewContext: viewContext, sceneController: sceneController);
            case "fileviewer":
              return FileRendererView(viewContext: viewContext, sceneController: sceneController);
            case "generaleditor":
              return GeneralEditorRendererView(
                  viewContext: viewContext, sceneController: sceneController);
            default:
              return Expanded(
                  child:
                      Text("No renderer selected", style: TextStyle(fontWeight: FontWeight.bold)));
          }
        });
  }

  //TODO onAppear, onDisappear

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
