import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';

class MemriTextField<T> extends StatefulWidget {
  final Binding<T>? binding;
  final FutureBinding<T>? futureBinding;

  MemriTextField.sync({required this.binding}) : futureBinding = null;

  MemriTextField.async({required this.futureBinding}) : binding = null;

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

  String _value = "";

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
    return TextFormField(
      style: TextStyle(
        color: Color(0xFF223322),
        fontWeight: FontWeight.normal,
        fontSize: 18,
      ),
      decoration: InputDecoration(border: InputBorder.none),
      controller: TextEditingController()..text = value, //TODO: need to change
      onChanged: (String newValue) async {
        value = newValue;
      },
    );
  }
}
