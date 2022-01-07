import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memri/MemriApp/CVU/CVUController.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUUIElementFamily.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUUINode.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/CVU/resolving/CVULookupController.dart';
import 'package:memri/MemriApp/Controllers/PageController.dart' as memri;
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';
import 'package:memri/MemriApp/UI/CVUComponents/CVUUINodeResolver.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import 'package:memri/MemriApp/UI/Components/AceEditor/AceEditor.dart';
import 'package:memri/MemriApp/UI/UIHelpers/ResetCVUToDefault.dart';

import '../ViewContextController.dart';

class CVUEditorRendererView extends StatefulWidget {
  final memri.PageController pageController;
  final ViewContextController viewContext;

  CVUEditorRendererView({required this.pageController, required this.viewContext});

  @override
  State<CVUEditorRendererView> createState() => _CVUEditorRendererViewState();
}

class _CVUEditorRendererViewState extends State<CVUEditorRendererView> {
  late final ViewContextController viewContext;
  late final AceEditorController controller;

  List<CVUParsedDefinition> definitions = [];

  @override
  initState() {
    super.initState();
    viewContext = widget.viewContext;
    controller = AceEditorController(saveCVU);
    initCVU();
  }

  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    initCVU();
  }

  Future<void> initCVU() async {
    definitions = [];
    var viewName = viewContext.viewDefinitionPropertyResolver
        .resolveString(viewContext.config.viewArguments?.args["viewName"]);
    var renderer = viewContext.viewDefinitionPropertyResolver
        .resolveString(viewContext.config.viewArguments?.args["renderer"]);

    await collectDefinitions(
        viewName: viewName, renderer: renderer, currentViewContext: viewContext);

    var cvuString =
        definitions.map((node) => node.toCVUString(0, "    ", true)).join("\n\n").nullIfBlank ??
            "No cvu found to edit";
    controller.updateEditorContent(cvuString);
  }

  collectDefinitions(
      {String? viewName,
      String? renderer,
      ViewContextController? currentViewContext,
      SceneController? sceneController,
      CVUDefinitionContent? subViewDefinition}) async {
    currentViewContext ??= viewContext;
    sceneController ??= widget.pageController.sceneController;
    viewName ??= currentViewContext.config.viewName;
    renderer ??= currentViewContext.config.rendererName;

    CVUParsedDefinition? viewDefinition;
    if (viewName != null && viewName != "customView") {
      viewDefinition = currentViewContext.cvuController
          .definitionFor(type: CVUDefinitionType.view, viewName: viewName, exactSelector: true);

      var datasource = (subViewDefinition ?? viewDefinition?.parsed)
          ?.definitions
          .firstWhereOrNull((definition) => definition.type == CVUDefinitionType.datasource);
      var datasourceResolver = datasource?.parsed.propertyResolver(
          context: CVUContext(),
          lookup: CVULookupController(),
          db: widget.pageController.appController.databaseController);
      var itemTypes = await datasourceResolver?.stringArray("query");

      await Future.forEach<String>(itemTypes ?? <String>[], (itemType) async {
        var nodeDefinition = currentViewContext!.cvuController.definitionFor(
            type: CVUDefinitionType.uiNode, selector: itemType, rendererName: renderer);

        if (nodeDefinition != null) {
          await addDefinition(nodeDefinition, viewContext, sceneController!);
        }
      });
    } else {
      viewDefinition = currentViewContext.cvuController.definitionFor(
          type: CVUDefinitionType.view,
          selector: currentViewContext.focusedItem!.type,
          exactSelector: true);

      var nodeDefinition = currentViewContext.cvuController.definitionFor(
          type: CVUDefinitionType.uiNode,
          selector: currentViewContext.focusedItem?.type,
          rendererName: renderer);

      if (nodeDefinition != null) {
        await addDefinition(nodeDefinition, viewContext, sceneController);
      }
    }

    if (viewDefinition != null) {
      if (renderer == "scene") {
        var subSceneRendererDefinition = currentViewContext.cvuController.definitionFor(
            selector: "[renderer = $renderer]",
            type: CVUDefinitionType.renderer,
            specifiedDefinitions: viewDefinition.parsed.definitions);
        if (subSceneRendererDefinition != null) {
          await collectSubSceneDefinitions(sceneController);
        }
      }

      await addDefinition(viewDefinition, viewContext, sceneController);
    }

    var globalDefinition = currentViewContext.cvuController
            .definitionFor(type: CVUDefinitionType.renderer, rendererName: renderer) ??
        currentViewContext.cvuController
            .definitionFor(selector: "[renderer = $renderer]", type: CVUDefinitionType.renderer);

    if (globalDefinition != null) {
      await addDefinition(globalDefinition, viewContext, sceneController);
    }
  }

  addDefinition(CVUParsedDefinition definition, ViewContextController currentViewContext,
      SceneController sceneController) async {
    definition.parsed.properties.forEach((key, value) {});

    await Future.forEach<CVUUINode>(definition.parsed.children,
        (node) async => await addSubViewDefinitions(node, viewContext, sceneController));

    definitions.add(definition);
  }

  addSubViewDefinitions(CVUUINode node, ViewContextController currentViewContext,
      SceneController sceneController) async {
    if (node.type == CVUUIElementFamily.SubView) {
      var nodeResolver = CVUUINodeResolver(
          context: CVUContext(),
          lookup: currentViewContext.lookupController,
          node: node,
          db: currentViewContext.databaseController,
          pageController: currentViewContext.pageController);

      var viewDefinition = nodeResolver.propertyResolver.value("view")?.getSubdefinition();
      if (viewDefinition == null) {
        return null;
      }

      var defaultRenderer = viewDefinition.properties["defaultRenderer"];
      String? rendererName;
      if (defaultRenderer is CVUValueConstant && defaultRenderer.value is CVUConstantArgument) {
        rendererName = (defaultRenderer.value as CVUConstantArgument).value;
      }

      var viewNameProp = viewDefinition.properties["viewName"];
      String? viewName;
      if (viewNameProp is CVUValueConstant && viewNameProp.value is CVUConstantArgument) {
        viewName = (viewNameProp.value as CVUConstantArgument).value;
      }

      if (rendererName == null) {
        return null;
      }

      await collectDefinitions(
          viewName: viewName,
          renderer: rendererName,
          currentViewContext: currentViewContext, //TODO maybe should be new viewContext:
          sceneController: sceneController,
          subViewDefinition: viewDefinition);
    } else {
      await Future.forEach<CVUUINode>(node.children,
          (subNode) async => await addSubViewDefinitions(subNode, viewContext, sceneController));
    }
  }

  collectSubSceneDefinitions(SceneController sceneController) async {
    await Future.forEach<SceneController>(sceneController.subSceneControllers,
        (subSceneController) async {
      await Future.forEach<memri.PageController>(subSceneController.pageControllers,
          (pageController) async {
        var subViewContext = pageController.topMostContext;
        await collectDefinitions(
            currentViewContext: subViewContext, sceneController: subSceneController);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CVUColor.black,
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Color(0xFFFE570F),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 13.5)),
                onPressed: controller.requestEditorData,
                child: Text(
                  "Save view",
                  style: TextStyle(color: CVUColor.white),
                ),
              ),
              TextButton(
                onPressed: close,
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Color(0xFF989898)),
                ),
              ),
              TextButton(
                  onPressed: () => resetCVUToDefault(context, widget.pageController, definitions),
                  child:
                      SvgPicture.asset("assets/images/rotate_ccw.svg", color: Color(0xFFFE570F))),
              TextButton(
                  onPressed: close,
                  child: SvgPicture.asset("assets/images/ico_close.svg", color: Color(0xFF989898))),
            ],
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
            child: AceEditor(controller),
          )),
        ],
      ),
    );
  }

  saveCVU() async {
    if (definitions.isNotEmpty) {
      var parsed = CVUController.parseCVUString(controller.content);
      await Future.forEach<CVUParsedDefinition>(parsed, (node) async {
        var definition = viewContext.cvuController.definitionFor(
            type: node.type,
            selector: node.selector,
            rendererName: node.renderer,
            viewName: node.name,
            specifiedDefinitions: definitions);
        if (definition != null) {
          await widget.pageController.appController.cvuController
              .updateDefinition(definition, node.parsed);
        }
      });
    }
    widget.pageController.sceneController.scheduleUIUpdate();
  }

  close() {
    widget.pageController.sceneController.pageControllers.first.topMostContext?.config.cols = null;
    widget.pageController.sceneController.removePageController(widget.pageController);
  }
}
