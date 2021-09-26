import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';

class MemriTextField<T> extends StatefulWidget {
  final Binding<T>? binding;
  final FutureBinding<T>? futureBinding;
  final TextStyle? style;
  final bool isEditing;
  final String? hint;
  final TextStyle? hintStyle;
  final bool secureMode;
  final bool isMultiline;
  final bool isCollapsed;

  MemriTextField.sync(
      {required this.binding,
      this.style,
      this.hint,
      this.hintStyle,
      this.secureMode = false,
      this.isEditing = true,
      this.isMultiline = false,
      this.isCollapsed = true})
      : futureBinding = null;

  MemriTextField.async(
      {required this.futureBinding,
      this.style,
      this.hint,
      this.hintStyle,
      this.secureMode = false,
      this.isEditing = true,
      this.isMultiline = false,
      this.isCollapsed = true})
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
            if (snapshot.connectionState == ConnectionState.done) {
              _value = snapshot.data;
            }

            return body(context);
          });
    } else {
      _value = widget.binding?.get();
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
      obscureText: widget.secureMode,
      readOnly: !widget.isEditing,
      style: widget.style,
      decoration: InputDecoration(
          isCollapsed: widget.isCollapsed,
          border: InputBorder.none,
          hintText: widget.hint,
          hintStyle: widget.hintStyle),
      controller: controller,
      maxLines: widget.isMultiline ? null : 1,
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
      decoration: InputDecoration(
          isCollapsed: widget.isCollapsed,
          border: InputBorder.none,
          hintText: widget.hint,
          hintStyle: widget.hintStyle),
      controller: controller,
      onChanged: (String newValue) async {
        value = int.tryParse(newValue);
      },
      maxLines: widget.isMultiline ? null : 1,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }

  doubleTextForm() {
    return TextFormField(
      obscureText: widget.secureMode,
      readOnly: !widget.isEditing,
      style: widget.style,
      decoration: InputDecoration(
          isCollapsed: widget.isCollapsed,
          border: InputBorder.none,
          hintText: widget.hint,
          hintStyle: widget.hintStyle),
      controller: controller,
      onChanged: (String newValue) async {
        value = double.tryParse(newValue);
      },
      maxLines: widget.isMultiline ? null : 1,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
    );
  }
}
