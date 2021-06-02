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
  T? _value;

  TextEditingController get controller => TextEditingController(text: _value?.toString());

  late Future<T> _futureValue;

  @override
  initState() {
    super.initState();
    if (widget.futureBinding != null) {
      _futureValue = widget.futureBinding!.get();
    }
  }

  @override
  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.futureBinding != null) {
      _futureValue = widget.futureBinding!.get();
    }
  }

  set value(newValue) {
    _value = newValue;
    if (widget.futureBinding != null) {
      widget.futureBinding!.set(newValue);
    } else {
      widget.binding!.set(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.futureBinding != null) {
      return FutureBuilder<T>(
        initialData: _value,
        future: _futureValue,
        builder: (context, snapshot) {
            _value = snapshot.data;

            return body(context);
        });
    } else {
      _value = widget.binding!.get();
      return body(context);
    }
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
      readOnly: !widget.isEditing,
      style: widget.style,
      decoration: InputDecoration(border: InputBorder.none),
      controller: controller,
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
      readOnly: !widget.isEditing,
      style: widget.style,
      decoration: InputDecoration(border: InputBorder.none),
      controller: controller,
      onChanged: (String newValue) async {
        value = double.tryParse(newValue);
      },
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
    );
  }
}
