import 'package:flutter/material.dart';
import 'package:memri/cvu/utilities/binding.dart';

class Toggle extends StatefulWidget {
  final Binding<bool>? binding;
  final bool isEditing;

  Toggle({required this.binding, required this.isEditing});

  @override
  _ToggleState createState() => _ToggleState();
}

class _ToggleState extends State<Toggle> {
  init() async {
    updateValue(widget.binding?.get());
  }

  bool _value = false;

  get value {
    return widget.binding?.get() ?? _value;
  }

  set value(newValue) {
    if (widget.binding != null) {
      widget.binding!.set(newValue);
    }
    updateValue(newValue);
  }

  void updateValue(newValue) {
    setState(() {
      _value = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: widget.isEditing
          ? (bool newValue) async {
              value = newValue;
            }
          : null,
    );
  }
}
