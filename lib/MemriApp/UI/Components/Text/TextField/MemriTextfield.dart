import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';

class MemriTextField<T> extends StatefulWidget {
  final Binding<T>? binding;
  final FutureBinding<T>? futureBinding;
  final TextStyle? style;
  final bool isEditing;

  MemriTextField.sync({required this.binding, this.style, this.isEditing = true})
      : futureBinding = null;

  MemriTextField.async({required this.futureBinding, this.style, this.isEditing = true})
      : binding = null;

  @override
  _MemriTextFieldState<T> createState() => _MemriTextFieldState<T>();
}

class _MemriTextFieldState<T> extends State<MemriTextField<T>> {
  @override
  void initState() {
    super.initState();
    if (widget.futureBinding != null) init();
  }

  init() async {
    await widget.futureBinding?.get().then((newValue) => updateValue(newValue));
  }

  T? _value;

  get value => _value;

  set value(newValue) {
    if (widget.futureBinding != null) {
      widget.futureBinding!.set(newValue).whenComplete(() => updateValue(newValue));
    } else {
      widget.binding!.set(newValue);
    }
  }

  void updateValue(newValue) {
    setState(() {
      _value = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    //TODO: make it more flexible
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
      readOnly: !widget.isEditing,
      style: widget.style,
      decoration: InputDecoration(border: InputBorder.none),
      controller: TextEditingController()..text = value ?? "", //TODO: need to change
      onChanged: (String newValue) async {
        value = newValue;
      },
    );
  }

  intTextForm() {
    return TextFormField(
      readOnly: !widget.isEditing,
      style: widget.style,
      decoration: InputDecoration(border: InputBorder.none),
      controller: TextEditingController()..text = value.toString(), //TODO: need to change
      onChanged: (String newValue) async {
        value = int.tryParse(newValue);
      },
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  doubleTextForm() {
    return TextFormField(
      readOnly: !widget.isEditing,
      style: widget.style,
      decoration: InputDecoration(border: InputBorder.none),
      controller: TextEditingController()..text = value.toString(), //TODO: need to change
      onChanged: (String newValue) async {
        value = double.tryParse(newValue);
      },
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
    );
  }
}
