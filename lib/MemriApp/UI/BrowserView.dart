import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/Controllers/PageController.dart' as memri;
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
  late final memri.PageController? pageController;

  BrowserView({required this.viewContext, this.pageController});

  @override
  _BrowserViewState createState() => _BrowserViewState();
}

class _BrowserViewState extends State<BrowserView> {
  late final ViewContextController viewContext;
  late final memri.PageController pageController;

  /// Keep track of whether the search bar is currently open (keyboard shown)
  bool _searchBarOpen = false;

  bool get searchBarOpen => _searchBarOpen;

  set searchBarOpen(bool newValue) => setState(() => _searchBarOpen = newValue);

  bool _filterPanelIsVisible = false;

  bool get filterPanelIsVisible => _filterPanelIsVisible;

  set filterPanelIsVisible(bool newValue) => setState(() => _filterPanelIsVisible = newValue);
  double filterPanelGestureOffset = 0;

  late final Future<String?> _title;

  @override
  initState() {
    super.initState();
    viewContext = widget.viewContext;
    pageController = widget.pageController ?? SceneController.sceneController.pageControllers.first;
    _title = widget.viewContext.viewDefinitionPropertyResolver.string("title");
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
        return ListRendererView(viewContext: viewContext, pageController: pageController);
      case "grid":
        return GridRendererView(viewContext: viewContext, pageController: pageController);
      case "map":
        return MapRendererView(viewContext: viewContext, pageController: pageController);
      case "timeline":
        return TimelineRendererView(viewContext: viewContext, pageController: pageController);
      case "calendar":
        return CalendarRendererView(viewContext: viewContext, pageController: pageController);
      case "photoviewer":
        return PhotoViewerRendererView(viewContext: viewContext, pageController: pageController);
      case "chart":
        return ChartRendererView(viewContext: viewContext, pageController: pageController);
      case "singleitem":
        return SingleItemRendererView(viewContext: viewContext, pageController: pageController);
      case "noteeditor":
        return NoteEditorRendererView(viewContext: viewContext, pageController: pageController);
      case "labelannotation":
        return LabelAnnotationRendererView(
            viewContext: viewContext, pageController: pageController);
      case "fileviewer":
        return FileRendererView(viewContext: viewContext, pageController: pageController);
      case "generaleditor":
        return GeneralEditorRendererView(viewContext: viewContext, pageController: pageController);
      default:
        return Expanded(
            child: Text(
          "No renderer selected",
          style: TextStyle(fontWeight: FontWeight.bold),
        ));
    }
  }

  Widget get topBarView => FutureBuilder<String?>(
      future: _title,
      builder: (context, snapshot) => snapshot.connectionState == ConnectionState.done
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: space(4, [
                      TextButton(
                          child: Icon(Icons.highlight_off),
                          onPressed: () => pageController.closeLastInStack()),
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
    pageController.addToStack(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.95, //TODO?
      child: Column(
        children: [
          topBarView,
          renderer,
          BottomBarView(
            viewContext: viewContext,
            pageController: pageController,
          ),
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
