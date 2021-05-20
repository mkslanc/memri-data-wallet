import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';

class MemriTextField<T> extends StatelessWidget {
  final Binding<T>? binding;
  final FutureBinding<T>? futureBinding;
  final TextStyle? style;
  final bool isEditing;

  MemriTextField.sync({required this.binding, this.style, this.isEditing = true})
      : futureBinding = null;

  MemriTextField.async({required this.futureBinding, this.style, this.isEditing = true})
      : binding = null;

  late final T? _value;
  TextEditingController get controller => TextEditingController(text: _value?.toString());

  set value(newValue) {
    if (futureBinding != null) {
      futureBinding!.set(newValue);
    } else {
      binding!.set(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (futureBinding != null) {
      return FutureBuilder<T>(
          future: futureBinding!.get(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                _value = snapshot.data;
                return body(context);
              default:
                return SizedBox.shrink();
            }
          });
    } else {
      _value = binding!.get();
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
      readOnly: !isEditing,
      style: style,
      decoration: InputDecoration(border: InputBorder.none),
      controller: controller,
      onChanged: (String newValue) async {
        value = newValue;
      },
    );
  }

  intTextForm() {
    return TextFormField(
      readOnly: !isEditing,
      style: style,
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
      readOnly: !isEditing,
      style: style,
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
