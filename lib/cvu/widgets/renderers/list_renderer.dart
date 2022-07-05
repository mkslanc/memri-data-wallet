import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/core/models/item.dart';
import 'package:memri/cvu/constants/cvu_color.dart';
import 'package:memri/utilities/extensions/collection.dart';
import 'package:memri/widgets/components/shapes/circle.dart';
import 'package:memri/widgets/empty.dart';
import 'package:memri/cvu/widgets/renderers/renderer.dart';

/// The list renderer
/// This presents the data in a list (aka tableView)
class ListRendererView extends Renderer {
  ListRendererView({required viewContext}) : super(viewContext: viewContext);

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
  bool selectFirst = false;
  late Color? backgroundSelected;

  @override
  initState() {
    super.initState();
    init();
    viewContext.addListener(updateState);
  }

  @override
  void didUpdateWidget(covariant Renderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() => init());
  }

  @override
  dispose() {
    super.dispose();
    viewContext.removeListener(updateState);
  }

  updateState() {
    setState(() {});
  }

  @override
  void init() {
    super.init();
    insets = viewContext.rendererDefinitionPropertyResolver.edgeInsets ??
        EdgeInsets.only(top: 0, left: 30, bottom: 0, right: 30);
    spacing =
        viewContext.rendererDefinitionPropertyResolver.spacing ?? Point(10, 10);
    backgroundColor =
        viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
            CVUColor.system("systemBackground");
    separatorsEnabled = !(viewContext.rendererDefinitionPropertyResolver
        .boolean("hideSeparators", false))!;
    isReverse = (viewContext.rendererDefinitionPropertyResolver
        .boolean("isReverse", false))!;
    singleChoice =
        viewContext.viewDefinitionPropertyResolver.boolean("singleChoice") ??
            false;
    backgroundSelected = viewContext.rendererDefinitionPropertyResolver
        .color("backgroundSelected");
    selectFirst = (viewContext.rendererDefinitionPropertyResolver
        .boolean("selectFirst", false))!;
  }

  @override
  Widget build(BuildContext context) {
    if (!viewContext.isLoaded) {
      return Empty();
    }
    List<Widget> elements = [];
    if (viewContext.hasItems) {
      var lastIndex = viewContext.items.length - 1;
      elements = List<Widget>.from(viewContext.items
          .mapIndexed((index, item) => [
                _buildItem(item, index),
                if (index < lastIndex) _buildSeparator()
              ])
          .expand((element) => element));
    }

    if (startingElement != null) {
      elements.insertAll(0, [
        ListTile(
          dense: true,
          minVerticalPadding: 0,
          visualDensity: VisualDensity(horizontal: -2, vertical: -2),
          contentPadding:
              EdgeInsets.fromLTRB(insets.left, 0, insets.right, spacing.y / 2),
          title: startingElement!,
        ),
        _buildSeparator()
      ]);
    }
    if (trailingElement != null) {
      elements.addAll([
        _buildSeparator(),
        ListTile(
          dense: true,
          minVerticalPadding: 0,
          visualDensity: VisualDensity(horizontal: -2, vertical: -2),
          contentPadding:
              EdgeInsets.fromLTRB(insets.left, 0, insets.right, spacing.y / 2),
          title: trailingElement!,
        )
      ]);
    }

    return elements.isNotEmpty
        ? ListView.custom(
            reverse: isReverse,
            shrinkWrap: true,
            padding: EdgeInsets.fromLTRB(0, insets.top + 80, 0, insets.bottom),
            childrenDelegate: SliverChildListDelegate(elements),

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
          )
        : emptyResult ??
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
            );
  }

  Widget _buildItem(Item item, int index) {
    var callback = selectionMode(index);
    if (callback != null &&
        index == 0 &&
        selectedIndices.isEmpty &&
        selectFirst) {
      WidgetsBinding.instance!.addPostFrameCallback((_) => callback());
    }
    var isSelected = selectedIndices.contains(index);
    var titleWidget = viewContext.render(item: item);
    var title = ColoredBox(
        key: Key(item.id), color: backgroundColor, child: titleWidget);

    Widget tile = ListTile(
      key: Key(item.id),
      dense: true,
      minVerticalPadding: 0,
      visualDensity: VisualDensity(horizontal: -2, vertical: -4),
      selected: isSelected,
      selectedTileColor: backgroundSelected,
      contentPadding: EdgeInsets.fromLTRB(
          insets.left,
          index == 0 && startingElement == null ? 0 : spacing.y / 2,
          insets.right,
          index == viewContext.items.length - 1 && trailingElement == null
              ? 0
              : spacing.y / 2),
      title: title,
      onTap: callback,
    );

    return tile;
  }

  get blockedSkeleton {
    return Column(children: [
      Row(
        children: [
          SizedBox(
            height: 30,
            width: 30,
            child: Circle(color: Color(0xffF0F0F0)),
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
              child: Container(
            height: 19,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Color(
                0xffF0F0F0,
              ),
            ),
            child: Text(" "),
          )),
          SizedBox(width: 24),
          Icon(
            Icons.more_horiz,
            color: Color(0xffDFDEDE),
          )
        ],
      )
    ]);
  }

  _buildSeparator() => Padding(
        padding: EdgeInsets.fromLTRB(insets.left, 0, insets.right, 0),
        child: Divider(
          height: separatorsEnabled ? 1 : 0,
          color: separatorsEnabled ? null : Colors.transparent,
        ),
      );
}
