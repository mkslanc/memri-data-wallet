import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import '../ViewContextController.dart';

class CustomRendererView extends StatefulWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  CustomRendererView({required this.sceneController, required this.viewContext});

  @override
  _CustomRendererViewState createState() => _CustomRendererViewState();
}

class _CustomRendererViewState extends State<CustomRendererView> {
  late final ViewContextController viewContext;

  CVUDefinitionContent? get nodeDefinition {
    var viewName = viewContext.config.viewName;
    if (viewName == null) {
      return null;
    }

    return viewContext.cvuController.viewDefinitionFor(viewName: viewName);
  }

  @override
  initState() {
    super.initState();
    viewContext = widget.viewContext;
    widget.sceneController.addListener(updateState);
  }

  @override
  dispose() {
    super.dispose();
    widget.sceneController.removeListener(updateState);
  }

  updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (nodeDefinition == null) {
      return Expanded(child: Text("No view defined"));
    } else {
      return Expanded(child: viewContext.render(nodeDefinition: nodeDefinition));
    }
  }
}
