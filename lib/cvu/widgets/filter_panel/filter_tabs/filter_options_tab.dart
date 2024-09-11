import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:memri/cvu/controllers/database_query.dart';
import 'package:memri/widgets/components/memri_text_field.dart';

import '../../../../core/services/database/schema.dart';
import '../../../../utilities/extensions/icon_data.dart';
import '../../../../widgets/components/optional_date_picker.dart';
import '../../../controllers/view_context_controller.dart';
import '../../../utilities/binding.dart';

class FilterOptionsTab extends StatefulWidget {
  final ViewContextController viewContext;

  const FilterOptionsTab(this.viewContext);

  @override
  State<FilterOptionsTab> createState() => _FilterOptionsTabState();
}

class _FilterOptionsTabState extends State<FilterOptionsTab> {
  var excludedFilterFields = [
    "abstract",
    "id",
    "deleted",
    "externalId",
    "version",
    "allEdges",
    "dateServerModified"
        "itemType",
    "transcript",
    "dateCreated",
    "dateModified",
  ];

  Widget optionalDateRow(String title, Binding<DateTime?> selection, [DateTime? initialSet]) {
    initialSet ??= DateTime.now();
    return OptionalDatePicker(title: title, selection: selection, initialSet: initialSet);
  }

  List<String> get filterFields {
    var itemTypes = widget.viewContext.config.query.itemTypes;
    List<String> fields = GetIt.I<Schema>().propertyNamesForItemType(itemTypes[0] ?? "");
    return fields.where((field) => !excludedFilterFields.contains(field)).toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    var date = DateTime.now();
    List<Widget> filterOptions = [
      optionalDateRow(
          "Modified after",
          Binding(() => widget.viewContext.config.query.dateModifiedAfter,
              (newValue) => widget.viewContext.config.query.dateModifiedAfter = newValue),
          date.subtract(Duration(days: 7))),
      optionalDateRow(
          "Modified before",
          Binding(() => widget.viewContext.config.query.dateModifiedBefore,
              (newValue) => widget.viewContext.config.query.dateModifiedBefore = newValue)),
      optionalDateRow(
          "Created after",
          Binding(() => widget.viewContext.config.query.dateCreatedAfter,
              (newValue) => widget.viewContext.config.query.dateCreatedAfter = newValue),
          date.subtract(Duration(days: 7))),
      optionalDateRow(
          "Created before",
          Binding(() => widget.viewContext.config.query.dateCreatedBefore,
              (newValue) => widget.viewContext.config.query.dateCreatedBefore = newValue)),
    ];

    filterOptions.addAll(filterFields.map((el) => FilterPanelFilterItemView(
        property: el,
        selection:
            Binding(() => widget.viewContext.config.query.getPropertyCondition(el)?.value,
                (newValue) {
          widget.viewContext.config.query.removePropertyCondition(el);
          if (newValue != null) {
            widget.viewContext.config.query.addPropertyCondition(el, newValue, ComparisonType.like);
          }
        }))));

    return ListView.separated(
        physics: BouncingScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) => ListTile(
              dense: true,
              minVerticalPadding: 0,
              title: filterOptions[index],
            ),
        separatorBuilder: (context, index) => Divider(
              height: 0,
            ),
        itemCount: filterOptions.length);
  }
}

class FilterPanelFilterItemView extends StatefulWidget {
  final String property;
  final Binding selection;

  FilterPanelFilterItemView({required this.property, required this.selection});

  @override
  State<FilterPanelFilterItemView> createState() => _FilterPanelFilterItemViewState();
}

class _FilterPanelFilterItemViewState extends State<FilterPanelFilterItemView> {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [Text(widget.property), Spacer(), ...setBinding()],
      ),
    );
  }

  List<Widget> setBinding() {
    if (_isEditing) {
      return [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            color: Colors.black12,
            child: MemriTextField.sync(binding: widget.selection),
          ),
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
            _isEditing = true; // Switch to the editing mode
          }),
          child: Text("Set"),
        )
      ];
    }
  }
}
