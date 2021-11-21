import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemEdgeRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/IconData.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';

import 'Renderer.dart';

/// The Label Annotation renderer
/// This renderer can be used to annotate items with Labels
/// - Set the `labelType` to a unique ID representing the type of labels
/// - Set the `labelOptions` property to an array of Strings (representing the options)
/// - You may also provide a `labelOptionIcons` property with an array of icon names (in matching order with `labelOptions` array)
class LabelAnnotationRendererView extends Renderer {
  LabelAnnotationRendererView({required pageController, required viewContext})
      : super(pageController: pageController, viewContext: viewContext);

  @override
  _LabelAnnotationRendererViewState createState() => _LabelAnnotationRendererViewState();
}

class _LabelAnnotationRendererViewState extends RendererViewState {
  ValueNotifier<Set<String>> _selectedLabels = ValueNotifier(Set<String>());

  Set<String> get selectedLabels => _selectedLabels.value;

  set selectedLabels(Set<String> newSelectedLabels) {
    setState(() => _selectedLabels.value = newSelectedLabels);
  }

  @override
  void initState() {
    super.initState();
  }

  Future<String> get labelType async {
    return await viewContext.rendererDefinitionPropertyResolver.string("labelType") ?? "UNDEFINED";
  }

  Future<List<String>> get labelOptionIcons async {
    return await viewContext.rendererDefinitionPropertyResolver.stringArray("labelOptionIcons");
  }

  Future<List<LabelOption>> get labelOptions async {
    var icons = (await labelOptionIcons).asMap();
    return (await viewContext.rendererDefinitionPropertyResolver.stringArray("labelOptions"))
        .mapIndexed((index, element) => LabelOption(
            labelID: element,
            text: element.titleCase(),
            icon: Icon(MemriIcon.getByName(icons[index] ?? "tag"))))
        .toList();
  }

  void moveToPreviousItem() {
    selectedLabels = Set<String>();
    if (viewContext.focusedIndex <= 0) {
      moveToIndex(viewContext.items.length - 2);
      return;
    }
    moveToIndex(viewContext.focusedIndex - 1);
  }

  void moveToNextItem() {
    if (viewContext.focusedIndex >= viewContext.items.length - 1) {
      moveToIndex(0);
      return;
    }
    moveToIndex(viewContext.focusedIndex + 1);
  }

  void moveToIndex(int index) {
    viewContext.focusedIndex = index;
    loadExistingAnnotation();
  }

  void loadExistingAnnotation() async {
    selectedLabels = await currentAnnotationLabels;
  }

  void applyCurrentItem() async {
    var currItem = currentItem;
    if (currItem == null) {
      return;
    }
    var labelsString = selectedLabels.join(",");

    var annotationItem = await currentAnnotation() ?? ItemRecord(type: "LabelAnnotation");
    await annotationItem.setPropertyValue("labels", PropertyDatabaseValueString(labelsString));

    var edge = ItemEdgeRecord(
        sourceRowID: annotationItem.rowId, name: "annotatedItem", targetRowID: currItem.rowId);
    edge.save();

    moveToNextItem();
  }

  Future<ItemRecord?> currentAnnotation() async {
    return await currentItem?.reverseEdgeItem("annotatedItem");
  }

  Future<Set<String>> get currentAnnotationLabels async {
    return Set.from(
        (await (await currentAnnotation())?.propertyValue("labels"))?.asString()?.split(",") ?? []);
  }

  ItemRecord? get currentItem {
    return widget.viewContext.items.asMap()[widget.viewContext.focusedIndex];
  }

  String? get progressText {
    if (widget.viewContext.items.isEmpty) {
      return null;
    }
    return "Item ${widget.viewContext.focusedIndex + 1} of ${widget.viewContext.items.length}";
  }

  bool get enableBackButton => widget.viewContext.focusedIndex > 0;

  bool get enableSkipButton =>
      widget.viewContext.focusedIndex < widget.viewContext.items.length - 1;

  Widget get currentContent {
    var item = currentItem;
    if (item != null) {
      return widget.viewContext.render(item: item);
    } else {
      return Text(
        "No items to label",
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LabelSelectionView(
        options: labelOptions,
        selected: _selectedLabels,
        enabled: currentItem != null,
        onBackPressed: moveToPreviousItem,
        onCheckmarkPressed: applyCurrentItem,
        onSkipPressed: moveToNextItem,
        enableBackButton: enableBackButton,
        enableCheckmarkButton: true,
        enableSkipButton: enableSkipButton,
        topText: progressText,
        content: currentContent,
        useScrollView: false,
        onAppear: () {
          loadExistingAnnotation();
        });
  }
}

class LabelOption {
  String labelID;
  String text;
  Icon icon;

  LabelOption({required this.labelID, required this.text, required this.icon});

  String get id => labelID;
}

class LabelSelectionView extends StatefulWidget {
  final Future<List<LabelOption>> options;

  final ValueNotifier<Set<String>> selected;
  final bool enabled;

  final void Function() onBackPressed;
  final void Function() onCheckmarkPressed;
  final void Function() onSkipPressed;

  final bool enableBackButton;
  final bool enableCheckmarkButton;
  final bool enableSkipButton;

  final String? topText;

  final Widget content;
  final bool useScrollView;

  final void Function() onAppear;

  LabelSelectionView({
    required this.options,
    required this.selected,
    required this.enabled,
    required this.onBackPressed,
    required this.onCheckmarkPressed,
    required this.onSkipPressed,
    required this.enableBackButton,
    required this.enableCheckmarkButton,
    required this.enableSkipButton,
    this.topText,
    required this.content,
    this.useScrollView = true,
    required this.onAppear,
  });

  @override
  _LabelSelectionViewState createState() => _LabelSelectionViewState();
}

class _LabelSelectionViewState extends State<LabelSelectionView> {
  late Future<List<LabelOption>> options;

  @override
  void initState() {
    super.initState();
    options = widget.options;
    widget.onAppear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      if (widget.topText != null) ...[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Text(
            widget.topText!,
            style: TextStyle(backgroundColor: CVUColor.system("secondarySystemBackground")),
          ),
        ),
        Divider(
          height: 1,
        )
      ],
      widget.useScrollView
          ? LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: widget.content,
              ),
            )
          : Expanded(child: widget.content),
      Container(
        height: 150,
        child: Opacity(
          opacity: widget.enabled ? 1 : 0.4,
          child: FutureBuilder<List<LabelOption>>(
            future: options,
            builder: (context, AsyncSnapshot<List<LabelOption>> snapshot) =>
                snapshot.connectionState == ConnectionState.done
                    ? ValueListenableBuilder<Set<String>>(
                        valueListenable: widget.selected,
                        builder: (context, value, child) {
                          List<String> selected = value.toList();
                          return ListView(
                            padding: EdgeInsets.zero,
                            children: snapshot.data!
                                .map<Widget>((option) => SizedBox(
                                      height: 30,
                                      child: ListTile(
                                        visualDensity: VisualDensity.compact,
                                        dense: true,
                                        minVerticalPadding: 0,
                                        title: TextButton(
                                            onPressed: () {
                                              if (selected.remove(option.id) == false) {
                                                selected.add(option.id);
                                              }
                                              widget.selected.value = Set.from(selected);
                                            },
                                            child: Row(
                                              children: [option.icon, Text(option.text)],
                                            ),
                                            style: TextButton.styleFrom(
                                                visualDensity: VisualDensity.compact,
                                                padding: EdgeInsets.all(0),
                                                backgroundColor: selected.contains(option.id)
                                                    ? Colors.blue
                                                    : Colors.transparent,
                                                primary: selected.contains(option.id)
                                                    ? Colors.white
                                                    : Colors.blue)),
                                      ),
                                    ))
                                .toList(),
                          );
                        },
                      )
                    : Empty(),
          ),
        ),
      ),
      Divider(),
      Container(
        height: 50,
        child: Opacity(
          opacity: widget.enabled ? 1 : 0.4,
          child: Row(
            children: [
              IconButton(
                  icon: Icon(Icons.undo),
                  onPressed: widget.enableBackButton ? widget.onBackPressed : null),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.green.withOpacity(widget.enableCheckmarkButton ? 1 : 0.5),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.check),
                    onPressed: widget.enableCheckmarkButton ? widget.onCheckmarkPressed : null,
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton(
                  child: Text("Skip"),
                  onPressed: widget.enableSkipButton ? widget.onSkipPressed : null),
            ],
          ),
        ),
      )
    ]);
  }
}
