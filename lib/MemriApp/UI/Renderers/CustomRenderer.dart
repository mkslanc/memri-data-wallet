import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'Renderer.dart';

class CustomRendererView extends Renderer {
  CustomRendererView({required pageController, required viewContext})
      : super(pageController: pageController, viewContext: viewContext);

  @override
  _CustomRendererViewState createState() => _CustomRendererViewState();
}

class _CustomRendererViewState extends RendererViewState {
  CVUDefinitionContent? get nodeDefinition {
    var viewDefinition;
    var viewName = viewContext.config.viewName;
    if (viewName != null) {
      viewDefinition = viewContext.cvuController.viewDefinitionFor(viewName: viewName);
    }

    return viewDefinition ?? viewContext.config.viewDefinition.definitions.asMap()[0]?.parsed;
  }

  @override
  initState() {
    super.initState();
    widget.pageController.addListener(updateState);
  }

  @override
  dispose() {
    super.dispose();
    widget.pageController.removeListener(updateState);
  }

  updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (nodeDefinition == null) {
      return Text("No view defined");
    } else {
      return viewContext.render(nodeDefinition: nodeDefinition);
    }
  }
}
