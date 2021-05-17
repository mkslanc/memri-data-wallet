import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MemriDatePicker extends StatefulWidget {
  final ValueChanged<DateTime> onPressed;
  final DateTime initialSet;
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
  _MemriDatePickerState createState() => _MemriDatePickerState();
}

class _MemriDatePickerState extends State<MemriDatePicker> {
  @override
  Widget build(BuildContext context) {
    var dateFormatter = DateFormat(widget.formatter, "en_US");
    return Row(
      children: [
        Flexible(
          child: TextButton(
            onPressed: widget.isEditing ? () => _selectDate(context) : null,
            child: Text(
              dateFormatter.format(widget.initialSet),
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
      initialDate: widget.initialSet,
      firstDate: DateTime.now().subtract(Duration(days: 365 * 100)),
      lastDate: DateTime.now().add(Duration(days: 365 * 5)),
    );
    if (picked != null && picked != widget.initialSet)
      setState(() {
        widget.onPressed(picked);
      });
  }
}
