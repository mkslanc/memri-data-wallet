import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';
import 'Renderer.dart';

class CustomRendererView extends Renderer {
  CustomRendererView({required pageController, required viewContext})
      : super(pageController: pageController, viewContext: viewContext);

  @override
  _CustomRendererViewState createState() => _CustomRendererViewState();
}

class _CustomRendererViewState extends RendererViewState {
  late Future _init;

  CVUDefinitionContent? get nodeDefinition {
    var viewDefinition;
    var viewName = viewContext.config.viewName;
    if (viewName != null) {
      viewDefinition = viewContext.cvuController.viewDefinitionFor(viewName: viewName);
    }

    return viewDefinition ??
        viewContext.config.viewDefinition.definitions
            .firstWhereOrNull((definition) =>
                definition.type == CVUDefinitionType.renderer && definition.name == "custom")
            ?.parsed;
  }

  Future init() async {
    scrollable = await viewContext.viewDefinitionPropertyResolver.boolean("scrollable") ?? true;
  }

  @override
  initState() {
    super.initState();
    _init = init();
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
      return FutureBuilder(
          future: _init,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (scrollable) {
                return CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: viewContext.render(
                          nodeDefinition: nodeDefinition, items: widget.viewContext.items),
                      fillOverscroll: false,
                    ),
                  ],
                );
              }
              return viewContext.render(
                  nodeDefinition: nodeDefinition, items: widget.viewContext.items);
            }
            return Empty();
          });
    }
  }
}
