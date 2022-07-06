import 'package:flutter/material.dart';
import 'package:memri/cvu/controllers/view_context_controller.dart';
import 'package:memri/cvu/utilities/binding.dart';

abstract class Renderer extends StatefulWidget {
  final ViewContextController viewContext;

  Renderer({required this.viewContext});
}

abstract class RendererViewState<T extends Renderer> extends State<T> {
  late final ViewContextController viewContext;
  bool singleChoice = false;
  late Binding<Set<int>> selectedIndicesBinding;
  Set<int> selectedIndices = Set<int>();
  bool scrollable = true;
  bool showDefaultSelections = true;

  late Widget? startingElement;
  late Widget? trailingElement;

  @override
  initState() {
    super.initState();
    viewContext = widget.viewContext;
  }

  @override
  dispose() {
    super.dispose();
  }

  void init() {
    showDefaultSelections = viewContext.rendererDefinitionPropertyResolver
            .boolean("showDefaultSelections") ??
        true;
    startingElement = getAdditionalElement("startingElement");
    trailingElement = getAdditionalElement("trailingElement");

    selectedIndicesBinding = viewContext.selectedIndicesBinding;
    selectedIndices = selectedIndicesBinding.get();
  }

  Widget? getAdditionalElement(String elementName) {
    var def = viewContext
            .viewDefinitionPropertyResolver.properties[elementName] ??
        viewContext.rendererDefinitionPropertyResolver.properties[elementName];

    var subDef = def?.getSubdefinition();
    if (subDef != null) {
      return viewContext.render(
          nodeDefinition: subDef,
          item: viewContext.focusedItem,
          items: viewContext.items);
    }
    return null;
  }

  Widget? get emptyResult {
    var emptyResultDef =
        viewContext.viewDefinitionPropertyResolver.properties["emptyResult"] ??
            viewContext
                .rendererDefinitionPropertyResolver.properties["emptyResult"];

    var emptyResultSubdef = emptyResultDef?.getSubdefinition();
    if (emptyResultSubdef != null) {
      return viewContext.render(nodeDefinition: emptyResultSubdef);
    }
    return null;
  }

  selectIndice(int index, bool isSingleChoice) {
    setState(() {
      if (!isSingleChoice) {
        if (!selectedIndices.remove(index)) {
          selectedIndices.add(index);
        }
      } else {
        selectedIndices.clear();
        selectedIndices.add(index);
      }

      selectedIndicesBinding.set(selectedIndices);
    });
  }

  selectionMode(int index) {
    return () {
      var item = viewContext.items.asMap()[index];

      if (item != null) {
        var presses =
            viewContext.rendererDefinitionPropertyResolver.actions("onPress") ??
                viewContext.nodePropertyResolver(item)?.actions("onPress");
        if (presses != null) {
          presses.forEach((press) async =>
              await press.execute(viewContext.getCVUContext(item: item)));

          selectIndice(index, true);
        }
      }
    };
  }
}
