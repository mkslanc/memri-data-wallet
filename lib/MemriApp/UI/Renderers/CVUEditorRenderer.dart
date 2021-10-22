import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/parsing/CVULexer.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUParser.dart';
import 'package:memri/MemriApp/Controllers/PageController.dart' as memri;

import '../ViewContextController.dart';

class CVUEditorRendererView extends StatelessWidget {
  final memri.PageController pageController;
  final ViewContextController viewContext;

  CVUEditorRendererView({required this.pageController, required this.viewContext});

  TextEditingController get controller => TextEditingController(text: currentCVU);
  CVUParsedDefinition? node;

  String get currentCVU {
    var viewName = viewContext.viewDefinitionPropertyResolver
        .resolveString(viewContext.config.viewArguments?.args["viewName"]);
    var renderer = viewContext.viewDefinitionPropertyResolver
        .resolveString(viewContext.config.viewArguments?.args["renderer"]);
    node = viewContext.cvuController.definitionFor(
        type: CVUDefinitionType.uiNode,
        selector: viewContext.focusedItem?.type,
        viewName: (viewName != null && viewName != "customView") ? viewName : null,
        rendererName: renderer);
    /*if (viewContext.focusedItem != null) {
      node = viewContext.cvuController.nodeDefinitionForItem(
          item: viewContext.focusedItem!,
          renderer: viewContext.viewDefinitionPropertyResolver
              .resolveString(viewContext.config.viewArguments?.args["renderer"]));
    } else {
      node = viewContext.cvuController.nodeDefinitionForItem(
          item: viewContext.focusedItem!,
          renderer: viewContext.viewDefinitionPropertyResolver
              .resolveString(viewContext.config.viewArguments?.args["renderer"]));
    }
*/
    return node!.toCVUString(0, "    ", true);
  }

  String? newCVU;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 44),
        child: Column(
          children: [
            Expanded(
                child: TextFormField(
              //style: widget.style,
              decoration: InputDecoration(
                  //border: InputBorder,
                  ),
              controller: controller,
              onChanged: (String newValue) async {
                newCVU = newValue;
              },
              keyboardType: TextInputType.multiline,
              minLines: 6,
              maxLines: null,
            )),
            TextButton(
              onPressed: () {
                var lexer = CVULexer(newCVU!);
                var tokens = lexer.tokenize();
                var parser = CVUParser(tokens);
                var nodes = parser.parse();
                node?.parsed = nodes[0].parsed;
                viewContext.pageController.navigateBack();
              },
              child: Text("Save"),
            ),
          ],
        ));
  }
}
