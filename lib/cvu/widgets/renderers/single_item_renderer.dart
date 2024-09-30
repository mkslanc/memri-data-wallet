import 'package:flutter/material.dart';
import 'package:memri/cvu/constants/cvu_color.dart';
import 'package:memri/cvu/widgets/renderers/renderer.dart';

class SingleItemRendererView extends Renderer {
  SingleItemRendererView({required viewContext})
      : super(viewContext: viewContext);

  @override
  _SingleItemRendererViewState createState() => _SingleItemRendererViewState();
}

class _SingleItemRendererViewState extends RendererViewState {
  EdgeInsets? insets;
  Color? backgroundColor;

  @override
  initState() {
    super.initState();
    init();
  }

  @override
  void didUpdateWidget(covariant Renderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(init);
  }

  @override
  dispose() {
    super.dispose();
  }

  void init() {
    insets = viewContext.rendererDefinitionPropertyResolver.edgeInsets ??
        EdgeInsets.fromLTRB(10, 10, 10, 10);
    backgroundColor =
        viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
            CVUColor.system("systemBackground");
    scrollable =
        viewContext.rendererDefinitionPropertyResolver.boolean("scrollable") ??
            true;
  }

  @override
  Widget build(BuildContext context) {
    var item = viewContext.focusedItem ?? viewContext.items.asMap()[0];
    Widget group;
    if (item != null) {
      group = viewContext.render(item: item, items: viewContext.items);
    } else {
      group = emptyResult ?? Center(child: Text("No item selected"));
    }
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
