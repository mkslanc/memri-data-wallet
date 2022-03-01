import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memri/constants/cvu/cvu_color.dart';
import 'package:memri/core/cvu/cvu_action.dart';
import 'package:memri/models/database/item_record.dart';
import 'package:memri/utils/extensions/collection.dart';
import 'package:memri/widgets/components/shapes/circle.dart';
import 'package:memri/widgets/empty.dart';
import 'package:memri/widgets/renderers/renderer.dart';
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
    viewContext.addListener(updateState);
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
  Future<void> init() async {
    super.init();
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
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!viewContext.isLoaded) {
              return Empty();
            }
            if (viewContext.hasItems) {
              selectedIndices = selectedIndicesBinding.get();
              var lastIndex = viewContext.items.length - 1;
              var elements = List<Widget>.from(viewContext.items
                  .mapIndexed((index, item) =>
                      [_buildItem(item, index), if (index < lastIndex) _buildSeparator()])
                  .expand((element) => element));

              if (additional != null) {
                elements.insert(0, _buildSeparator());
                elements.insertAll(0, [
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
                  padding: EdgeInsets.fromLTRB(0,
                      pageController.showTopBar ? insets.top : insets.top + 80, 0, insets.bottom),
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
          } else {
            return Empty();
          }
        });
  }

  Widget _buildItem(ItemRecord item, int index) {
    var titleWidget = isBlocked ? blockedSkeleton : viewContext.render(item: item);
    var title = ColoredBox(key: Key(item.uid), color: backgroundColor, child: titleWidget);
    var callback = isBlocked ? null : selectionMode(index);
    var isSelected = selectedIndices.contains(index);

    Widget tile = ListTile(
      key: Key(item.uid),
      dense: true,
      minVerticalPadding: 0,
      visualDensity: VisualDensity(horizontal: -2, vertical: -2),
      contentPadding: EdgeInsets.fromLTRB(insets.left, index == 0 ? 0 : spacing.y / 2, insets.right,
          index == viewContext.items.length - 1 ? 0 : spacing.y / 2),
      title: isInEditMode && showDefaultSelections
          ? Row(
              children: [
                SvgPicture.asset(
                  "assets/images/check.svg",
                  color: isSelected ? Colors.black : Color(0xffDFDEDE),
                ),
                SizedBox(
                  width: 18,
                ),
                Expanded(child: title),
              ],
            )
          : title,
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
