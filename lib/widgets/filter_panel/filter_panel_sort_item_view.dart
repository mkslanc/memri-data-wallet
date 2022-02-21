import 'package:flutter/material.dart';
import 'package:memri/utils/binding.dart';
import 'package:memri/utils/extensions/string.dart';

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
