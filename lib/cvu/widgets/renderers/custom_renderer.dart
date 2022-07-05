import 'package:flutter/material.dart';
import 'package:memri/cvu/constants/cvu_color.dart';
import 'package:memri/cvu/models/cvu_parsed_definition.dart';
import 'package:memri/utilities/extensions/collection.dart';
import 'package:memri/cvu/widgets/renderers/renderer.dart';

class CustomRendererView extends Renderer {
  CustomRendererView({required viewContext}) : super(viewContext: viewContext);

  @override
  _CustomRendererViewState createState() => _CustomRendererViewState();
}

class _CustomRendererViewState extends RendererViewState {
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

  void init() {
    insets = viewContext.rendererDefinitionPropertyResolver.edgeInsets ??
        viewContext.viewDefinitionPropertyResolver.edgeInsets ??
        EdgeInsets.all(0);
    backgroundColor =
        viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
            viewContext.viewDefinitionPropertyResolver.backgroundColor ??
            CVUColor.system("systemBackground");
    scrollable =
        viewContext.viewDefinitionPropertyResolver.boolean("scrollable") ??
            false;
  }

  @override
  initState() {
    super.initState();
    init();
  }

  @override
  void didUpdateWidget(covariant Renderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() => init());
  }

  @override
  Widget build(BuildContext context) {
    if (nodeDefinition == null) {
      return Text("No view defined");
    } else {
      var group = viewContext.render(
          nodeDefinition: nodeDefinition, items: widget.viewContext.items);
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
  }
}
