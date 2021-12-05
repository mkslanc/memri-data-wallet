import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memri/MemriApp/CVU/CVUController.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/CVU/resolving/CVULookupController.dart';
import 'package:memri/MemriApp/Controllers/PageController.dart' as memri;
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
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
  late Future _init;

  late TextEditingController controller = TextEditingController();

  List<CVUParsedDefinition> definitions = [];

  @override
  initState() {
    super.initState();
    viewContext = widget.viewContext;
    _init = init();
  }

  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init = init();
  }

  init() async {
    definitions = [];
    var viewName = viewContext.viewDefinitionPropertyResolver
        .resolveString(viewContext.config.viewArguments?.args["viewName"]);
    var renderer = viewContext.viewDefinitionPropertyResolver
        .resolveString(viewContext.config.viewArguments?.args["renderer"]);

    CVUParsedDefinition? viewDefinition;
    if (viewName != null && viewName != "customView") {
      viewDefinition = viewContext.cvuController
          .definitionFor(type: CVUDefinitionType.view, viewName: viewName, exactSelector: true);

      var datasource = viewDefinition?.parsed.definitions
          .firstWhereOrNull((definition) => definition.type == CVUDefinitionType.datasource);
      var datasourceResolver = datasource?.parsed.propertyResolver(
          context: CVUContext(),
          lookup: CVULookupController(),
          db: widget.pageController.appController.databaseController);
      var itemTypes = await datasourceResolver?.stringArray("query");

      itemTypes?.forEach((itemType) {
        var nodeDefinition = viewContext.cvuController.definitionFor(
            type: CVUDefinitionType.uiNode, selector: itemType, rendererName: renderer);

        if (nodeDefinition != null) {
          definitions.add(nodeDefinition);
        }
      });
    } else {
      viewDefinition = viewContext.cvuController.definitionFor(
          type: CVUDefinitionType.view,
          selector: viewContext.focusedItem!.type,
          exactSelector: true);

      var nodeDefinition = viewContext.cvuController.definitionFor(
          type: CVUDefinitionType.uiNode,
          selector: viewContext.focusedItem?.type,
          rendererName: renderer);

      if (nodeDefinition != null) {
        definitions.add(nodeDefinition);
      }
    }

    if (viewDefinition != null) {
      definitions.add(viewDefinition);
    }

    var globalDefinition = viewContext.cvuController
            .definitionFor(type: CVUDefinitionType.renderer, rendererName: renderer) ??
        viewContext.cvuController
            .definitionFor(selector: "[renderer = $renderer]", type: CVUDefinitionType.renderer);

    if (globalDefinition != null) {
      definitions.add(globalDefinition);
    }

    if (definitions.isNotEmpty) {
      newCVU = definitions.map((node) => node.toCVUString(0, "    ", true)).join("\n\n");
    }

    controller.text = newCVU ?? "No cvu found to edit";
  }

  String? newCVU;

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
                onPressed: save,
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
              child: FutureBuilder(
            future: _init,
            builder: (context, snapshot) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                child: TextFormField(
                  decoration: InputDecoration(),
                  style: TextStyle(color: CVUColor.white),
                  controller: controller,
                  onChanged: (String newValue) async {
                    newCVU = newValue;
                  },
                  keyboardType: TextInputType.multiline,
                  minLines: 6,
                  maxLines: null,
                )),
          )),
        ],
      ),
    );
  }

  save() async {
    if (definitions.isNotEmpty) {
      var parsed = CVUController.parseCVUString(newCVU!);
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
