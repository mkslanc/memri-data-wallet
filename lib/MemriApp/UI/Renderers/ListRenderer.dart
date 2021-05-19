import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';

import '../ViewContextController.dart';

/// The list renderer
/// This presents the data in a list (aka tableView)
class ListRendererView extends StatefulWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  ListRendererView({required this.sceneController, required this.viewContext});

  @override
  _ListRendererViewState createState() => _ListRendererViewState(sceneController, viewContext);
}

class _ListRendererViewState extends State<ListRendererView> {
  final SceneController sceneController;
  final ViewContextController viewContext;

  _ListRendererViewState(this.sceneController, this.viewContext);

  late EdgeInsets insets;
  late Point spacing;
  late Color backgroundColor;
  late bool separatorsEnabled;
  late bool isInEditMode;

  Future<bool> init() async {
    insets = await viewContext.rendererDefinitionPropertyResolver.edgeInsets ??
        EdgeInsets.only(top: 10, left: 10, bottom: 10, right: 10);
    spacing = await viewContext.rendererDefinitionPropertyResolver.spacing ?? Point(10, 10);
    backgroundColor = await viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
        CVUColor.system("systemBackground");
    separatorsEnabled =
        !(await viewContext.rendererDefinitionPropertyResolver.boolean("hideSeparators", false))!;

    isInEditMode = (await viewContext.viewDefinitionPropertyResolver
        .boolean("editMode", sceneController.isInEditMode.value))!; // sceneController.isInEditMode

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return ValueListenableBuilder(
                  valueListenable: viewContext.itemsValueNotifier,
                  builder: (BuildContext context, List<ItemRecord> value, Widget? child) {
                    if (viewContext.hasItems) {
                      return Expanded(
                          child: ListView.separated(
                              physics:
                                  BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                              padding: EdgeInsets.fromLTRB(0, insets.top, 0, insets.bottom),
                              itemBuilder: (context, index) => ListTile(
                                    dense: true,
                                    title: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            insets.left,
                                            index == 0 ? 0 : spacing.y / 2,
                                            insets.right,
                                            index == viewContext.items.length - 1
                                                ? 0
                                                : spacing.y / 2),
                                        child: ColoredBox(
                                          color: backgroundColor,
                                          child: viewContext.render(item: viewContext.items[index]),
                                        )),
                                    onTap: selectionMode(index),
                                  ),
                              separatorBuilder: (context, index) => Divider(
                                    height: 1,
                                    color: separatorsEnabled ? null : Colors.transparent,
                                  ),
                              itemCount: viewContext.items.length));
                    } else {
                      return Expanded(
                          child: Padding(
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
                      ));
                    }
                  });

            default:
              return SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              );
          }
        });
  }

  GestureTapCallback selectionMode(index) {
    if (isInEditMode) {
      return () {
        print(index); //TODO select
      };
    } else {
      return () {
        var item = viewContext.items.asMap()[index];

        if (item != null) {
          var presses = viewContext.rendererDefinitionPropertyResolver.actions("onPress") ??
              viewContext.nodePropertyResolver(item)?.actions("onPress");
          if (presses != null) {
            presses.forEach(
                (press) => press.execute(sceneController, viewContext.getCVUContext(item: item)));
          }
        }
      };
    }
  }
}
