import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUViewArguments.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/Controllers/Database/Schema.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Dictionary.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes//String.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import 'package:memri/MemriApp/UI/Components/Button/ActionButton.dart';
import 'package:memri/MemriApp/UI/Components/MemriDatePicker.dart';
import 'package:memri/MemriApp/UI/Components/Text/TextField/MemriTextfield.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import '../ViewContextController.dart';

class GeneralEditorLayoutItem {
  String id;
  Map<String, CVUValue> dict;

  GeneralEditorLayoutItem(this.id, this.dict);

  bool has(String propName) {
    return dict.containsKey(propName);
  }

  T? get<T>({required String propName, ItemRecord? item, Type? additionalType}) {
    var propValue = dict[propName];
    if (propValue == null) {
      if (propName == "section") {
        print("ERROR: tri");
      }
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

    return propValue as T;
  }
}

/// The GeneralEditorRenderer
/// This presents an editor for a single item
class GeneralEditorRendererView extends StatefulWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  GeneralEditorRendererView({required this.sceneController, required this.viewContext});

  @override
  _GeneralEditorRendererViewState createState() => _GeneralEditorRendererViewState();
}

class _GeneralEditorRendererViewState extends State<GeneralEditorRendererView> {
  updateState() => setState(() {});

  @override
  initState() {
    super.initState();
    widget.sceneController.addListener(updateState);
  }

  @override
  dispose() {
    super.dispose();
    widget.sceneController.removeListener(updateState);
  }

  List<GeneralEditorLayoutItem> get layout {
    var currentItem = widget.viewContext.focusedItem;
    if (currentItem == null) {
      return [];
    }
    var viewLayout = widget.viewContext.cvuController
        .viewDefinitionForItemRecord(itemRecord: currentItem)
        ?.definitions
        .asMap()[0]
        ?.get("layout");
    List<Map<String, CVUValue>>? viewDefs = [];

    if (viewLayout is CVUValueArray) {
      var values = viewLayout.value;
      viewDefs.addAll(values.compactMap((value) => value.getSubdefinition()?.properties));
    }

    var generalLayout = widget.viewContext.cvuController
        .rendererDefinitionForSelector(selector: "[renderer = ${widget.viewContext.config.rendererName}]")
        ?.properties["layout"];
    List<Map<String, CVUValue>>? generalDefs = [];
    if (generalLayout is CVUValueArray) {
      var values = generalLayout.value;
      generalDefs.addAll(values.compactMap((value) => value.getSubdefinition()?.properties));
    }
    if (viewDefs.isEmpty || generalDefs.isEmpty) {
      return [];
    }

    var mergedDefinitions = [];
    mergedDefinitions.addAll(viewDefs);
    mergedDefinitions.addAll(generalDefs);

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
      var fields = layoutItem.get<List>(propName: "fields", additionalType: String);
      if (fields != null) {
        for (var field in fields) {
          uniqueFields.add(field);
        }
      }
    }

    return uniqueFields;
  }

  List<Widget> get stackContent {
    var currentItem = widget.viewContext.focusedItem;
    if (currentItem != null) {
      return layout
          .map((layoutSection) => GeneralEditorSection(
              viewContext: widget.viewContext, layout: layoutSection, item: currentItem, usedFields: usedFields))
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.sceneController.isInEditMode,
        builder: (BuildContext context, bool value, Widget? child) {
          return Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: stackContent,
            ),
          ));
        });
  }
}

class GeneralEditorSection extends StatefulWidget {
  final ViewContextController viewContext;
  final GeneralEditorLayoutItem layout;
  final ItemRecord item;
  final Set<String> usedFields;

  GeneralEditorSection({required this.viewContext, required this.layout, required this.item, required this.usedFields});

  @override
  _GeneralEditorSectionState createState() => _GeneralEditorSectionState();
}

class _GeneralEditorSectionState extends State<GeneralEditorSection> {
  final SceneController sceneController = SceneController.sceneController;

  late Future<String?> _sectionTitle;
  late Future<List<ItemRecord>> _edgeItems;

  String? currentSectionTitle;
  List<ItemRecord> currentEdgeItems = [];


  @override
  initState() {
    super.initState();
    init();
  }

  SchemaType? get schemaType {
    var type = widget.item.type;
    return sceneController.appController.databaseController.schema.types[type];
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
    return sceneController.isInEditMode.value;
  }

  bool get isEmpty {
    if (sceneController.isInEditMode.value) {
      return false;
    }
    return widget.layout.has("edges") && fields.length == 0 && currentEdgeItems.length == 0;
  }

  List<String> get fields {
    List<String> fields = (widget.layout.get<List>(propName: "fields", additionalType: String) as List<String>?) ?? [];
    if (fields.isNotEmpty && fields[0] == "*") {
      fields = [];
      var propertyTypes = widget.viewContext.databaseController.schema.types[widget.item.type]?.propertyTypes ?? {};
      for (var propertyType in propertyTypes.keys) {
        if (!widget.usedFields.contains(propertyType)) {
          fields.add(propertyType);
        }
      }
    }

    return fields;
  }

  Future<List<ItemRecord>> get edgeItems async {
    var edges = widget.layout.get<List>(propName: "edges", additionalType: String);
    if (edges == null) {
      return [];
    }
    List<ItemRecord> items = [];
    for (var edge in edges) {
      List<ItemRecord> edgeItems = await widget.viewContext.lookupController
          .resolve<List>(edge: edge, item: widget.item, db: widget.viewContext.databaseController) as List<ItemRecord>;
      items.addAll(edgeItems);
    }

    return items;
  }

  CVUDefinitionContent? get nodeDefinition {
    CVUDefinitionContent? nodeDefinition = widget.viewContext.cvuController
        .viewDefinitionForItemRecord(itemRecord: widget.item)
        ?.definitions
        .asMap()[0]
        ?.get(widget.layout.id)
        ?.getSubdefinition();
    if (nodeDefinition != null) {
      return nodeDefinition;
    } else {
      nodeDefinition = widget.viewContext.cvuController
          .rendererDefinitionForSelector(viewName: widget.viewContext.config.rendererName)
          ?.properties[widget.layout.id]
          ?.getSubdefinition();
      if (nodeDefinition != null) {
        return nodeDefinition;
      }
    }
    return null;
  }

  CVUViewArguments? get viewArguments {
    String? edgeType = widget.layout.get<List>(propName: "edges", additionalType: String)?.asMap()[0];
    if (!isEditing || edgeType == null || !widget.layout.has("edges")) {
      return null;
    }

    var args = widget.viewContext.config.viewArguments?.args ?? <String, CVUValue>{};
    args["query"] = CVUValueConstant(CVUConstantString(widget.item.type));
    args["type"] = CVUValueConstant(CVUConstantString(edgeType));
    args["subject"] = CVUValueItem(widget.item.rowId!);
    args["item"] = CVUValueItem(widget.item.rowId!);
    args["edgeType"] = CVUValueConstant(CVUConstantString(edgeType));
    args["distinct"] = CVUValueConstant(CVUConstantBool(false));

    return CVUViewArguments(args: args, argumentItem: widget.item);
  }

  CVUActionOpenViewByName? get action {
    String? edgeType = widget.layout.get<List>(propName: "edges", additionalType: String)?.asMap()[0];
    String? itemType = widget.layout.get<String>(propName: "type");
    if (!isEditing || edgeType == null || itemType == null || !widget.layout.has("edges")) {
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

    Map<String, CVUValue> vars = {"viewArguments": CVUValueSubdefinition(CVUDefinitionContent(properties: properties))};

    return CVUActionOpenViewByName(vars: vars, viewName: "itemByQuery", renderer: "list", itemType: itemType);
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
                  if (shouldShowTitle && title != null) {
                    header.add(_GeneralEditorHeader(content: title.toUpperCase())); // .generalEditorHeader()
                    if (action != null) {
                      header.add(Spacer());
                      header.add(ActionPopupButton(action!));
                    }
                  }
                  List<Widget> content = [];

                  if (nodeDefinition != null) {
                    content = [widget.viewContext.render(item: widget.item, nodeDefinition: nodeDefinition)];
                  } else {
                    fields.sort();
                    fields.forEach((field) {
                      var fieldProperty = schemaType?.propertyTypes[field];
                      if (fieldProperty != null) {
                        content.add(DefaultGeneralEditorRow(
                            viewContext: widget.viewContext,
                            property: fieldProperty,
                            currentItem: widget.item,
                            prop: field,
                            isLast: fields.last == field,
                            item: widget.item));
                      }
                    });

                    if (currentEdgeItems.isNotEmpty) {
                      currentEdgeItems.forEach((edgeItem) {
                        var nodeDefinition = widget.viewContext.cvuController.edgeDefinitionFor(edgeItem);
                        if (nodeDefinition != null) {
                          content.add(widget.viewContext
                              .render(item: edgeItem, nodeDefinition: nodeDefinition, viewArguments: viewArguments));
                        }
                      });
                    }
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 20, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: header,
                        ),
                      ),
                      Divider(
                        height: 1,
                      ),
                      ...content,
                      Divider(height: 1)
                    ],
                  );
                }
              });
        });
  }
}

class DefaultGeneralEditorRow extends StatelessWidget {
  final SceneController sceneController = SceneController.sceneController;
  final ViewContextController viewContext;

  final SchemaProperty property;
  final ItemRecord currentItem;
  final String prop;
  final bool readOnly;
  final bool isLast;
  final bool hasGroup;
  final ItemRecord item;

  DefaultGeneralEditorRow(
      {required this.viewContext,
      required this.property,
      required this.currentItem,
      required this.prop,
      this.readOnly = false,
      required this.isLast,
      this.hasGroup = false,
      required this.item});

  bool get isEmpty {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var propType = property.valueType;
    var nodeDefinition = viewContext.cvuController
        .rendererDefinitionForSelector(viewName: viewContext.config.rendererName)
        ?.properties[prop]
        ?.getSubdefinition();
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
          currentWidget = defaultRow();
          break;
      }
    }
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(10, 0, 5, 10),
          color: CVUColor.system("systemBackground"),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GeneralEditorLabel(content: prop.camelCaseToWords().toLowerCase().capitalizingFirst()),
              nodeDefinition != null ? viewContext.render(item: item, nodeDefinition: nodeDefinition) : currentWidget,
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
        () async => (await currentItem.propertyValue(property.property))?.asString() ?? "",
        (value) => currentItem.setPropertyValue(prop, PropertyDatabaseValueString(value)));
    return MemriTextField.async(
      futureBinding: binding,
      style: generalEditorCaptionStyle(),
      isEditing: sceneController.isInEditMode.value,
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
    var binding = FutureBinding<int>(() async => (await currentItem.propertyValue(property.property))?.asInt() ?? 0,
        (value) async => currentItem.setPropertyValue(prop, PropertyDatabaseValueInt(value)));

    return MemriTextField.async(
      futureBinding: binding,
      style: generalEditorCaptionStyle(),
      isEditing: sceneController.isInEditMode.value,
    );
  }

  Widget doubleRow() {
    var binding = FutureBinding<double>(
        () async => (await currentItem.propertyValue(property.property))?.asDouble() ?? 0,
        (value) async => await currentItem.setPropertyValue(prop, PropertyDatabaseValueDouble(value)));

    return MemriTextField.async(
        futureBinding: binding, style: generalEditorCaptionStyle(), isEditing: sceneController.isInEditMode.value);
  }

  Widget dateRow() {
    var binding = FutureBinding<DateTime?>(() async => (await currentItem.propertyValue(property.property))?.asDate(),
        (value) async => await currentItem.setPropertyValue(prop, PropertyDatabaseValueDatetime(value!)));
    return FutureBuilder<DateTime?>(
      future: binding.get(),
      builder: (context, snapshot) => snapshot.connectionState == ConnectionState.done
          ? MemriDatePicker(
              initialSet: snapshot.data,
              onPressed: sceneController.isInEditMode.value ? (DateTime value) async => await binding.set(value) : null,
              formatter: "MMM d, yyyy",
              style: generalEditorCaptionStyle(),
              isEditing: sceneController.isInEditMode.value)
          : Empty(),
    );
  }

  Widget defaultRow([String? caption]) {
    return _GeneralEditorCaption(content: caption ?? prop.camelCaseToWords().toLowerCase().capitalizingFirst());
  }

  TextStyle generalEditorCaptionStyle() {
    return TextStyle(
      color: Color(0xFF223322),
      fontWeight: FontWeight.normal,
      fontSize: 18,
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
        child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 16,
        ),
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

class _GeneralEditorHeader extends StatelessWidget {
  final String content;

  _GeneralEditorHeader({required this.content});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 5),
      child: Text(
        content,
        style: TextStyle(
          color: Color(0xFF333333),
          fontWeight: FontWeight.normal,
          fontSize: 15,
        ),
      ),
    ));
  }
}
