import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:jiffy/jiffy.dart';
import 'package:memri/cvu/controllers/database_query.dart';
import 'package:memri/utilities/extensions/string.dart';
import 'package:memri/widgets/components/memri_text_field.dart';
import 'package:memri/widgets/components/toggle.dart';

import '../../../../core/services/database/schema.dart';
import '../../../../utilities/extensions/icon_data.dart';
import '../../../controllers/view_context_controller.dart';
import '../../../utilities/binding.dart';

class FilterOptionsTab extends StatefulWidget {
  final ViewContextController viewContext;

  const FilterOptionsTab(this.viewContext);

  @override
  State<FilterOptionsTab> createState() => _FilterOptionsTabState();
}

class _FilterOptionsTabState extends State<FilterOptionsTab> {
  late Schema _schema;
  late String itemType;
  var excludedFilterFields = [
    "abstract",
    "id",
    "deleted",
    "externalId",
    "version",
    "allEdges",
    "dateServerModified",
    "itemType",
    "transcript",
    "dateCreated",
    "dateModified",
  ];

  List<String> get filterFields {
    List<String> properties = _schema.propertyNamesForItemType(itemType);
    var fields = properties.where((field) => !excludedFilterFields.contains(field)).toList()..sort();
    return fields..insertAll(0, ["dateModified", "dateCreated"]);
  }

  @override
  Widget build(BuildContext context) {
    _schema = GetIt.I<Schema>();
    itemType = widget.viewContext.config.query.itemTypes[0] ?? "";
    var date = DateTime.now();
    var weekAgo = date.subtract(Duration(days: 7));

    List<Widget> filterOptions = filterFields.expand((property) {
      var propertyType = _schema.expectedPropertyType(itemType, property)!;
      if (property == "dateModified" || property == "dateCreated")
        propertyType = SchemaValueType.datetime;//TODO why in our schema they're not datetime?
      var title = property.camelCaseToWords();
      switch (propertyType) {
        case SchemaValueType.bool:
          return [filterItem<bool>(title, property, ComparisonType.equals)];
        case SchemaValueType.datetime:
          if (title.startsWith("Date "))
            title = title.replaceFirst("Date ", "").capitalizingFirst();
          return [
            filterItem<DateTime>(title + " after", property, ComparisonType.greaterThan, weekAgo),
            filterItem<DateTime>(title + " before", property, ComparisonType.lessThan, date),
          ];
        default:
          return [filterItem<String>(title, property, ComparisonType.like)];
      }
    }).toList();

    return ListView.separated(
        physics: BouncingScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) =>
            ListTile(
              dense: true,
              minVerticalPadding: 0,
              title: filterOptions[index],
            ),
        separatorBuilder: (context, index) =>
            Divider(
              height: 0,
            ),
        itemCount: filterOptions.length);
  }

  FilterPanelFilterItemView<T> filterItem<T>(
      String title,
      String property,
      ComparisonType comparisonType,
      [T? initialSet]
      ) {
    var query = widget.viewContext.config.query;
    return FilterPanelFilterItemView<T>(
        title: title,
        selection:
            Binding<T?>(() => query.getPropertyCondition(property)?.value,
                (newValue) {
              if (newValue == null) {
                query.removePropertyCondition(property, comparisonType);
              } else {
                query.addPropertyCondition(property, newValue, comparisonType);
              }
        }),
        initialSet: initialSet,
    );
  }
}

class FilterPanelFilterItemView<T> extends StatefulWidget {
  final String title;
  final Binding<T?> selection;
  final T? initialSet;

  FilterPanelFilterItemView({required this.title, required this.selection, this.initialSet});

  @override
  State<FilterPanelFilterItemView> createState() => _FilterPanelFilterItemViewState<T>();
}

class _FilterPanelFilterItemViewState<T> extends State<FilterPanelFilterItemView<T>> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Text(widget.title),
          Spacer(),
          ...setBinding()
        ],
      ),
    );
  }

  List<Widget> setBinding() {
    if (_isEditing) {
      return [
        Expanded(
          child: field,
        ),
        IconButton(
          onPressed: () => setState(() {
            _isEditing = false; // Toggle back to the "Set" button mode
            widget.selection.set(null);
          }),
          icon: Icon(MemriIcon.getByName("xmark.circle")),
          padding: EdgeInsets.all(5),
        )
      ];
    } else {
      return [
        TextButton(
          onPressed: () => setState(() {
            widget.selection.set(widget.initialSet);
            _isEditing = true; // Switch to the editing mode
          }),
          child: Text("Set"),
        )
      ];
    }
  }

  Widget get field {
    switch (T) {
      case DateTime:
        return dateField;
      case bool:
        return boolField;
      default:
        return stringField;
    }
  }

  _selectDate(BuildContext context) async {
    var selection = widget.selection as Binding<DateTime?>;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (selection.get()),
      firstDate: DateTime.now().subtract(Duration(days: 365 * 100)),
      lastDate: DateTime.now().add(Duration(days: 365 * 5)),
    );
    if (picked != null && picked != selection.get())
      setState(() {
        selection.set(picked);
      });
  }

  Widget get dateField {
    var selection = widget.selection as Binding<DateTime?>;
    return TextButton(
      onPressed: () => _selectDate(context),
      child: Text(Jiffy.parseFromDateTime(selection.get()!).format(pattern: 'yyyy-MM-dd')),
    );
  }

  Widget get boolField {
    var binding = widget.selection as Binding<bool?>;
    return Toggle(binding: binding, isEditing: true);
  }

  Widget get stringField {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      color: Colors.black12,
      child: MemriTextField.sync(binding: widget.selection),
    );
  }
}
