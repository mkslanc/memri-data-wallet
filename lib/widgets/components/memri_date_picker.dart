import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memri/widgets/empty.dart';

import '../../cvu/utilities/binding.dart';

class MemriDatePicker extends StatefulWidget {
  final String formatter;
  final TextStyle? style;
  final bool isEditing;
  final Binding<DateTime?>? binding;

  MemriDatePicker(
      {this.formatter = "yyyy/MM/dd",
      this.binding,
      this.style,
      this.isEditing = true});

  @override
  _MemriDatePickerState createState() => _MemriDatePickerState();
}

class _MemriDatePickerState extends State<MemriDatePicker> {
  DateTime? _value;
  late final Binding<DateTime?>? binding;

  @override
  void initState() {
    super.initState();
    binding = widget.binding;
    _value = binding?.get();
  }

  set value(newValue) {
    setState(() {
      _value = newValue;
      widget.binding!.set(newValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    var dateFormatter = DateFormat(widget.formatter, "en_US");
    if (!widget.isEditing && _value == null)
      return Empty();
    return Row(
      children: [
        Flexible(
          child: InkWell(
            onTap: widget.isEditing ? () => _selectDate(context) : null,
            child: Text(
              _value != null ? dateFormatter.format(_value!) : "Set",
              style: widget.style,
            ),
          ),
        ),
      ],
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _value ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365 * 100)),
      lastDate: DateTime.now().add(Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _value && binding != null)
      value = picked;
  }
}
