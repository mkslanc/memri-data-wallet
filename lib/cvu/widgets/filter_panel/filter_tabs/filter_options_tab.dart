import 'package:flutter/material.dart';

import '../../../../widgets/components/optional_date_picker.dart';
import '../../../controllers/view_context_controller.dart';
import '../../../utilities/binding.dart';

class FilterOptionsTab extends StatelessWidget {
  final ViewContextController viewContext;

  const FilterOptionsTab(this.viewContext);

  Widget optionalDateRow(String title, Binding<DateTime?> selection, [DateTime? initialSet]) {
    initialSet ??= DateTime.now();
    return OptionalDatePicker(title: title, selection: selection, initialSet: initialSet);
  }

  @override
  Widget build(BuildContext context) {
    var date = DateTime.now();
    List<Widget> filterOptions = [
      optionalDateRow(
          "Modified after",
          Binding(() => viewContext.config.query.dateModifiedAfter,
                  (newValue) => viewContext.config.query.dateModifiedAfter = newValue),
          date.subtract(Duration(days: 7))),
      optionalDateRow(
          "Modified before",
          Binding(() => viewContext.config.query.dateModifiedBefore,
                  (newValue) => viewContext.config.query.dateModifiedBefore = newValue)),
      optionalDateRow(
          "Created after",
          Binding(() => viewContext.config.query.dateCreatedAfter,
                  (newValue) => viewContext.config.query.dateCreatedAfter = newValue),
          date.subtract(Duration(days: 7))),
      optionalDateRow(
          "Created before",
          Binding(() => viewContext.config.query.dateCreatedBefore,
                  (newValue) => viewContext.config.query.dateCreatedBefore = newValue)),
    ];
    return ListView.separated(
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