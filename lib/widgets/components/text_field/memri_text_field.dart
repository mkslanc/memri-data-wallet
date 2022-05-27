import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/utils/binding.dart';

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
  final bool autoFocus;
  final Future Function()? onSubmit;
  final ValueNotifier<bool> isDisabled;

  MemriTextField.sync(
      {required this.binding,
      this.style,
      this.hint,
      this.hintStyle,
      this.secureMode = false,
      this.isEditing = true,
      this.isMultiline = false,
      this.isCollapsed = false,
      this.autoFocus = false,
      this.onSubmit,
      isDisabled})
      : futureBinding = null,
        this.isDisabled = isDisabled ?? ValueNotifier(false);

  MemriTextField.async(
      {required this.futureBinding,
      this.style,
      this.hint,
      this.hintStyle,
      this.secureMode = false,
      this.isEditing = true,
      this.isMultiline = false,
      this.isCollapsed = false,
      this.autoFocus = false,
      this.onSubmit,
      isDisabled})
      : binding = null,
        this.isDisabled = isDisabled ?? ValueNotifier(false);

  @override
  _MemriTextFieldState<T> createState() => _MemriTextFieldState<T>();
}

class _MemriTextFieldState<T> extends State<MemriTextField<T>> {
  T? _value;

  TextEditingController get controller => TextEditingController(text: _value?.toString());

  late Future<T> _futureValue;
  final FocusNode _focusNode = FocusNode();

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

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool pending = false;
  bool usePending = false;

  updateFutureValue() {
    widget.futureBinding!.set(_value!).then((value) async {
      if (usePending) {
        usePending = false;
        await updateFutureValue();
      } else {
        pending = false;
        (AppController.shared.storage["isBlocked"] as ValueNotifier?)?.value = false;
      }
    }).catchError((error) {
      pending = false;
      usePending = false;
      (AppController.shared.storage["isBlocked"] as ValueNotifier?)?.value = false;
    });
  }

  set value(newValue) {
    _value = newValue;
    if (widget.futureBinding != null) {
      if (pending) {
        usePending = true;
        return;
      }
      pending = true;

      AppController.shared.storage["isBlocked"] ??= ValueNotifier(true);
      (AppController.shared.storage["isBlocked"] as ValueNotifier).value = true;
      updateFutureValue();
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
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isDisabled,
      builder: (BuildContext context, disabledValue, Widget? child) => TextFormField(
          focusNode: _focusNode,
          obscureText: widget.secureMode,
          readOnly: !widget.isEditing || disabledValue,
          style: widget.style,
          autofocus: widget.autoFocus,
          decoration: InputDecoration(
              isCollapsed: widget.isCollapsed,
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              border: InputBorder.none,
              hintText: widget.hint,
              hintStyle: widget.hintStyle),
          controller: controller,
          maxLines: widget.isMultiline ? null : 1,
          onChanged: (String newValue) async {
            value = newValue;
          },
          onFieldSubmitted: (lastValue) async {
            if (widget.onSubmit != null) {
              await widget.onSubmit!();
              if (widget.autoFocus)
                Future.delayed(Duration(milliseconds: 500)).then((value) {
                  FocusScope.of(context).requestFocus(_focusNode);
                });
            }
          }),
    );
  }

  intTextForm() {
    return TextFormField(
      obscureText: widget.secureMode,
      readOnly: !widget.isEditing,
      style: widget.style,
      decoration: InputDecoration(
          isCollapsed: widget.isCollapsed,
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
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
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
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
