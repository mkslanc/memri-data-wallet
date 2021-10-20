import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/PageController.dart' as memri;
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';

import '../ViewContextController.dart';

class SingleItemRendererView extends StatefulWidget {
  final memri.PageController pageController;
  final ViewContextController viewContext;

  SingleItemRendererView({required this.pageController, required this.viewContext});

  @override
  _SingleItemRendererViewState createState() => _SingleItemRendererViewState();
}

class _SingleItemRendererViewState extends State<SingleItemRendererView> {
  EdgeInsets? insets;

  Color? backgroundColor;

  late Future _init;

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

  Future init() async {
    insets = await widget.viewContext.rendererDefinitionPropertyResolver.edgeInsets ??
        EdgeInsets.fromLTRB(30, 0, 30, 0);
    backgroundColor = await widget.viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
        CVUColor.system("systemBackground");
  }

  CVUDefinitionContent? get nodeDefinition {
    CVUDefinitionContent? viewDefinition;
    var viewName = widget.viewContext.config.viewName;
    if (viewName != null) {
      viewDefinition = widget.viewContext.cvuController.viewDefinitionFor(viewName: viewName);
    }
    viewDefinition ??= widget.viewContext.config.viewDefinition;

    return viewDefinition.definitions
        .firstWhereOrNull((definition) => definition.selector == "[renderer = singleItem]")
        ?.parsed;
  }

  Widget? get emptyResult {
    var emptyResultDef = widget.viewContext.cvuController
        .viewDefinitionFor(
            viewName: widget.viewContext.config.viewName ?? widget.viewContext.config.rendererName)
        ?.properties["emptyResult"];

    var emptyResultSubdef = emptyResultDef?.getSubdefinition();
    if (emptyResultSubdef != null) {
      return widget.viewContext.render(nodeDefinition: emptyResultSubdef);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return ValueListenableBuilder(
              valueListenable: widget.viewContext.itemsValueNotifier,
              builder: (BuildContext context, List<ItemRecord> value, Widget? child) {
                var item = widget.viewContext.focusedItem ?? widget.viewContext.items.asMap()[0];
                Widget group;
                if (item != null) {
                  group = widget.viewContext.render(
                      item: item, items: widget.viewContext.items, nodeDefinition: nodeDefinition);
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
