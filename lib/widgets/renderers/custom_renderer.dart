import 'package:flutter/material.dart';
import 'package:memri/constants/cvu/cvu_color.dart';
import 'package:memri/core/models/cvu/cvu_parsed_definition.dart';
import 'package:memri/utilities/extensions/collection.dart';
import 'package:memri/widgets/empty.dart';
import 'package:memri/widgets/renderers/renderer.dart';

class CustomRendererView extends Renderer {
  CustomRendererView({required pageController, required viewContext})
      : super(pageController: pageController, viewContext: viewContext);

  @override
  _CustomRendererViewState createState() => _CustomRendererViewState();
}

class _CustomRendererViewState extends RendererViewState {
  late Future _init;
  EdgeInsets? insets;
  Color? backgroundColor;

  CVUDefinitionContent? get nodeDefinition {
    var viewDefinition;
    var viewName = viewContext.config.viewName;
    if (viewName != null) {
      viewDefinition =
          viewContext.cvuController.viewDefinitionFor(viewName: viewName);
    }

    return viewDefinition ??
        viewContext.config.viewDefinition.definitions
            .firstWhereOrNull((definition) =>
                definition.type == CVUDefinitionType.renderer &&
                definition.name == "custom")
            ?.parsed;
  }

  Future init() async {
    insets = await viewContext.rendererDefinitionPropertyResolver.edgeInsets ??
        await viewContext.viewDefinitionPropertyResolver.edgeInsets ??
        EdgeInsets.all(0);
    backgroundColor =
        await viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
            await viewContext.viewDefinitionPropertyResolver.backgroundColor ??
            CVUColor.system("systemBackground");
    scrollable = await viewContext.viewDefinitionPropertyResolver
            .boolean("scrollable") ??
        true;
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
              var group = viewContext.render(
                  nodeDefinition: nodeDefinition,
                  items: widget.viewContext.items);
              if (insets != null) {
                group = Padding(
                  padding: insets!,
                  child: group,
                );
              }
              if (backgroundColor != null) {
                group = ColoredBox(
                  color: backgroundColor!,
                  child: group,
                );
              }
              if (scrollable) {
                return CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: group,
                      fillOverscroll: false,
                    ),
                  ],
                );
              }
              return group;
            }
            return Empty();
          });
    }
  }
}
