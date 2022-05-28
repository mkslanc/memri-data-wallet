import 'package:flutter/material.dart';
import 'package:memri/controllers/scene_controller.dart';
import 'package:memri/models/cvu/cvu_value.dart';
import 'package:memri/models/cvu/cvu_value_constant.dart';
import 'package:memri/models/cvu/cvu_view_arguments.dart';
import 'package:memri/widgets/scene_view.dart';
import 'package:memri/widgets/empty.dart';
import 'package:memri/widgets/renderers/renderer.dart';

import '../../constants/cvu/cvu_color.dart';

class SceneViewRendererView extends Renderer {
  SceneViewRendererView({required pageController, required viewContext})
      : super(pageController: pageController, viewContext: viewContext);

  @override
  State<StatefulWidget> createState() => _SceneViewRendererViewState();
}

class _SceneViewRendererViewState extends RendererViewState {
  late SceneController _sceneController;
  late Future<void> _init;
  var pages = <Map<String, dynamic>>[];

  EdgeInsets? insets;
  Color backgroundColor = CVUColor.system("systemBackground");

  @override
  void initState() {
    super.initState();
    _init = init();
  }

  Future<void> init() async {
    insets = await viewContext.rendererDefinitionPropertyResolver.edgeInsets ??
        await viewContext.viewDefinitionPropertyResolver.edgeInsets ??
        EdgeInsets.all(0);
    backgroundColor = await viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
        await viewContext.viewDefinitionPropertyResolver.backgroundColor ??
        CVUColor.system("systemBackground");

    _sceneController = SceneController();
    _sceneController.parentSceneController = pageController.sceneController;
    _sceneController.parentSceneController!.subSceneControllers.add(_sceneController);
    var pageResolver = viewContext.rendererDefinitionPropertyResolver.subdefinition("pages");
    var viewArguments =
        viewContext.rendererDefinitionPropertyResolver.subdefinition("viewArguments");

    pageResolver?.properties.forEach((label, viewName) {
      pages.add({
        "label": label,
        "viewName": ((viewName as CVUValueConstant).value as CVUConstantString).value,
        "viewArguments": CVUViewArguments(
            args: viewArguments?.properties, parentArguments: viewContext.config.viewArguments),
        "targetItem": widget.viewContext.focusedItem
      }); //TODO resolve normally
    });
    if (pages.isEmpty) {
      return;
    }
    await _sceneController.init(pages);
  }

  @override
  void dispose() {
    super.dispose();
    _sceneController.reset();
  }

  @override
  void didUpdateWidget(covariant Renderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sceneController.scheduleUIUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) => snapshot.connectionState == ConnectionState.done
          ? pages.isEmpty
              ? Empty()
              : ColoredBox(
                  color: backgroundColor,
                  child: Padding(
                    padding: insets ?? const EdgeInsets.all(0),
                    child: SceneView(
                      sceneController: _sceneController,
                      showMainNavigation: false,
                    ),
                  ),
                )
          : Center(
              child: SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              ),
            ),
    );
  }
}
