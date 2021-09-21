import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/Controllers/PageController.dart' as memri;

import '../ViewContextController.dart';

class CustomRendererView extends StatefulWidget {
  final memri.PageController pageController;
  final ViewContextController viewContext;

  CustomRendererView({required this.pageController, required this.viewContext});

  @override
  _CustomRendererViewState createState() => _CustomRendererViewState();
}

class _CustomRendererViewState extends State<CustomRendererView> {
  late final ViewContextController viewContext;

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
    viewContext = widget.viewContext;
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
