import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';
import 'package:memri/MemriApp/Controllers/PageController.dart' as memri;
import 'package:memri/MemriApp/UI/Components/PluginModeSwitcher.dart';
import 'package:uuid/uuid.dart';

import '../ViewContextController.dart';

/// The list renderer
/// This presents the data in a list (aka tableView)
class ListRendererView extends StatefulWidget {
  final memri.PageController pageController;
  final ViewContextController viewContext;

  ListRendererView({required this.pageController, required this.viewContext});

  @override
  _ListRendererViewState createState() => _ListRendererViewState();
}

class _ListRendererViewState extends State<ListRendererView> {
  late final memri.PageController pageController;
  late final ViewContextController viewContext;

  late EdgeInsets insets;
  late Point spacing;
  late Color backgroundColor;
  late bool separatorsEnabled;
  late bool isInEditMode;
  late bool isReverse;
  bool isDismissible = false;

  late Binding<Set<int>> selectedIndicesBinding;
  late Set<int> selectedIndices;

  late Future _init;

  initState() {
    super.initState();
    pageController = widget.pageController;
    viewContext = widget.viewContext;
    _init = init();

    pageController.isInEditMode.addListener(updateIsInEditMode);
  }

  updateIsInEditMode() async {
    await initEditMode();
    setState(() {});
  }

  dispose() {
    super.dispose();
    pageController.isInEditMode.removeListener(updateIsInEditMode);
  }

  Future<void> init() async {
    insets = await viewContext.rendererDefinitionPropertyResolver.edgeInsets ??
        EdgeInsets.only(top: 0, left: 30, bottom: 0, right: 30);
    spacing = await viewContext.rendererDefinitionPropertyResolver.spacing ?? Point(10, 10);
    backgroundColor = await viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
        CVUColor.system("systemBackground");
    separatorsEnabled =
        !(await viewContext.rendererDefinitionPropertyResolver.boolean("hideSeparators", false))!;
    isReverse = (await viewContext.rendererDefinitionPropertyResolver.boolean("isReverse", false))!;

    await initEditMode();
  }

  Future<void> initEditMode() async {
    isInEditMode = (await viewContext.viewDefinitionPropertyResolver
        .boolean("editMode", pageController.isInEditMode.value))!;

    selectedIndicesBinding = viewContext.selectedIndicesBinding;
    selectedIndices = selectedIndicesBinding.get();
  }

  Widget? get additional {
    var additionalDef = viewContext.cvuController
        .viewDefinitionFor(viewName: viewContext.config.viewName ?? viewContext.config.rendererName)
        ?.properties["additional"];

    var additionalSubdef = additionalDef?.getSubdefinition();
    if (additionalSubdef != null) {
      return viewContext.render(nodeDefinition: additionalSubdef);
    }
    return null;
  }

  Widget? get emptyResult {
    var emptyResultDef = viewContext.cvuController
        .viewDefinitionFor(viewName: viewContext.config.viewName ?? viewContext.config.rendererName)
        ?.properties["emptyResult"];

    var emptyResultSubdef = emptyResultDef?.getSubdefinition();
    if (emptyResultSubdef != null) {
      return viewContext.render(nodeDefinition: emptyResultSubdef);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ValueListenableBuilder(
              valueListenable: viewContext.itemsValueNotifier,
              builder: (context, value, child) {
                if (viewContext.items.isNotEmpty) {
                  selectedIndices = selectedIndicesBinding.get();
                  var lastIndex = viewContext.items.length - 1;
                  var elements = List<Widget>.from(viewContext.items
                      .mapIndexed((index, item) =>
                          [_buildItem(item, index), if (index < lastIndex) _buildSeparator()])
                      .expand((element) => element));

                  if (additional != null) {
                    elements.insert(0, _buildSeparator());
                    elements.insertAll(0, [
                      _buildSeparator(),
                      ListTile(
                        key: Key(Uuid().v4()),
                        dense: true,
                        minVerticalPadding: 0,
                        visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                        contentPadding:
                            EdgeInsets.fromLTRB(insets.left, 0, insets.right, spacing.y / 2),
                        title: additional!,
                      )
                    ]);
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        setState(() => pageController.topMostContext?.setupQueryObservation()),
                    child: ListView.custom(
                      reverse: isReverse,
                      shrinkWrap: true,
                      padding: EdgeInsets.fromLTRB(
                          0,
                          pageController.showTopBar ? insets.top : insets.top + 80,
                          0,
                          insets.bottom),
                      childrenDelegate: SliverChildListDelegate(elements),
                    ),
                    //TODO with large data ListView.custom will lag, should open ListView.separated and delete ListView.custom as soon as this issue is solved: https://github.com/flutter/flutter/issues/21023
                    /*child: ListView.separated(
                      shrinkWrap: true,
                      // physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: EdgeInsets.fromLTRB(0, insets.top, 0, insets.bottom),
                      itemBuilder: (context, index) {
                        var item = viewContext.items[index];
                        return _buildItem(item, index);
                      },
                      separatorBuilder: (context, index) => _buildSeparator(),
                      itemCount: viewContext.items.length)*/
                  );
                } else {
                  List<Widget> elements = [];
                  if (additional != null) {
                    elements.insertAll(0, [
                      _buildSeparator(),
                      ListTile(
                        key: Key(Uuid().v4()),
                        dense: true,
                        minVerticalPadding: 0,
                        visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                        contentPadding:
                            EdgeInsets.fromLTRB(insets.left, 0, insets.right, spacing.y / 2),
                        title: additional!,
                      )
                    ]);
                  }
                  return Column(
                    children: [
                      if (elements.isNotEmpty)
                        ListView.custom(
                          shrinkWrap: true,
                          padding: EdgeInsets.fromLTRB(
                              0,
                              pageController.showTopBar ? insets.top : insets.top + 80,
                              0,
                              insets.bottom),
                          childrenDelegate: SliverChildListDelegate(elements),
                        ),
                      emptyResult ??
                          Padding(
                            padding: EdgeInsets.all(30),
                            child: Center(
                              child: Text(
                                "No items",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Color.fromRGBO(0, 0, 0, 0.7),
                                    backgroundColor: backgroundColor),
                              ),
                            ),
                          ),
                    ],
                  );
                }
              },
            );
          } else {
            return SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            );
          }
        });
  }

  Widget _buildItem(ItemRecord item, int index) {
    var title = ColoredBox(
        key: Key(item.uid), color: backgroundColor, child: viewContext.render(item: item));
    var callback = selectionMode(index);
    Widget tile = isInEditMode
        ? CheckboxListTile(
            key: Key(item.uid),
            dense: true,
            title: title,
            onChanged: callback,
            value: selectedIndices.contains(index),
            controlAffinity: ListTileControlAffinity.leading)
        : ListTile(
            key: Key(item.uid),
            dense: true,
            minVerticalPadding: 0,
            visualDensity: VisualDensity(horizontal: -2, vertical: -2),
            contentPadding: EdgeInsets.fromLTRB(insets.left, index == 0 ? 0 : spacing.y / 2,
                insets.right, index == viewContext.items.length - 1 ? 0 : spacing.y / 2),
            title: title,
            onTap: callback,
          );
    if (isDismissible) {
      tile = Dismissible(
          direction: DismissDirection.endToStart,
          key: Key(item.uid),
          onDismissed: (direction) async {
            var action = CVUActionDelete();
            await action
                .execute(pageController, viewContext.getCVUContext(item: item))
                .then((value) => viewContext.setupQueryObservation());
          },
          child: tile);
    }

    //TODO: hardcoded part for now, we could migrate this to cvu, when switches will allow to use different actions instead of bindings
    if (widget.pageController.appController.isDevelopersMode && item.type == "Plugin") {
      tile = Column(children: [PluginModeSwitcher(item), tile]);
    }

    return tile;
  }

  _buildSeparator() => Padding(
        padding: EdgeInsets.fromLTRB(insets.left, 0, insets.right, 0),
        child: Divider(
          height: separatorsEnabled ? 1 : 0,
          color: separatorsEnabled ? null : Colors.transparent,
        ),
      );

  selectionMode(index) {
    if (isInEditMode) {
      return (bool? newValue) {
        setState(() {
          if (!selectedIndices.remove(index)) {
            selectedIndices.add(index);
          }
          selectedIndicesBinding.set(selectedIndices);
        });
      };
    } else {
      return () {
        var item = viewContext.items.asMap()[index];

        if (item != null) {
          var presses = viewContext.rendererDefinitionPropertyResolver.actions("onPress") ??
              viewContext.nodePropertyResolver(item)?.actions("onPress");
          if (presses != null) {
            presses.forEach((press) async =>
                await press.execute(pageController, viewContext.getCVUContext(item: item)));
          }
        }
      };
    }
  }
}
