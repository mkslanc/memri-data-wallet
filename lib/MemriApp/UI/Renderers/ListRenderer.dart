import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';
import 'package:memri/MemriApp/UI/Components/PluginModeSwitcher.dart';
import 'package:memri/MemriApp/UI/Renderers/Renderer.dart';
import 'package:uuid/uuid.dart';

/// The list renderer
/// This presents the data in a list (aka tableView)
class ListRendererView extends Renderer {
  ListRendererView({required pageController, required viewContext})
      : super(pageController: pageController, viewContext: viewContext);

  @override
  _ListRendererViewState createState() => _ListRendererViewState();
}

class _ListRendererViewState extends RendererViewState {
  late EdgeInsets insets;
  late Point spacing;
  late Color backgroundColor;
  late bool separatorsEnabled;
  late bool isReverse;
  bool isDismissible = false;

  late Future _init;

  @override
  initState() {
    super.initState();
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
    singleChoice =
        await viewContext.viewDefinitionPropertyResolver.boolean("singleChoice") ?? false;

    await initEditMode();
  }

  Future<void> initEditMode() async {
    isInEditMode = (await viewContext.viewDefinitionPropertyResolver
        .boolean("editMode", pageController.isInEditMode.value))!;

    selectedIndicesBinding = viewContext.selectedIndicesBinding;
    selectedIndices = selectedIndicesBinding.get();
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
    var isSelected = selectedIndices.contains(index);

    Widget tile = ListTile(
      key: Key(item.uid),
      dense: true,
      minVerticalPadding: 0,
      visualDensity: VisualDensity(horizontal: -2, vertical: -2),
      contentPadding: EdgeInsets.fromLTRB(insets.left, index == 0 ? 0 : spacing.y / 2, insets.right,
          index == viewContext.items.length - 1 ? 0 : spacing.y / 2),
      title: Row(
        children: [
          if (isSelected) Icon(Icons.face),
          Expanded(child: title),
        ],
      ),
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
}
