import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/controllers/cvu_controller.dart';
import 'package:memri/controllers/cvu_lookup_controller.dart';
import 'package:memri/controllers/page_controller.dart' as memri;
import 'package:memri/controllers/scene_controller.dart';
import 'package:memri/controllers/view_context_controller.dart';
import 'package:memri/core/cvu/parsing/cvu_parse_errors.dart';
import 'package:memri/core/cvu/parsing/cvu_validator.dart';
import 'package:memri/core/cvu/resolving/cvu_context.dart';
import 'package:memri/models/cvu/cvu_parsed_definition.dart';
import 'package:memri/models/cvu/cvu_ui_element_family.dart';
import 'package:memri/models/cvu/cvu_ui_node.dart';
import 'package:memri/models/cvu/cvu_value.dart';
import 'package:memri/models/cvu/cvu_value_constant.dart';
import 'package:memri/utils/app_helper.dart';
import 'package:memri/utils/extensions/collection.dart';
import 'package:memri/utils/extensions/enum.dart';
import 'package:memri/utils/extensions/string.dart';
import 'package:memri/utils/reset_cvu_to_default.dart';
import 'package:memri/widgets/components/ace_editor/ace_editor.dart';
import 'package:memri/widgets/components/cvu/cvu_ui_node_resolver.dart';

import '../../controllers/database_query.dart';
import '../../core/apis/pod/pod_connection_details.dart';
import '../../core/apis/pod/pod_requests.dart';
import '../../core/cvu/cvu_action.dart';
import '../../models/view_context.dart';

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

  late Future<void> _init;
  late String mode;
  CVUDefinitionContent? buttons;
  CVUAction? overrideResetAction;
  bool logMode = false;
  bool allowLogMode = false;
  StreamSubscription? logsStream;

  List<CVUParsedDefinition> definitions = [];

  @override
  initState() {
    super.initState();
    viewContext = widget.viewContext;
    controller = AceEditorController(saveCVU, validate: validate);
    _init = init();
  }

  @override
  dispose() {
    super.dispose();
    logsStream?.cancel();
    logsStream = null;
  }

  Future<void> init() async {
    mode = await viewContext.viewDefinitionPropertyResolver.string("mode") ?? "inMainPage";
    if (viewContext.focusedItem?.type == "Plugin") {
      allowLogMode = true;
    }

    var customDefinition = await viewContext.viewDefinitionPropertyResolver
        .resolveString(viewContext.config.viewArguments?.args["customDefinition"]);

    var buttonsArg = viewContext.config.viewArguments?.args["buttons"];
    buttons = buttonsArg?.getSubdefinition();
    overrideResetAction = viewContext.viewDefinitionPropertyResolver.action(
        "overrideResetAction", viewContext.config.viewArguments?.args["overrideResetAction"]);

    if (customDefinition != null) {
      definitions = (await CVUController.parseCVU(customDefinition)).compactMap(
          (definition) => viewContext.cvuController.definitionByQuery(definition.queryStr));
    } else {
      await initDefinitions();
    }
    if (!logMode) initCVU();
  }

  getLogs(PodConnectionDetails connection, String id) async {
    if (id == "") {
      controller.updateEditorContent("Please, start plugin before trying to access logs");
    } else {
      var request = PodStandardRequest.getLogsForPluginRun(id);
      var networkCall = await request.execute(connection);
      if (networkCall.statusCode != 200) {
        controller.updateEditorContent(
            networkCall.statusCode.toString() + ' ' + networkCall.reasonPhrase!);
      } else {
        var logs = Utf8Decoder().convert(networkCall.bodyBytes);
        var decodedLogs = jsonDecode(logs);
        controller.updateEditorContent(decodedLogs["logs"]);
      }
    }
  }

  setLogMode() async {
    var currentConnection = await widget.pageController.appController.podConnectionConfig;
    var pluginRuns = (await viewContext.focusedItem!.reverseEdgeItems("plugin"));
    controller.updateEditorContent("Loading...");
    setState(() {
      logMode = true;

      if (logsStream == null)
        logsStream = Stream.periodic(const Duration(seconds: 3)).listen(
            (_) => getLogs(currentConnection!, pluginRuns.isNotEmpty ? pluginRuns.last.uid : ""));
    });
  }

  setCVUMode() {
    setState(() {
      logMode = false;
      logsStream?.cancel();
      logsStream = null;
      initCVU();
    });
  }

  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init = init();
  }

  Future<List<Map<String, dynamic>>> validate(content) async {
    List<CVUParsedDefinition> parsed = <CVUParsedDefinition>[];
    try {
      parsed = CVUController.parseCVUString(content);
    } on CVUParseErrors catch (error) {
      var errorString = error.toErrorString(content);
      var resultErrorString = errorString.substring(0, min(100, errorString.length));
      if (resultErrorString != errorString) resultErrorString += "...";
      return [
        {
          "type": "error",
          "row": error.token.ln,
          "column": error.token.ch,
          "text": resultErrorString
        }
      ];
    }

    var validator = CVUValidator(
        lookupController: CVULookupController(),
        databaseController: widget.pageController.appController.databaseController);
    await validator.validate(parsed);

    return (validator.errors + validator.warnings)
        .map((annotation) => {
              "type": annotation.type.inString,
              "row": annotation.row,
              "column": annotation.column,
              "text": annotation.message
            })
        .toList();
  }

  initDefinitions() async {
    definitions = [];
    var sceneController = widget.pageController.sceneController;
    for (var pageController in sceneController.pageControllers) {
      if (pageController == widget.pageController) {
        continue;
      }

      var viewContext = pageController.topMostContext!;

      await collectDefinitions(currentViewContext: viewContext, sceneController: sceneController);
    }
  }

  initCVU() {
    var cvuString =
        definitions.map((node) => node.toCVUString(0, "    ", true)).join("\n\n").nullIfBlank ??
            "No cvu found to edit";
    controller.updateEditorContent(cvuString);
  }

  collectDefinitions(
      {String? viewName,
      String? renderer,
      required ViewContextController currentViewContext,
      required SceneController sceneController,
      CVUDefinitionContent? subViewDefinition}) async {
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
        var nodeDefinition = currentViewContext.cvuController.definitionFor(
            type: CVUDefinitionType.uiNode, selector: itemType, rendererName: renderer);

        if (nodeDefinition != null) {
          await addDefinition(nodeDefinition, viewContext, sceneController);
        }
      });
    } else if (currentViewContext.focusedItem != null) {
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
    } else if (subViewDefinition != null) {
      await collectSubViewDefinitions(subViewDefinition, currentViewContext, sceneController);
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

    await collectSubViewDefinitions(definition.parsed, currentViewContext, sceneController);

    definitions.add(definition);
  }

  collectSubViewDefinitions(CVUDefinitionContent definition,
      ViewContextController currentViewContext, SceneController sceneController) async {
    for (var node in definition.children) {
      await addSubViewDefinitions(node, viewContext, sceneController);
    }
    for (var subDefinition in definition.definitions) {
      if ((subDefinition.type == CVUDefinitionType.uiNode ||
              subDefinition.type == CVUDefinitionType.renderer) &&
          subDefinition.parsed.children.isNotEmpty) {
        await addSubViewDefinitions(
            subDefinition.parsed.children.first, viewContext, sceneController);
      }
    }
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

      var newViewContext = ViewContextController(
          config: ViewContextHolder(ViewContext(
              viewName: viewName,
              pageLabel: "",
              rendererName: rendererName,
              viewDefinition: viewDefinition,
              query: DatabaseQueryConfig())),
          pageController: widget.pageController);

      await collectDefinitions(
          viewName: viewName,
          renderer: rendererName,
          currentViewContext: newViewContext,
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
        await collectDefinitions(
            currentViewContext: pageController.topMostContext!,
            sceneController: subSceneController);
      });
    });
  }

  renderButtons() {
    if (buttons != null) {
      return viewContext.render(
          nodeDefinition: buttons, item: viewContext.focusedItem, items: viewContext.items);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) => Container(
        color: Color(0xff333333),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (!logMode)
                          TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Color(0xFFFE570F),
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 13.5)),
                            onPressed: controller.requestEditorData,
                            child: Text(
                              "Save view",
                              style: CVUFont.link.copyWith(color: Color(0xffF5F5F5)),
                            ),
                          ),
                        if (logMode)
                          TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Color(0xFF333333),
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 13.5)),
                            onPressed: setCVUMode,
                            child: Text(
                              "Configure UI",
                              style: CVUFont.link.copyWith(color: Color(0xffE9500F)),
                            ),
                          ),
                        SizedBox(width: 10),
                        if (!logMode)
                          TextButton(
                            onPressed: close,
                            child: Text(
                              "Cancel",
                              style: CVUFont.link.copyWith(color: Color(0xFF989898)),
                            ),
                          ),
                        Spacer(),
                        if (!logMode)
                          TextButton(
                              onPressed: () => resetCVUToDefault(context, widget.pageController,
                                  cvuContext: CVUContext(
                                      currentItem: widget.viewContext.focusedItem,
                                      items: widget.viewContext.items),
                                  definitions: definitions,
                                  action: overrideResetAction),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                runAlignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 10,
                                children: [
                                  app.icons.rotateCCW(color: app.colors.primary),
                                  Text("Reset to default",
                                      style: CVUFont.tabList.copyWith(color: app.colors.primary)),
                                ],
                              )),
                      ],
                    ),
                  ),
                ),
                if (buttons != null || allowLogMode)
                  Container(
                      constraints: BoxConstraints(minHeight: 60),
                      padding: EdgeInsets.all(10),
                      color: Color(0xff202020),
                      child: Wrap(spacing: 10, children: [
                        if (allowLogMode)
                          TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Color(0xff202020),
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 13.5)),
                            onPressed: () async => await setLogMode(),
                            child: Text(
                              "Log",
                              style: CVUFont.link.copyWith(color: Color(0xff7B81FF)),
                            ),
                          ),
                        if (buttons != null) renderButtons(),
                      ]))
              ],
            ),
            Expanded(child: AceEditor(controller)),
          ],
        ),
      ),
    );
  }

  saveCVU() async {
    if (definitions.isNotEmpty) {
      await widget.pageController.appController.cvuController
          .updateDefinition(content: controller.content);
    }
    widget.pageController.sceneController.scheduleUIUpdate();
  }

  close() {
    if (mode == "inMainPage") {
      widget.pageController.sceneController.removePageController(widget.pageController);
    } else {
      widget.pageController.navigateBack();
    }
  }
}
