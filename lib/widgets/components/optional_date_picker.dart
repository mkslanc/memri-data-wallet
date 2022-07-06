import 'package:flutter/material.dart';
import 'package:memri/cvu/utilities/binding.dart';
import 'package:memri/utilities/extensions/icon_data.dart';

class OptionalDatePicker extends StatefulWidget {
  final String title;
  final Binding<DateTime?> selection;
  final DateTime initialSet;

  OptionalDatePicker({required this.title, required this.selection, initialSet})
      : this.initialSet = initialSet ?? DateTime.now();

  @override
  _OptionalDatePickerState createState() => _OptionalDatePickerState();
}

class _OptionalDatePickerState extends State<OptionalDatePicker> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [Text(widget.title), Spacer(), ...setBinding()],
      ),
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (widget.selection.get())!,
      firstDate: DateTime.now().subtract(Duration(days: 365 * 100)),
      lastDate: DateTime.now().add(Duration(days: 365 * 5)),
    );
    if (picked != null && picked != widget.selection.get())
      setState(() {
        widget.selection.set(picked);
      });
  }

  List<Widget> setBinding() {
    var unwrappedBinding = widget.selection.get();
    if (unwrappedBinding != null) {
      return [
        Expanded(
          flex: 0,
          child: TextButton(
            onPressed: () => _selectDate(context),
            child: Text(unwrappedBinding
                .toString()
                .split(' ')
                .first), //TODO: format this with Jiffy
          ),
        ),
        IconButton(
          onPressed: () => setState(() => widget.selection.set(null)),
          icon: Icon(MemriIcon.getByName("xmark.circle")),
          padding: EdgeInsets.all(5),
        )
      ];
    } else {
      return [
        TextButton(
            onPressed: () =>
                setState(() => widget.selection.set(widget.initialSet)),
            child: Text("Set"))
      ];
    }
  }
}
