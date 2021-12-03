import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/SceneView.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import 'Renderer.dart';

class SceneViewRendererView extends Renderer {
  SceneViewRendererView({required pageController, required viewContext})
      : super(pageController: pageController, viewContext: viewContext);

  @override
  State<StatefulWidget> createState() => _SceneViewRendererViewState();
}

class _SceneViewRendererViewState extends RendererViewState {
  late SceneController _sceneController;
  late Future<void> _init;
  var pages = <Map<String, String>>[];

  @override
  void initState() {
    super.initState();
    _init = init();
  }

  Future<void> init() async {
    _sceneController = SceneController();
    var pageResolver = viewContext.rendererDefinitionPropertyResolver.subdefinition("pages");

    pageResolver?.properties.forEach((label, viewName) {
      pages.add({
        "label": label,
        "viewName": ((viewName as CVUValueConstant).value as CVUConstantString).value
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
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) => snapshot.connectionState == ConnectionState.done
          ? pages.isEmpty
              ? Empty()
              : SceneView(
                  sceneController: _sceneController,
                  showMainNavigation: false,
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
