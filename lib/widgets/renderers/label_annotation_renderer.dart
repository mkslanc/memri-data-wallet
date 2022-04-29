import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memri/constants/cvu/cvu_color.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/controllers/cvu_controller.dart';
import 'package:memri/core/services/database/property_database_value.dart';
import 'package:memri/models/cvu/cvu_parsed_definition.dart';
import 'package:memri/models/database/item_record.dart';
import 'package:memri/utils/extensions/collection.dart';
import 'package:memri/utils/extensions/enum.dart';
import 'package:memri/widgets/empty.dart';
import 'package:memri/widgets/renderers/renderer.dart';
import 'package:moor/moor.dart';

import '../../models/database/item_property_record.dart';

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

  bool isLoading = false;
  bool inPreviewMode = false;

  late final ItemRecord labellingTask;
  late List<LabelOption> labelOptions;

  LabelType labelType = LabelType.CategoricalLabel; //TODO resolve
  bool isSingleLabel = true; //TODO resolve

  late List<ItemRecord> datasetEntryList;
  ItemRecord? currentItem;
  ItemRecord? currentAnnotation;

  int currentIndex = 0;

  CVUDefinitionContent? contentDefinition;

  ValueNotifier<Set<String>> _selectedLabels = ValueNotifier(Set<String>());

  Set<String> get selectedLabels => _selectedLabels.value;

  final FocusNode _focusNode = FocusNode();

  set selectedLabels(Set<String> newSelectedLabels) {
    _selectedLabels.value = newSelectedLabels;
  }

  Set<String> _existingSelectedLabels = Set<String>();

  @override
  void initState() {
    super.initState();
    labellingTask = widget.viewContext.focusedItem!;
    _init = init();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
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

    await loadDatasetEntry();
  }

  startLoading() => setState(() {
        isLoading = true;
      });

  endLoading() => setState(() {
        isLoading = false;
      });

  Future<void> loadDataset() async {
    var dataset = await labellingTask.reverseEdgeItem("labellingTask");
    datasetEntryList = await dataset!.edgeItems("entry");
    var edges = (await widget.pageController.appController.databaseController.databasePool
        .edgeRecordsCustomSelect(
            "source IN (${datasetEntryList.map((item) => item.rowId).join(", ")}) AND name = ?",
            [Variable("annotation")])); //TODO not good calling db from widget
    currentIndex = edges.length > datasetEntryList.length ? 0 : edges.length;
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
    var index = currentIndex <= 0 ? datasetEntryList.length - 1 : currentIndex - 1;
    moveToIndex(index);
  }

  void moveToNextItem() {
    var index = currentIndex >= datasetEntryList.length - 1 ? 0 : currentIndex + 1;
    moveToIndex(index);
  }

  void moveToIndex(int index) {
    startLoading();
    currentIndex = index;
    loadDatasetEntry().then((value) => endLoading());
  }

  Future<ItemRecord?> getOrCreateCurrentAnnotation() async {
    if (currentEntry == null) return null;
    var labelAnnotation = currentAnnotation;
    if (labelAnnotation == null) {
      labelAnnotation = ItemRecord(type: labelType.inString);
      await labelAnnotation.save();

      await currentEntry!.addEdge(edgeName: "annotation", targetItem: labelAnnotation);
      currentAnnotation = labelAnnotation;
    }

    return labelAnnotation;
  }

  Future<void> skipCurrentItem() async {
    startLoading();
    var isNew = currentAnnotation == null;
    var labelAnnotation = await getOrCreateCurrentAnnotation();
    if (labelAnnotation == null) {
      endLoading();
      return;
    }

    if (isNew) {
      await labelAnnotation.setPropertyValue("isSubmitted", PropertyDatabaseValueBool(false));
      widget.pageController.sceneController
          .pageControllerByLabel("labellingSummary")
          ?.scheduleUIUpdate(); //TODO no sense in implementing more general as this is a hack till streams implemented
    }

    moveToNextItem();
  }

  Future<void> applyCurrentItem() async {
    startLoading();
    var isNew = currentAnnotation == null;
    var labelAnnotation = await getOrCreateCurrentAnnotation();
    if (labelAnnotation == null) {
      endLoading();
      return;
    }

    await saveSelectedValue();

    ItemPropertyRecord? isSubmitted;
    if (!isNew && _existingSelectedLabels.isEmpty) {
      isSubmitted = await labelAnnotation.property("isSubmitted");
    }
    if (isNew || isSubmitted?.$value.value == false) {
      await labelAnnotation.setPropertyValue("isSubmitted", PropertyDatabaseValueBool(true),
          isNew: isNew);
    }
    widget.pageController.sceneController
        .pageControllerByLabel("labellingSummary")
        ?.scheduleUIUpdate(); //TODO no sense in implementing more general as this is a hack till streams implemented

    moveToNextItem();
  }

  saveSelectedValue() async {
    if (_existingSelectedLabels.difference(selectedLabels).isEmpty &&
        selectedLabels.difference(_existingSelectedLabels).isEmpty) //TODO sets equals
      return;
    switch (labelType) {
      case LabelType.CategoricalLabel:
        var labelValue = labelOptions
            .compactMap(
                (labelOption) => selectedLabels.contains(labelOption.id) ? labelOption.text : null)
            .join(",");
        currentAnnotation!.setPropertyValue("labelValue", PropertyDatabaseValueString(labelValue));
        break;
      default:
        break;
    }
  }

  Future<void> loadDatasetEntry() async {
    var entry = currentEntry;
    if (entry == null) return;
    currentItem = await entry.edgeItem("data");
    currentAnnotation = await entry.edgeItem("annotation");
    await loadExistingAnnotation();
  }

  Future<void> loadExistingAnnotation() async {
    selectedLabels = Set<String>();
    var annotation = currentAnnotation;
    if (annotation == null) return;
    switch (labelType) {
      case LabelType.CategoricalLabel:
        var labelValue = await annotation.property("labelValue");
        if (labelValue != null) {
          var selectedLabelValues =
              (labelValue.$value as PropertyDatabaseValueString).value.split(",");
          selectedLabels = labelOptions
              .compactMap((labelOption) =>
                  selectedLabelValues.contains(labelOption.text) ? labelOption.id : null)
              .toSet();
        }
        break;
      default:
        break;
    }
    _existingSelectedLabels = Set.of(selectedLabels);
  }

  ItemRecord? get currentEntry {
    return datasetEntryList.asMap()[currentIndex];
  }

  bool get enableBackButton => currentIndex > 0;

  bool get enableSkipButton => currentIndex < datasetEntryList.length - 1;

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
        if (snapshot.connectionState == ConnectionState.done) {
          FocusScope.of(context).requestFocus(_focusNode);
          return KeyboardListener(
            focusNode: _focusNode,
            child: LabelSelectionView(
                options: labelOptions,
                selected: _selectedLabels,
                enabled: currentEntry != null && !isLoading,
                onBackPressed: moveToPreviousItem,
                onCheckmarkPressed: inPreviewMode ? null : applyCurrentItem,
                onSkipPressed: inPreviewMode ? moveToNextItem : skipCurrentItem,
                enableBackButton: enableBackButton,
                enableCheckmarkButton: true,
                enableSkipButton: enableSkipButton,
                content: currentContent,
                labelType: labelType,
                isSingleLabel: isSingleLabel,
                isLoading: isLoading),
            onKeyEvent: (KeyEvent event) {
              if (isLoading) return;
              var pressedKey = int.tryParse(event.character ?? "");
              if (pressedKey is int) {
                var index = pressedKey - 1;
                if (index < 0) {
                  selectedLabels = Set();
                } else if (labelOptions.length > index) {
                  selectedLabels = [labelOptions[index].id].toSet();
                }
              } else if (event is KeyUpEvent) {
                if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
                    event.logicalKey == LogicalKeyboardKey.arrowUp) {
                  var index = -1;
                  if (selectedLabels.isNotEmpty) {
                    var selectedLabelOption = selectedLabels.toList().first;
                    index = labelOptions
                        .indexWhere((labelOption) => labelOption.id == selectedLabelOption);
                  }
                  if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                    index++;
                  } else {
                    index--;
                  }
                  if (index < 0) {
                    index = labelOptions.length - 1;
                  } else if (index >= labelOptions.length) {
                    index = 0;
                  }

                  selectedLabels = [labelOptions[index].id].toSet();
                } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  inPreviewMode ? moveToNextItem() : skipCurrentItem();
                } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                  if (currentIndex > 0) moveToPreviousItem();
                } else if (event.logicalKey == LogicalKeyboardKey.enter) {
                  if (!inPreviewMode) applyCurrentItem();
                }
              }
            },
          );
        } else {
          return Empty();
        }
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

class LabelSelectionView extends StatelessWidget {
  final List<LabelOption> options;

  final LabelType labelType;

  final ValueNotifier<Set<String>> selected;
  final bool enabled;

  final void Function()? onBackPressed;
  final void Function()? onCheckmarkPressed;
  final void Function()? onSkipPressed;

  final bool enableBackButton;
  final bool enableCheckmarkButton;
  final bool enableSkipButton;

  final String? topText;

  final Widget content;

  final bool isSingleLabel;

  final bool isLoading;

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
      required this.labelType,
      required this.isSingleLabel,
      required this.isLoading});

  Widget get labelOptions => Container(
        //height: 150,
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: ValueListenableBuilder<Set<String>>(
            valueListenable: selected,
            builder: (context, value, child) {
              var selectedList = value.toList();
              return Wrap(
                direction: Axis.vertical,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 5,
                children: options
                    .mapIndexed<Widget>((index, option) => TextButton(
                          style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact, padding: EdgeInsets.all(0)),
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (isSingleLabel) {
                                    selectedList = [option.id];
                                  } else {
                                    if (selectedList.remove(option.id) == false) {
                                      selectedList.add(option.id);
                                    }
                                  }
                                  selected.value = selectedList.toSet();
                                },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10, 5, 19, 5),
                            decoration: BoxDecoration(
                                color: selectedList.contains(option.id)
                                    ? Color(0x33FE570F)
                                    : Color(0xffF5F5F5),
                                borderRadius: BorderRadius.circular(20)),
                            child: Wrap(
                              spacing: 5,
                              children: [
                                if (option.icon != null) option.icon!,
                                Text(
                                  option.text,
                                  style: CVUFont.bodyText1.copyWith(
                                      color: selectedList.contains(option.id)
                                          ? Color(0xffFE570F)
                                          : Color(0xff333333)),
                                ),
                                Text(
                                  (index + 1).toString(),
                                  style: CVUFont.smallCaps.copyWith(
                                      fontWeight: FontWeight.w700, color: Color(0xff999999)),
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
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          direction: Axis.vertical,
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          children: [
            if (topText != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Text(
                  topText!,
                  style: TextStyle(backgroundColor: CVUColor.system("secondarySystemBackground")),
                ),
              ),
              Divider(
                height: 1,
              )
            ],
            SizedBox(
              height: constraints.maxHeight - 150 - options.length * 30,
              width: constraints.maxWidth,
              child: isLoading
                  ? Center(
                      child: SizedBox(
                        child: CircularProgressIndicator(color: Color(0xff333333)),
                        width: 60,
                        height: 60,
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: content,
                    ),
            ),
            if (labelType == LabelType.CategoricalLabel) labelOptions,
            Container(
              height: 100,
              width: constraints.maxWidth,
              padding: EdgeInsets.symmetric(horizontal: 60, vertical: 25),
              child: Opacity(
                opacity: enabled ? 1 : 0.4,
                child: Row(
                  children: [
                    TextButton(
                        child: Icon(Icons.arrow_back, color: Color(0xFFF5F5F5)),
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.all(10),
                            fixedSize: Size(50, 50),
                            backgroundColor:
                                enableBackButton ? Color(0xFF333333) : Color(0xFFDFDEDE)),
                        onPressed: enableBackButton && !isLoading ? onBackPressed : null),
                    Spacer(),
                    TextButton(
                      child: SvgPicture.asset("assets/images/check.svg", color: Color(0xFFF5F5F5)),
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFF333333),
                        fixedSize: Size(50, 50),
                      ),
                      onPressed: enableCheckmarkButton && !isLoading ? onCheckmarkPressed : null,
                    ),
                    if (labelType == LabelType.BinaryLabel) ...binaryOptions,
                    Spacer(),
                    TextButton(
                        child: Icon(Icons.arrow_forward, color: Color(0xFFF5F5F5)),
                        style: TextButton.styleFrom(
                            fixedSize: Size(50, 50),
                            backgroundColor:
                                enableSkipButton ? Color(0xFF333333) : Color(0xFFDFDEDE)),
                        onPressed: enableSkipButton && !isLoading ? onSkipPressed : null),
                  ],
                ),
              ),
            ),
          ]);
    });
  }
}
