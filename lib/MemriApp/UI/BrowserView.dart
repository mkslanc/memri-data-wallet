import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/Chrome/BottomBarView.dart';

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

import 'FilterPanel/FilterPanelView.dart';

import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

class BrowserView extends StatefulWidget {
  final ViewContextController viewContext;
  final SceneController? sceneController;

  BrowserView({required this.viewContext, this.sceneController});

  @override
  _BrowserViewState createState() => _BrowserViewState();
}

class _BrowserViewState extends State<BrowserView> {
  late final ViewContextController viewContext;
  late final SceneController sceneController;

  /// Keep track of whether the search bar is currently open (keyboard shown)
  bool _searchBarOpen = false;

  bool get searchBarOpen => _searchBarOpen;

  set searchBarOpen(bool newValue) => setState(() => _searchBarOpen = newValue);

  bool _filterPanelIsVisible = false;

  bool get filterPanelIsVisible => _filterPanelIsVisible;

  set filterPanelIsVisible(bool newValue) => setState(() => _filterPanelIsVisible = newValue);
  double filterPanelGestureOffset = 0;

  @override
  initState() {
    super.initState();
    viewContext = widget.viewContext;
    sceneController = widget.sceneController ?? SceneController.sceneController;
    viewContext.onAppear();
  }

  @override
  dispose() {
    super.dispose();
    viewContext.onDisappear();
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
      case "fileviewer":
        return FileRendererView(viewContext: viewContext, sceneController: sceneController);
      case "generaleditor":
        return GeneralEditorRendererView(
            viewContext: viewContext, sceneController: sceneController);
      default:
        return Expanded(
            child: Text(
          "No renderer selected",
          style: TextStyle(fontWeight: FontWeight.bold),
        ));
    }
  }

  Widget get topBarView => FutureBuilder<String?>(
      future: widget.viewContext.viewDefinitionPropertyResolver.string("title"),
      builder: (context, snapshot) => snapshot.connectionState == ConnectionState.done
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: space(4, [
                      TextButton(
                          child: Icon(Icons.highlight_off),
                          onPressed: () => sceneController.closeLastInStack()),
                      if (snapshot.hasData) ...[
                        Spacer(),
                        Text(snapshot.data!,
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                        Spacer()
                      ]
                    ]),
                  ),
                ),
                Divider()
              ],
            )
          : Empty());

  @override
  Widget build(BuildContext context) {
    sceneController.addToStack(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.95, //TODO?
      child: Column(
        children: [
          topBarView,
          renderer,
          BottomBarView(viewContext: viewContext, onSearchPressed: () => searchBarOpen = true),
          if (filterPanelIsVisible) ...[
            GestureDetector(
              child: ColoredBox(
                color: Colors.black.withOpacity(0.15),
              ),
              onTap: () => filterPanelIsVisible = false,
              //TODO DragGesture
            ),
            Column(
              children: [
                //TODO Capsule
                FilterPanelView(
                  viewContext: viewContext,
                )
              ],
            )
          ]
        ],
      ),
    );
  }
}
