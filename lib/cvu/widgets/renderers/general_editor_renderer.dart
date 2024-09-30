import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:memri/core/models/item.dart';
import 'package:memri/cvu/widgets/renderers/renderer.dart';
import 'package:memri/utilities/extensions/string.dart';

import '../../../core/services/database/schema.dart';
import '../../../widgets/components/memri_date_picker.dart';
import '../../../widgets/components/memri_text_field.dart';
import '../../../widgets/components/toggle.dart';
import '../../constants/cvu_color.dart';
import '../../controllers/view_context_controller.dart';
import '../../models/cvu_parsed_definition.dart';
import '../../utilities/binding.dart';

class GeneralEditorRendererView extends Renderer {
  GeneralEditorRendererView({required viewContext})
      : super(viewContext: viewContext);

  @override
  _GeneralEditorRendererViewState createState() => _GeneralEditorRendererViewState();
}

class _GeneralEditorRendererViewState extends RendererViewState {
  Item? currentItem;
  late final Schema schema;
  List<String> excludedFields = [
    "abstract",
    "id",
    "deleted",
    "version",
    "dateCreated",
    "dateModified",
    "dateServerModified",
    "itemType",
    "transcript",
  ];

  @override
  initState() {
    super.initState();
    schema = GetIt.I<Schema>();
    currentItem = widget.viewContext.focusedItem;
  }

  List<String> get fields {
    List<String> _fields = [];

    var propertyTypes = schema.propertyNamesForItemType(currentItem!.type);
    for (var propertyType in propertyTypes) {
      if (!excludedFields.contains(propertyType))
        _fields.add(propertyType);
    }

    return _fields..sort();
  }

  List<Widget> get stackContent {
    if (currentItem != null) {
      return [
        ...fields.asMap().entries.map((entry) => _GeneralEditorRow(
            viewContext: widget.viewContext,
            property: schema.expectedProperty(currentItem!.type, entry.value)!,
            currentItem: currentItem!,
            isLast: entry.key == fields.length - 1))
            .toList()
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
        children: stackContent,
    ),
  );
}

class _GeneralEditorRow extends StatelessWidget {
  final ViewContextController viewContext;

  final SchemaProperty property;
  final Item currentItem;
  final bool isLast;
  final String prop;
  late final bool isEditing;

    _GeneralEditorRow({
      required this.viewContext,
      required this.property,
      required this.currentItem,
      required this.isLast,
    }) : prop = property.property;


    CVUDefinitionContent? get _nodeDefinition {
    var nodeDefinition = viewContext.cvuController
        .viewDefinitionForItemRecord(item: currentItem)
        ?.definitions
        .asMap()[0]
        ?.get(prop)
        ?.getSubdefinition();
    if (nodeDefinition == null) {
      nodeDefinition = viewContext.cvuController
          .rendererDefinitionForSelector(viewName: viewContext.config.rendererName)
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
    isEditing = viewContext.isInEditMode;
    var nodeDefinition = _nodeDefinition;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(10, 0, 5, 10),
          color: CVUColor.system("systemBackground"),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GeneralEditorLabel(
                  content: prop.camelCaseToWords()),
              nodeDefinition != null
                  ? viewContext.render(item: currentItem, nodeDefinition: nodeDefinition)
                  : currentWidget,
              // if (!isLast)
                Divider(
                  height: 0,
                )
            ],
          ),
        )
      ],
    );
  }

  Widget get currentWidget {
    var propType = property.valueType;
    switch (propType) {
      case SchemaValueType.string:
        return stringRow;
      case SchemaValueType.bool:
        return boolRow;
      case SchemaValueType.datetime:
        return dateRow;
      case SchemaValueType.int:
        return intRow;
      case SchemaValueType.double:
        return doubleRow;
      default:
        return defaultRow;
    }
  }

  Widget get stringRow {
    return MemriTextField.sync(
      binding: Binding<String>.forItem(currentItem, prop, ""),
      style: style,
      isEditing: isEditing,
    );
  }

  Widget get boolRow {
    var binding = Binding.forItem(currentItem, prop, false);
    return Toggle(binding: binding, isEditing: isEditing);
  }

  Widget get intRow {
    return MemriTextField.sync(
      binding: Binding<int>.forItem(currentItem, prop, 0),
      style: style,
      isEditing: isEditing,
    );
  }

  Widget get doubleRow {
    return MemriTextField.sync(
      binding: Binding<double>.forItem(currentItem, prop, 0),
      style: style,
      isEditing: isEditing,
    );
  }

  Widget get dateRow {
    return MemriDatePicker(
        binding: Binding<DateTime?>.forItem(currentItem, prop, null),
        formatter: "MMM d, yyyy",
        style: style,
        isEditing: isEditing);
  }

  Widget get defaultRow {
    return _GeneralEditorCaption(
        content: prop.camelCaseToWords());
  }

  TextStyle get style {
    return TextStyle(
      color: Color(0xFF223322),
      fontWeight: FontWeight.normal,
      fontSize: 18,
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