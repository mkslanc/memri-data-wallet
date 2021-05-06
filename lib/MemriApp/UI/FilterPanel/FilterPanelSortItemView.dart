import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';

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
