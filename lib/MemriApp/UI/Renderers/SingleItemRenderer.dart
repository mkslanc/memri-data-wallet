import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';
import 'package:memri/MemriApp/UI/Renderers/Renderer.dart';

class SingleItemRendererView extends Renderer {
  SingleItemRendererView({required pageController, required viewContext})
      : super(pageController: pageController, viewContext: viewContext);

  @override
  _SingleItemRendererViewState createState() => _SingleItemRendererViewState();
}

class _SingleItemRendererViewState extends RendererViewState {
  EdgeInsets? insets;

  Color? backgroundColor;

  late Future _init;

  @override
  initState() {
    super.initState();
    _init = init();
    pageController.addListener(updateState);
  }

  @override
  dispose() {
    super.dispose();
    pageController.removeListener(updateState);
  }

  updateState() {
    setState(() {});
  }

  Future init() async {
    insets = await viewContext.rendererDefinitionPropertyResolver.edgeInsets ??
        EdgeInsets.fromLTRB(30, 0, 30, 0);
    backgroundColor = await viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
        CVUColor.system("systemBackground");
  }

  CVUDefinitionContent? get nodeDefinition {
    CVUDefinitionContent? viewDefinition;
    var viewName = viewContext.config.viewName;
    if (viewName != null) {
      viewDefinition = viewContext.cvuController.viewDefinitionFor(viewName: viewName);
    }
    viewDefinition ??= viewContext.config.viewDefinition;

    return viewDefinition.definitions
        .firstWhereOrNull((definition) => definition.selector == "[renderer = singleItem]")
        ?.parsed;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return ValueListenableBuilder(
              valueListenable: viewContext.itemsValueNotifier,
              builder: (BuildContext context, List<ItemRecord> value, Widget? child) {
                var item = viewContext.focusedItem ?? viewContext.items.asMap()[0];
                Widget group;
                if (item != null) {
                  group = viewContext.render(
                      item: item, items: viewContext.items, nodeDefinition: nodeDefinition);
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
                  ColoredBox(
                    color: backgroundColor!,
                    child: group,
                  );
                }

                return CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: group,
                      fillOverscroll: false,
                    ),
                  ],
                );
              });
        });
  }
}
