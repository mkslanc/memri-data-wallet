import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:memri/utilities/extensions/string.dart';

import '../../../../core/services/database/schema.dart';
import '../../../controllers/view_context_controller.dart';
import '../../../utilities/binding.dart';

class SortOptionsTab extends StatefulWidget {
  final ViewContextController viewContext;

  const SortOptionsTab(this.viewContext);

  @override
  State<SortOptionsTab> createState() => _SortOptionsTabState();
}

class _SortOptionsTabState extends State<SortOptionsTab> {
  var excludedSortFields = [
    "abstract",
    "id",
    "deleted",
    "externalId",
    "version",
    "allEdges",
    "dateServerModified",
    "itemType",
    "transcript"
  ];
  var defaultSortFields = [];

  List<String> get sortFields {
    var item = widget.viewContext.items.asMap()[0];
    List<String> fields = GetIt.I<Schema>().propertyNamesForItemType(item?.type ?? "");

    return fields.where((field) => !excludedSortFields.contains(field)).toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    var fields = sortFields;
    if (fields.isEmpty)
      return Text("No sort options available.");
    return ListView.separated(
        physics: BouncingScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) => ListTile(
          dense: true,
          minVerticalPadding: 0,
          title: FilterPanelSortItemView(
            property: fields[index],
            selection: Binding(
                    () => widget.viewContext.config.query.sortProperty,
                    (sortProperty) => setState(() {
                      widget.viewContext.config.query.sortProperty = sortProperty;
                    })),
          ),
        ),
        separatorBuilder: (context, index) => Divider(
          height: 0,
        ),
        itemCount: fields.length
    );
  }
}

class FilterPanelSortItemView extends StatelessWidget {
  final String property;
  final Binding<String?> selection;

  FilterPanelSortItemView({required this.property, required this.selection});

  @override
  Widget build(BuildContext context) {
    var isSelected = selection.get() == property;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 40),
      child: Row(
        children: [
          Text(
            property.camelCaseToWords(),
            style: TextStyle(fontWeight: isSelected ? FontWeight.bold : null),
          ),
          Spacer(),
          isSelected
              ? TextButton(child: Icon(Icons.close_rounded), onPressed: () => selection.set(null))
              : TextButton(onPressed: () => selection.set(property), child: Text("Set"))
        ],
      ),
    );
  }
}