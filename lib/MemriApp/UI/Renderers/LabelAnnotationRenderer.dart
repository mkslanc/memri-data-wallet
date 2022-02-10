import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memri/MemriApp/CVU/CVUController.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemEdgeRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUFont.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Enum.dart';

import 'Renderer.dart';

enum LabelType { CategoricalLabel, BinaryLabel }

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
  late Future<void> _init;

  bool inPreviewMode = false;

  late final ItemRecord labellingTask;
  late List<LabelOption> labelOptions;

  LabelType labelType = LabelType.CategoricalLabel; //TODO resolve

  late List<ItemRecord> currentItemList;
  int currentIndex = 0;

  Map<int, ItemRecord> itemAnnotationList = {};

  CVUDefinitionContent? contentDefinition;

  ValueNotifier<Set<String>> _selectedLabels = ValueNotifier(Set<String>());

  Set<String> get selectedLabels => _selectedLabels.value;

  set selectedLabels(Set<String> newSelectedLabels) {
    _selectedLabels.value = Set.of(newSelectedLabels);
  }

  @override
  void initState() {
    super.initState();
    labellingTask = widget.viewContext.focusedItem!;
    _init = init();
  }

  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init = init();
  }

  Future<void> init() async {
    await loadDataset();
    await loadLabelOptions();
    await loadCVU();

    inPreviewMode =
        await viewContext.viewDefinitionPropertyResolver.boolean("inPreviewMode") ?? false;
  }

  Future<void> loadDataset() async {
    var dataset = await labellingTask.reverseEdgeItem("labellingTask");
    currentItemList = await dataset!.edgeItems("entry");
    var currentAnnotationList = await labellingTask.edgeItems("labelAnnotation");
    await Future.forEach<ItemRecord>(currentAnnotationList, (labelAnnotation) async {
      var annotatedItem = await labelAnnotation.edgeItem("annotatedItem");
      if (annotatedItem != null) {
        itemAnnotationList[annotatedItem.rowId!] = labelAnnotation;
      }
    });
  }

  Future<void> loadLabelOptions() async {
    labelOptions =
        await Future.wait((await labellingTask.edgeItems("labelOption")).map((labelOption) async {
      var labelString = (await labelOption.property("name"))!.$value.asString()!;
      return LabelOption(labelID: labelOption.uid, text: labelString);
    }));
  }

  loadCVU() async {
    var cvuController = widget.pageController.appController.cvuController;
    var view = await labellingTask.edgeItem("view");
    var cvuContent = (await view?.propertyValue("definition"))?.value;
    var cvuDefinition =
        cvuContent != null ? (await CVUController.parseCVU(cvuContent)).asMap()[0] : null;
    if (cvuDefinition != null) {
      cvuController.definitions.add(cvuDefinition);
      contentDefinition = cvuDefinition.parsed;
    }
  }

  void moveToPreviousItem() {
    if (currentIndex <= 0) {
      moveToIndex(currentItemList.length - 1);
      return;
    }
    moveToIndex(currentIndex - 1);
  }

  void moveToNextItem() {
    // widget.pageController.sceneController.scheduleUIUpdate();
    if (currentIndex >= currentItemList.length - 1) {
      moveToIndex(0);
      return;
    }
    moveToIndex(currentIndex + 1);
  }

  void moveToIndex(int index) {
    setState(() {
      currentIndex = index;
      loadExistingAnnotation();
    });
  }

  Future<ItemRecord?> getOrCreateCurrentAnnotation() async {
    if (currentItem == null) {
      return null;
    }
    var currentRowID = currentItem!.rowId!;
    var labelAnnotation = currentAnnotation;
    if (labelAnnotation == null) {
      labelAnnotation = ItemRecord(type: labelType.inString);
      await labelAnnotation.save();

      var annotationItem = ItemEdgeRecord(
          sourceRowID: labelAnnotation.rowId, name: "annotatedItem", targetRowID: currentRowID);
      await annotationItem.save();

      var labelEdge = ItemEdgeRecord(
          sourceRowID: labellingTask.rowId,
          name: "labelAnnotation",
          targetRowID: labelAnnotation.rowId);
      await labelEdge.save();

      itemAnnotationList[currentRowID] = labelAnnotation;
    }

    return labelAnnotation;
  }

  Future<void> skipCurrentItem() async {
    var labelAnnotation = await getOrCreateCurrentAnnotation();
    if (labelAnnotation == null) return;

    var isSubmitted = await labelAnnotation.property("isSubmitted");
    if (isSubmitted == null) {
      await labelAnnotation.setPropertyValue("isSubmitted", PropertyDatabaseValueBool(false));
    }

    moveToNextItem();
  }

  Future<void> applyCurrentItem() async {
    var labelAnnotation = await getOrCreateCurrentAnnotation();
    if (labelAnnotation == null) return;

    var isSubmitted = await labelAnnotation.property("isSubmitted");
    if (isSubmitted == null || isSubmitted.$value.value == false) {
      await labelAnnotation.setPropertyValue("isSubmitted", PropertyDatabaseValueBool(true),
          isNew: isSubmitted == null);
    }

    switch (labelType) {
      case LabelType.CategoricalLabel:
        var labels = await labelAnnotation.edgeItems("categoricalLabel");
        await Future.forEach<ItemRecord>(labels, (label) async {
          if (!selectedLabels.contains(label.uid)) {
            await ItemEdgeRecord(
                    name: "categoricalLabel",
                    targetRowID: label.rowId,
                    sourceRowID: labelAnnotation.rowId)
                .delete();
          }
        });
        var newSelected =
            selectedLabels.difference(labels.map((labelOption) => labelOption.uid).toSet());
        var labelEdges = newSelected
            .map((labelId) => ItemEdgeRecord(
                sourceRowID: labelAnnotation.rowId!, name: "categoricalLabel", targetUID: labelId))
            .toList();
        await ItemEdgeRecord.insertAll(labelEdges);
        break;
      default:
        break;
    }

    moveToNextItem();
  }

  ItemRecord? get currentAnnotation => itemAnnotationList[currentItem?.rowId];

  Future<void> loadExistingAnnotation() async {
    selectedLabels = Set<String>();
    var annotation = currentAnnotation;
    if (annotation == null) return;
    switch (labelType) {
      case LabelType.CategoricalLabel:
        selectedLabels = (await annotation.edgeItems("categoricalLabel"))
            .map((labelOption) => labelOption.uid)
            .toSet();
        break;
      default:
        break;
    }
  }

  ItemRecord? get currentItem {
    return currentItemList.asMap()[currentIndex];
  }

  bool get enableBackButton => currentIndex > 0;

  bool get enableSkipButton => currentIndex < currentItemList.length - 1;

  Widget get currentContent {
    var item = currentItem;
    if (item != null) {
      return widget.viewContext.render(item: item, overrideViewDefinition: contentDefinition);
    } else {
      return Text(
        "No items to label",
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return snapshot.connectionState == ConnectionState.done
            ? LabelSelectionView(
                options: labelOptions,
                selected: _selectedLabels,
                enabled: currentItem != null,
                onBackPressed: moveToPreviousItem,
                onCheckmarkPressed: inPreviewMode ? null : applyCurrentItem,
                onSkipPressed: inPreviewMode ? moveToNextItem : skipCurrentItem,
                enableBackButton: enableBackButton,
                enableCheckmarkButton: true,
                enableSkipButton: enableSkipButton,
                content: currentContent,
                useScrollView: false,
                onAppear: () {
                  loadExistingAnnotation();
                },
                labelType: labelType,
                additional: additional)
            : Empty();
      },
    );
  }
}

class LabelOption {
  String labelID;
  String text;
  Icon? icon;

  LabelOption({required this.labelID, required this.text, this.icon});

  String get id => labelID;
}

class LabelSelectionView extends StatefulWidget {
  final List<LabelOption> options;

  final LabelType labelType;

  final ValueNotifier<Set<String>> selected;
  final bool enabled;

  final void Function() onBackPressed;
  final void Function()? onCheckmarkPressed;
  final void Function() onSkipPressed;

  final bool enableBackButton;
  final bool enableCheckmarkButton;
  final bool enableSkipButton;

  final String? topText;

  final Widget content;
  final bool useScrollView;

  final Widget? additional;

  final void Function() onAppear;

  LabelSelectionView(
      {required this.options,
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
      required this.labelType,
      this.additional});

  @override
  _LabelSelectionViewState createState() => _LabelSelectionViewState();
}

class _LabelSelectionViewState extends State<LabelSelectionView> {
  @override
  void initState() {
    super.initState();
    widget.onAppear();
  }

  Widget get labelOptions => Container(
        //height: 150,
        child: Opacity(
          opacity: widget.enabled ? 1 : 0.4,
          child: ValueListenableBuilder<Set<String>>(
            valueListenable: widget.selected,
            builder: (context, value, child) {
              var selected = value.toList();
              return Wrap(
                direction: Axis.vertical,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 5,
                children: widget.options
                    .map<Widget>((option) => TextButton(
                          style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact, padding: EdgeInsets.all(0)),
                          onPressed: () {
                            if (selected.remove(option.id) == false) {
                              selected.add(option.id);
                            }
                            widget.selected.value = selected.toSet();
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10, 5, 19, 5),
                            decoration: BoxDecoration(
                                color: selected.contains(option.id)
                                    ? Color(0x33FE570F)
                                    : Color(0xffF5F5F5),
                                borderRadius: BorderRadius.circular(20)),
                            child: Wrap(
                              children: [
                                if (option.icon != null) option.icon!,
                                Text(
                                  option.text,
                                  style: CVUFont.bodyText1.copyWith(
                                      color: selected.contains(option.id)
                                          ? Color(0xffFE570F)
                                          : Color(0xff333333)),
                                )
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ),
      );

  List<Widget> get binaryOptions => [
        SizedBox(
          width: 10,
        ),
        TextButton(
          child: SvgPicture.asset("assets/images/ico_ignore.svg", color: Color(0xFFF5F5F5)),
          style: TextButton.styleFrom(
            backgroundColor: Color(0xFFDFDEDE),
            fixedSize: Size(50, 50),
          ),
          onPressed: null,
        ),
        SizedBox(
          width: 10,
        ),
        TextButton(
          child: SvgPicture.asset(
            "assets/images/ico_close.svg",
            color: Color(0xFFF5F5F5),
          ),
          style: TextButton.styleFrom(
            backgroundColor: Color(0xFFFE570F),
            fixedSize: Size(50, 50),
          ),
          onPressed: null,
        )
      ];

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
      if (widget.labelType == LabelType.CategoricalLabel) labelOptions,
      Container(
        height: 100,
        padding: EdgeInsets.symmetric(horizontal: 60, vertical: 25),
        child: Opacity(
          opacity: widget.enabled ? 1 : 0.4,
          child: Row(
            children: [
              TextButton(
                  child: Icon(Icons.arrow_back, color: Color(0xFFF5F5F5)),
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.all(10),
                      fixedSize: Size(50, 50),
                      backgroundColor:
                          widget.enableBackButton ? Color(0xFF333333) : Color(0xFFDFDEDE)),
                  onPressed: widget.enableBackButton ? widget.onBackPressed : null),
              Spacer(),
              TextButton(
                child: SvgPicture.asset("assets/images/check.svg", color: Color(0xFFF5F5F5)),
                style: TextButton.styleFrom(
                  backgroundColor: Color(0xFF333333),
                  fixedSize: Size(50, 50),
                ),
                onPressed: widget.enableCheckmarkButton ? widget.onCheckmarkPressed : null,
              ),
              if (widget.labelType == LabelType.BinaryLabel) ...binaryOptions,
              Spacer(),
              TextButton(
                  child: Icon(Icons.arrow_forward, color: Color(0xFFF5F5F5)),
                  style: TextButton.styleFrom(
                      fixedSize: Size(50, 50),
                      backgroundColor:
                          widget.enableSkipButton ? Color(0xFF333333) : Color(0xFFDFDEDE)),
                  onPressed: widget.enableSkipButton ? widget.onSkipPressed : null),
            ],
          ),
        ),
      ),
      if (widget.additional != null) widget.additional!
    ]);
  }
}
