import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../cvu/utilities/binding.dart';

class MemriTextField<T> extends StatefulWidget {
  final Binding<T>? binding;
  final TextStyle? style;
  final bool isEditing;
  final String? hint;
  final bool secureMode;

  MemriTextField.sync(
      {required this.binding,
      this.style,
      this.hint,
      this.secureMode = false,
      this.isEditing = true});

  @override
  _MemriTextFieldState<T> createState() => _MemriTextFieldState<T>();
}

class _MemriTextFieldState<T> extends State<MemriTextField<T>> {
  T? _value;

  TextEditingController get controller => TextEditingController(text: _value?.toString());

  set value(newValue) {
    _value = newValue;
    widget.binding!.set(newValue);
  }

  @override
  Widget build(BuildContext context) {
    _value = widget.binding?.get();
    return body(context);
  }

  Widget body(BuildContext context) {
    switch (T) {
      case int:
        return intTextForm();
      case double:
        return doubleTextForm();
      case String:
      default:
        return stringTextForm();
    }
  }

  stringTextForm() {
    return TextFormField(
      obscureText: widget.secureMode,
      readOnly: !widget.isEditing,
      style: widget.style,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: widget.hint,
      ),
      controller: controller,
      onChanged: (String newValue) async {
        value = newValue;
      },
    );
  }

  intTextForm() {
    return TextFormField(
      obscureText: widget.secureMode,
      readOnly: !widget.isEditing,
      style: widget.style,
      decoration: InputDecoration(border: InputBorder.none, hintText: widget.hint),
      controller: controller,
      onChanged: (String newValue) async {
        value = int.tryParse(newValue);
      },
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  doubleTextForm() {
    return TextFormField(
      obscureText: widget.secureMode,
      readOnly: !widget.isEditing,
      style: widget.style,
      decoration: InputDecoration(border: InputBorder.none, hintText: widget.hint),
      controller: controller,
      onChanged: (String newValue) async {
        value = double.tryParse(newValue);
      },
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
    );
  }
}
