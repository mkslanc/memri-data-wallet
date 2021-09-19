import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

class MemriDatePicker extends StatefulWidget {
  final ValueChanged<DateTime>? onPressed;
  final DateTime? initialSet;
  final String formatter;
  final TextStyle? style;
  final bool isEditing;

  MemriDatePicker(
      {required this.onPressed,
      required this.initialSet,
      this.formatter = "yyyy/MM/dd",
      this.style,
      this.isEditing = true});

  @override
  _MemriDatePickerState createState() => _MemriDatePickerState(initialSet);
}

class _MemriDatePickerState extends State<MemriDatePicker> {
  DateTime? initialSet;

  _MemriDatePickerState(this.initialSet);

  @override
  Widget build(BuildContext context) {
    var dateFormatter = DateFormat(widget.formatter, "en_US");
    if (!widget.isEditing && initialSet == null) return Empty();
    return Row(
      children: [
        Flexible(
          child: InkWell(
            onTap: widget.isEditing ? () => _selectDate(context) : null,
            child: Text(
              initialSet != null ? dateFormatter.format(initialSet!) : "Set",
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
      initialDate: initialSet ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365 * 100)),
      lastDate: DateTime.now().add(Duration(days: 365 * 5)),
    );
    if (picked != null && picked != initialSet && widget.onPressed != null)
      setState(() {
        initialSet = picked;
        widget.onPressed!(picked);
      });
  }
}
