import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/PageController.dart' as memri;
import 'package:memri/MemriApp/Helpers/Binding.dart';

import '../ViewContextController.dart';

abstract class Renderer extends StatefulWidget {
  final memri.PageController pageController;
  final ViewContextController viewContext;

  Renderer({required this.pageController, required this.viewContext});
}

abstract class RendererViewState<T extends Renderer> extends State<T> {
  late final memri.PageController pageController;
  late final ViewContextController viewContext;
  late bool isInEditMode;
  bool singleChoice = false;
  late Binding<Set<int>> selectedIndicesBinding;
  late Set<int> selectedIndices;
  bool scrollable = true;
  bool isBlocked = false;
  ValueNotifier? blockedFromStorage;
  bool showDefaultSelections = true;

  @override
  initState() {
    super.initState();
    pageController = widget.pageController;
    viewContext = widget.viewContext;
    pageController.isInEditMode.addListener(updateIsInEditMode);
  }

  @override
  dispose() {
    super.dispose();
    pageController.isInEditMode.removeListener(updateIsInEditMode);
    blockedFromStorage?.removeListener(updateBlockedState);
  }

  Future<void> init() async {
    blockedFromStorage =
        pageController.appController.databaseController.storage[pageController.label]?["isBlocked"];
    isBlocked = blockedFromStorage?.value ?? false;
    blockedFromStorage?.addListener(updateBlockedState);
    showDefaultSelections =
        await viewContext.rendererDefinitionPropertyResolver.boolean("showDefaultSelections") ??
            true;
    await initEditMode();
  }

  updateBlockedState() {
    setState(() {
      isBlocked = blockedFromStorage?.value ?? false;
    });
  }

  Future<void> initEditMode() async {
    isInEditMode = (await viewContext.viewDefinitionPropertyResolver
        .boolean("editMode", pageController.isInEditMode.value))!;

    selectedIndicesBinding = viewContext.selectedIndicesBinding;
    selectedIndices = selectedIndicesBinding.get();
  }

  updateIsInEditMode() async {
    await initEditMode();
    setState(() {});
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

  selectionMode(index) {
    if (isInEditMode) {
      return () {
        setState(() {
          if (!singleChoice) {
            if (!selectedIndices.remove(index)) {
              selectedIndices.add(index);
            }
          } else {
            selectedIndices.clear();
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
