import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';

import '../ViewContextController.dart';

/// The list renderer
/// This presents the data in a list (aka tableView)
class ListRendererView extends StatefulWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  ListRendererView({required this.sceneController, required this.viewContext});

  @override
  _ListRendererViewState createState() => _ListRendererViewState();
}

class _ListRendererViewState extends State<ListRendererView> {
  late final SceneController sceneController;
  late final ViewContextController viewContext;

  late EdgeInsets insets;
  late Point spacing;
  late Color backgroundColor;
  late bool separatorsEnabled;
  late bool isInEditMode;

  late Binding<Set<int>> selectedIndicesBinding;
  late Set<int> selectedIndices;

  late Future _init;

  initState() {
    super.initState();
    sceneController = widget.sceneController;
    viewContext = widget.viewContext;
    _init = init();

    sceneController.isInEditMode.addListener(updateIsInEditMode);
  }

  updateIsInEditMode() async {
    await initEditMode();
    setState(() {});
  }

  dispose() {
    super.dispose();
    sceneController.isInEditMode.removeListener(updateIsInEditMode);
  }

  Future<void> init() async {
    insets = await viewContext.rendererDefinitionPropertyResolver.edgeInsets ??
        EdgeInsets.only(top: 10, left: 10, bottom: 10, right: 10);
    spacing = await viewContext.rendererDefinitionPropertyResolver.spacing ?? Point(10, 10);
    backgroundColor = await viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
        CVUColor.system("systemBackground");
    separatorsEnabled =
        !(await viewContext.rendererDefinitionPropertyResolver.boolean("hideSeparators", false))!;

    await initEditMode();
  }

  Future<void> initEditMode() async {
    isInEditMode = (await viewContext.viewDefinitionPropertyResolver
        .boolean("editMode", sceneController.isInEditMode.value))!; // sceneController.isInEditMode

    selectedIndicesBinding = viewContext.selectedIndicesBinding;
    selectedIndices = selectedIndicesBinding.get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) => snapshot.connectionState == ConnectionState.done
          ? ValueListenableBuilder(
              valueListenable: viewContext.itemsValueNotifier,
              builder: (BuildContext context, List<ItemRecord> value, Widget? child) {
                if (value.isNotEmpty) {
                  return Expanded(
                      child: ListView.separated(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                          padding: EdgeInsets.fromLTRB(0, insets.top, 0, insets.bottom),
                          itemBuilder: (context, index) {
                            var item = value[index];
                            var title = ColoredBox(
                                  color: backgroundColor,
                                  child: viewContext.render(item: item),
                                );
                            var callback = selectionMode(index);
                            return isInEditMode
                                ? CheckboxListTile(
                                    dense: true,
                                    title: title,
                                    onChanged: callback,
                                    value: selectedIndices.contains(index),
                                    controlAffinity: ListTileControlAffinity.leading)
                                : Dismissible(
                                    direction: DismissDirection.endToStart,
                                    key: Key(item.uid),
                                    onDismissed: (direction) async {
                                      var action = CVUActionDelete();
                                      await action
                                          .execute(sceneController,
                                              viewContext.getCVUContext(item: item))
                                          .then((value) => viewContext.setupQueryObservation());
                                    },
                                    child: ListTile(
                                      dense: true,
                                      minVerticalPadding: 0,
                                      visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                                      contentPadding: EdgeInsets.fromLTRB(
                                          insets.left,
                                          index == 0 ? 0 : spacing.y / 2,
                                          insets.right,
                                          index == viewContext.items.length - 1 ? 0 : spacing.y / 2),
                                      title: title,
                                      onTap: callback,
                                    ),
                                  );
                          },
                          separatorBuilder: (context, index) => Divider(
                                height: separatorsEnabled ? 1 : 0,,
                                color: separatorsEnabled ? null : Colors.transparent,
                              ),
                          itemCount: value.length));
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
              })
          : SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            ),
    );
  }

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
            presses.forEach(
                (press) => press.execute(sceneController, viewContext.getCVUContext(item: item)));
          }
        }
      };
    }
  }
}
