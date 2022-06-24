import 'package:flutter/material.dart';
import 'package:memri/constants/cvu/cvu_color.dart';
import 'package:memri/core/controllers/app_controller.dart';
import 'package:memri/core/controllers/page_controller.dart' as memri;
import 'package:memri/core/controllers/view_context_controller.dart';
import 'package:memri/core/cvu/cvu_action.dart';
import 'package:memri/core/models/cvu/cvu_parsed_definition.dart';
import 'package:memri/core/models/cvu/cvu_view_arguments.dart';
import 'package:memri/core/models/database/item_record.dart';
import 'package:memri/core/services/database/property_database_value.dart';
import 'package:memri/core/services/database/schema.dart';
import 'package:memri/core/models/cvu/cvu_value.dart';
import 'package:memri/core/models/cvu/cvu_value_constant.dart';
import 'package:memri/utilities/binding.dart';
import 'package:memri/utilities/extensions/collection.dart';
import 'package:memri/utilities/extensions/dictionary.dart';
import 'package:memri/utilities/extensions/string.dart';
import 'package:memri/widgets/components/button/action_button.dart';
import 'package:memri/widgets/components/memri_date_picker.dart';
import 'package:memri/widgets/components/text_field/memri_text_field.dart';
import 'package:memri/widgets/empty.dart';
import 'package:memri/widgets/renderers/renderer.dart';

class GeneralEditorLayoutItem {
  String id;
  Map<String, CVUValue> dict;

  GeneralEditorLayoutItem(this.id, this.dict);

  bool has(String propName) {
    return dict.containsKey(propName);
  }

  T? get<T>(
      {required String propName, ItemRecord? item, Type? additionalType}) {
    var propValue = dict[propName];
    if (propValue == null) {
      return null;
    }

    if (T == List && additionalType == String) {
      if (propValue is CVUValueArray) {
        var values = propValue.value;
        return values.compactMap((value) {
          if (value is CVUValueConstant) {
            var constant = value.value;
            return constant.asString();
          } else {
            return null;
          }
        }) as T;
      } else if (propValue is CVUValueConstant) {
        var constant = propValue.value;
        return [constant.asString()] as T;
      } else {
        return null;
      }
    }

    if (T == String) {
      if (propValue is CVUValueConstant) {
        var constant = propValue.value;
        return constant.asString() as T;
      } else {
        return null;
      }
    }

    if (T == bool) {
      if (propValue is CVUValueConstant) {
        var constant = propValue.value;
        return constant.asBool() as T;
      } else {
        return null;
      }
    }

    return propValue as T;
  }
}

/// The GeneralEditorRenderer
/// This presents an editor for a single item
class GeneralEditorRendererView extends Renderer {
  GeneralEditorRendererView({required pageController, required viewContext})
      : super(pageController: pageController, viewContext: viewContext);

  @override
  _GeneralEditorRendererViewState createState() =>
      _GeneralEditorRendererViewState();
}

class _GeneralEditorRendererViewState extends RendererViewState {
  updateState() => setState(() {});

  @override
  initState() {
    super.initState();
    pageController.addListener(updateState);
  }

  @override
  dispose() {
    super.dispose();
    pageController.removeListener(updateState);
  }

  List<GeneralEditorLayoutItem> get layout {
    var currentItem = viewContext.focusedItem;
    if (currentItem == null) {
      return [];
    }
    var viewLayout = viewContext.cvuController
            .viewDefinitionForItemRecord(itemRecord: currentItem)
            ?.definitions
            .firstWhereOrNull((definition) =>
                definition.selector == "[renderer = generalEditor]")
            ?.get("layout") ??
        viewContext.cvuController
            .viewDefinitionFor(viewName: viewContext.config.viewName ?? "")
            ?.definitions
            .firstWhereOrNull((definition) =>
                definition.selector == "[renderer = generalEditor]")
            ?.get("layout");
    List<Map<String, CVUValue>>? viewDefs = [];

    if (viewLayout is CVUValueArray) {
      var values = viewLayout.value;
      viewDefs.addAll(
          values.compactMap((value) => value.getSubdefinition()?.properties));
    }

    var generalLayout = viewContext.cvuController
        .rendererDefinitionForSelector(
            selector: "[renderer = ${viewContext.config.rendererName}]")
        ?.properties["layout"];
    List<Map<String, CVUValue>>? generalDefs = [];
    if (generalLayout is CVUValueArray) {
      var values = generalLayout.value;
      generalDefs.addAll(
          values.compactMap((value) => value.getSubdefinition()?.properties));
    }
    if (viewDefs.isEmpty || generalDefs.isEmpty) {
      return [];
    }

    var showDefaultLayout = true;
    var showDefaultLayoutValue =
        viewContext.config.viewDefinition.properties["showDefaultLayout"];
    if (showDefaultLayoutValue is CVUValueConstant) {
      if (showDefaultLayoutValue.value is CVUConstantBool) {
        showDefaultLayout =
            (showDefaultLayoutValue.value as CVUConstantBool).value;
      }
    }

    var mergedDefinitions = [];
    mergedDefinitions.addAll(viewDefs);
    if (showDefaultLayout) {
      // Merge layout from default generalEditor cvu
      mergedDefinitions.addAll(generalDefs);
    }

    var sections = [];
    Map<String, Map<String, CVUValue>> sectionInfos = {};

    for (var definition in mergedDefinitions) {
      var sectionName = definition["section"]?.toCVUString(0, " ", false);
      if (sectionName != null) {
        if (!sections.contains(sectionName)) {
          sections.add(sectionName);
        }
        var newSection = sectionInfos[sectionName] ?? {};
        newSection = newSection.merge(newSection, definition);
        sectionInfos[sectionName] = newSection;
      }
    }

    return sections.compactMap((el) {
      var value = sectionInfos[el];
      if (value != null) {
        return GeneralEditorLayoutItem(el, value);
      }

      return null;
    });
  }

  Set<String> get usedFields {
    Set<String> uniqueFields = Set();

    for (var layoutItem in layout) {
      var fields =
          layoutItem.get<List>(propName: "fields", additionalType: String);
      if (fields != null) {
        for (var field in fields) {
          uniqueFields.add(field);
        }
      }
    }

    return uniqueFields;
  }

  List<Widget> get stackContent {
    var currentItem = viewContext.focusedItem;
    if (currentItem != null) {
      var _usedFields = usedFields;
      return [
        SizedBox(
          height: pageController.showTopBar ? 0 : 80,
        ),
        ...layout
            .map((layoutSection) => GeneralEditorSection(
                  viewContext: viewContext,
                  layout: layoutSection,
                  item: currentItem,
                  usedFields: _usedFields,
                  isEditing: !viewContext
                      .config.viewArguments!.args["readOnly"]!.value.value,
                  pageController: pageController,
                ))
            .toList()
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: pageController.isInEditMode,
        builder: (BuildContext context, bool value, Widget? child) {
          return RefreshIndicator(
            onRefresh: () async => updateState(),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                //TODO: from view or default value
                child: Column(
                  children: stackContent,
                ),
              ),
            ),
          );
        });
  }
}

class GeneralEditorSection extends StatefulWidget {
  final ViewContextController viewContext;
  final GeneralEditorLayoutItem layout;
  final ItemRecord item;
  final Set<String> usedFields;
  final bool isEditing;
  final memri.PageController pageController;

  GeneralEditorSection(
      {required this.viewContext,
      required this.layout,
      required this.item,
      required this.usedFields,
      required this.pageController,
      this.isEditing = false});

  @override
  _GeneralEditorSectionState createState() => _GeneralEditorSectionState();
}

class _GeneralEditorSectionState extends State<GeneralEditorSection> {
  late Future<String?> _sectionTitle;
  late Future<List<ItemRecord>> _edgeItems;

  String? currentSectionTitle;
  List<ItemRecord> currentEdgeItems = [];

  @override
  initState() {
    super.initState();
    init();
  }

  bool get shouldShowTitle {
    var showTitle = nodeDefinition?.properties["showTitle"];
    if (showTitle == null) {
      return true;
    }
    if (showTitle is CVUValueConstant) {
      var value = showTitle.value;
      if (value is CVUConstantBool) {
        return value.value;
      }
    }
    return true;
  }

  Future<String?> get sectionTitle async {
    var title = widget.viewContext.cvuController
        .viewDefinitionForItemRecord(itemRecord: widget.item)
        ?.definitions
        .first
        .get(widget.layout.id)
        ?.getSubdefinition()
        ?.properties["title"];
    if (title == null) {
      return widget.layout.id;
    }
    return await widget.viewContext.lookupController.resolve<String>(
        value: title,
        context: widget.viewContext.getCVUContext(item: widget.item),
        db: widget.viewContext.databaseController);
  }

  bool get isEditing {
    return widget.isEditing;
  }

  bool get isEmpty {
    if (isEditing) {
      return false;
    }
    return widget.layout.has("edges") &&
        fields.length == 0 &&
        currentEdgeItems.length == 0;
  }

  List<String> get fields {
    List<String> fields =
        (widget.layout.get<List>(propName: "fields", additionalType: String)
                as List<String>?) ??
            [];
    if (fields.isNotEmpty && fields[0] == "*") {
      fields = [];
      var propertyTypes = widget.viewContext.databaseController.schema
          .propertyNamesForItemType(widget.item.type);
      for (var propertyType in propertyTypes) {
        if (!widget.usedFields.contains(propertyType)) {
          fields.add(propertyType);
        }
      }
    }

    return fields;
  }

  Future<List<ItemRecord>> get edgeItems async {
    var edges =
        widget.layout.get<List>(propName: "edges", additionalType: String);
    if (edges == null) {
      return [];
    }
    List<ItemRecord> items = [];
    for (var edge in edges) {
      List<ItemRecord> edgeItems = await widget.viewContext.lookupController
          .resolve<List>(
              edge: edge,
              item: widget.item,
              db: widget.viewContext.databaseController) as List<ItemRecord>;
      items.addAll(edgeItems);
    }

    return items;
  }

  CVUDefinitionContent? get nodeDefinition {
    CVUDefinitionContent? nodeDefinition = widget.viewContext.cvuController
        .viewDefinitionForItemRecord(itemRecord: widget.item)
        ?.definitions
        .firstWhereOrNull(
            (definition) => definition.selector == "[renderer = generalEditor]")
        ?.get(widget.layout.id)
        ?.getSubdefinition();
    if (nodeDefinition != null) {
      return nodeDefinition;
    } else {
      nodeDefinition = widget.viewContext.cvuController
          .rendererDefinitionForSelector(
              viewName: widget.viewContext.config.rendererName)
          ?.properties[widget.layout.id]
          ?.getSubdefinition();
      if (nodeDefinition != null) {
        return nodeDefinition;
      } else {
        var viewName = widget.viewContext.config.viewName;
        if (viewName != null) {
          var nodeDefinition = widget.viewContext.cvuController
              .viewDefinitionFor(viewName: viewName)
              ?.definitions
              .firstWhereOrNull((definition) =>
                  definition.selector == "[renderer = generalEditor]")
              ?.get(widget.layout.id)
              ?.getSubdefinition();
          return nodeDefinition;
        }
      }
    }
    return null;
  }

  CVUViewArguments? get viewArguments {
    String? edgeType = widget.layout
        .get<List>(propName: "edges", additionalType: String)
        ?.asMap()[0];
    if (!isEditing || edgeType == null || !widget.layout.has("edges")) {
      return null;
    }

    var args = <String, CVUValue>{};
    args.addAll(widget.viewContext.config.viewArguments?.args ?? {});
    args["query"] = CVUValueConstant(CVUConstantString(widget.item.type));
    args["type"] = CVUValueConstant(CVUConstantString(edgeType));
    args["subject"] = CVUValueItem(widget.item.rowId!);
    args["item"] = CVUValueItem(widget.item.rowId!);
    args["edgeType"] = CVUValueConstant(CVUConstantString(edgeType));
    args["distinct"] = CVUValueConstant(CVUConstantBool(false));

    return CVUViewArguments(args: args, argumentItem: widget.item);
  }

  CVUActionOpenViewByName? get action {
    String? edgeType = widget.layout
        .get<List>(propName: "edges", additionalType: String)
        ?.asMap()[0];
    String? itemType = widget.layout.get<String>(propName: "type");
    if (!isEditing ||
        edgeType == null ||
        itemType == null ||
        !widget.layout.has("edges")) {
      return null;
    }

    Map<String, CVUValue> properties = {
      "query": CVUValueConstant(CVUConstantString(widget.item.type)),
      "type": CVUValueConstant(CVUConstantString(edgeType)),
      "subject": CVUValueItem(widget.item.rowId!),
      "item": CVUValueItem(widget.item.rowId!),
      "edgeType": CVUValueConstant(CVUConstantString(edgeType)),
      "distinct": CVUValueConstant(CVUConstantBool(false))
    };

    Map<String, CVUValue> vars = {
      "viewArguments":
          CVUValueSubdefinition(CVUDefinitionContent(properties: properties))
    };

    return CVUActionOpenViewByName(
        vars: vars,
        viewName: "itemByQuery",
        renderer: "list",
        itemType: itemType);
  }

  init() {
    _sectionTitle = sectionTitle;
    _edgeItems = edgeItems;
  }

  @override
  void didUpdateWidget(covariant GeneralEditorSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
        future: _sectionTitle,
        initialData: currentSectionTitle,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            currentSectionTitle = snapshot.data;
          }
          var title = snapshot.data;
          return FutureBuilder<List<ItemRecord>>(
              future: _edgeItems,
              initialData: currentEdgeItems,
              builder: (BuildContext context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  currentEdgeItems = snapshot.data!;
                }
                if (isEmpty == true) {
                  return Empty();
                } else {
                  List<Widget> header = [];
                  var layoutShowTitle =
                      widget.layout.get<bool>(propName: "showTitle");
                  if (shouldShowTitle &&
                      title != null &&
                      layoutShowTitle != false) {
                    header.add(GeneralEditorHeader(
                        content:
                            title.toUpperCase())); // .generalEditorHeader()
                    if (action != null) {
                      header.add(Spacer());
                      header.add(
                          ActionPopupButton(action!, widget.pageController));
                    }
                  }
                  List<Widget> content = [];

                  if (nodeDefinition != null) {
                    content = [
                      widget.viewContext.render(
                          item: widget.item, nodeDefinition: nodeDefinition)
                    ];
                  } else {
                    var _fields = fields;
                    _fields.sort();
                    _fields.forEach((field) {
                      var fieldProperty = AppController
                          .shared.databaseController.schema
                          .expectedPropertyType(widget.item.type, field);

                      if (fieldProperty != null) {
                        var schemaProperty = SchemaProperty(
                            widget.item.type, field, fieldProperty);
                        content.add(DefaultGeneralEditorRow(
                          viewContext: widget.viewContext,
                          property: schemaProperty,
                          currentItem: widget.item,
                          prop: field,
                          isLast: _fields.last == field,
                          item: widget.item,
                          isEditing: isEditing,
                          showLabel: _fields.length > 1,
                        ));
                      }
                    });

                    if (currentEdgeItems.isNotEmpty) {
                      currentEdgeItems.forEach((edgeItem) {
                        var nodeDefinition = widget.viewContext.cvuController
                            .edgeDefinitionFor(edgeItem);
                        if (nodeDefinition != null) {
                          content.add(widget.viewContext.render(
                              item: edgeItem,
                              nodeDefinition: nodeDefinition,
                              viewArguments: viewArguments));
                        }
                      });
                    }
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: header,
                      ),
                      ...content,
                      SizedBox(
                        height: 6,
                      ),
                      Divider(height: 1)
                    ],
                  );
                }
              });
        });
  }
}

class DefaultGeneralEditorRow extends StatelessWidget {
  final ViewContextController viewContext;

  final SchemaProperty property;
  final ItemRecord currentItem;
  final String prop;
  final bool isEditing;
  final bool isLast;
  final bool hasGroup;
  final ItemRecord item;
  final bool showLabel;

  DefaultGeneralEditorRow(
      {required this.viewContext,
      required this.property,
      required this.currentItem,
      required this.prop,
      this.isEditing = false,
      required this.isLast,
      this.hasGroup = false,
      this.showLabel = true,
      required this.item});

  bool get isEmpty {
    return false;
  }

  CVUDefinitionContent? get _nodeDefinition {
    var nodeDefinition = viewContext.cvuController
        .viewDefinitionForItemRecord(itemRecord: currentItem)
        ?.definitions
        .asMap()[0]
        ?.get(prop)
        ?.getSubdefinition();
    if (nodeDefinition == null) {
      nodeDefinition = viewContext.cvuController
          .rendererDefinitionForSelector(
              viewName: viewContext.config.rendererName)
          ?.properties[prop]
          ?.getSubdefinition();
    }
    if (nodeDefinition == null) {
      var viewName = viewContext.config.viewName;
      if (viewName != null) {
        nodeDefinition = viewContext.cvuController
            .viewDefinitionFor(viewName: viewName)
            ?.properties[prop]
            ?.getSubdefinition();
      }
    }
    return nodeDefinition;
  }

  @override
  Widget build(BuildContext context) {
    var propType = property.valueType;
    var nodeDefinition = _nodeDefinition;
    Widget currentWidget = defaultRow();
    if (nodeDefinition == null) {
      switch (propType) {
        case SchemaValueType.string:
          currentWidget = stringRow();
          break;
        case SchemaValueType.bool:
          currentWidget = boolRow();
          break;
        case SchemaValueType.datetime:
          currentWidget = dateRow();
          break;
        case SchemaValueType.int:
          currentWidget = intRow();
          break;
        case SchemaValueType.double:
          currentWidget = doubleRow();
          break;
        default:
          break;
      }
    }
    return Column(
      children: [
        Container(
          //padding: EdgeInsets.fromLTRB(10, 0, 5, 10),
          color: CVUColor.system("systemBackground"),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showLabel)
                _GeneralEditorLabel(
                    content: prop
                        .camelCaseToWords()
                        .toLowerCase()
                        .capitalizingFirst()),
              nodeDefinition != null
                  ? viewContext.render(
                      item: item, nodeDefinition: nodeDefinition)
                  : currentWidget,
              if (!isLast)
                Divider(
                  height: 1,
                )
            ],
          ),
        )
      ],
    );
  }

  Widget stringRow() {
    var binding = FutureBinding<String>(
        () async =>
            (await currentItem.propertyValue(property.property))?.asString() ??
            "",
        (value) => currentItem.setPropertyValue(
            prop, PropertyDatabaseValueString(value)));
    return MemriTextField.async(
      futureBinding: binding,
      style: generalEditorCaptionStyle(),
      isEditing: isEditing,
    );
  }

  Widget boolRow() {
    /*var binding = FutureBinding<bool>(
        () async => (await currentItem.propertyValue(property.property))?.asBool() ?? false,
        (value) async {
      var currentVal = (await currentItem.propertyValue(property.property))?.asBool() ?? false;
      currentItem.setPropertyValue(prop, PropertyDatabaseValueBool(!currentVal));
    });*/
    return Text("Toggle"); //TODO
    /* return Toggle(isOn: binding) {
            Text(prop
                .camelCaseToWords()
                .lowercased()
                .capitalizingFirst())
        }
        .generalEditorCaption()*/
  }

  Widget intRow() {
    var binding = FutureBinding<int>(
        () async =>
            (await currentItem.propertyValue(property.property))?.asInt() ?? 0,
        (value) async => currentItem.setPropertyValue(
            prop, PropertyDatabaseValueInt(value)));

    return MemriTextField.async(
      futureBinding: binding,
      style: generalEditorCaptionStyle(),
      isEditing: isEditing,
    );
  }

  Widget doubleRow() {
    var binding = FutureBinding<double>(
        () async =>
            (await currentItem.propertyValue(property.property))?.asDouble() ??
            0,
        (value) async => await currentItem.setPropertyValue(
            prop, PropertyDatabaseValueDouble(value)));

    return MemriTextField.async(
        futureBinding: binding,
        style: generalEditorCaptionStyle(),
        isEditing: isEditing);
  }

  Widget dateRow() {
    var binding = FutureBinding<DateTime?>(
        () async =>
            (await currentItem.propertyValue(property.property))?.asDate(),
        (value) async => await currentItem.setPropertyValue(
            prop, PropertyDatabaseValueDatetime(value!)));
    return FutureBuilder<DateTime?>(
      future: binding.get(),
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.done
              ? MemriDatePicker(
                  initialSet: snapshot.data,
                  onPressed: isEditing
                      ? (DateTime value) async => await binding.set(value)
                      : null,
                  formatter: "MMM d, yyyy",
                  style: generalEditorCaptionStyle(),
                  isEditing: isEditing)
              : Empty(),
    );
  }

  Widget defaultRow([String? caption]) {
    return _GeneralEditorCaption(
        content: caption ??
            prop.camelCaseToWords().toLowerCase().capitalizingFirst());
  }

  TextStyle generalEditorCaptionStyle() {
    return TextStyle(
      color: Color(0xFF737373),
      fontWeight: FontWeight.normal,
      fontSize: 13,
    );
  }
}

// ignore: unused_element
class _GeneralEditorInput extends StatelessWidget {
  final content;

  _GeneralEditorInput({required this.content});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: TextField(
      style: TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 16,
      ),
    ));
  }
}

class _GeneralEditorLabel extends StatelessWidget {
  final String content;

  _GeneralEditorLabel({required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(
        content,
        style: TextStyle(
          color: Color(0xFF38761d),
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _GeneralEditorCaption extends StatelessWidget {
  final String content;

  _GeneralEditorCaption({required this.content});

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: TextStyle(
        color: Color(0xFF223322),
        fontWeight: FontWeight.normal,
        fontSize: 18,
      ),
    );
  }
}

class GeneralEditorHeader extends StatelessWidget {
  final String content;

  GeneralEditorHeader({required this.content});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.only(top: 11.0, bottom: 5),
      child: Text(
        content,
        style: TextStyle(
          color: Color(0xFF828282),
          fontWeight: FontWeight.normal,
          fontSize: 10,
        ),
      ),
    ));
  }
}
