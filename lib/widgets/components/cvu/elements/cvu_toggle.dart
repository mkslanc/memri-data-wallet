import 'package:flutter/material.dart';
import 'package:memri/utils/binding.dart';

import '../cvu_ui_node_resolver.dart';

/// A CVU element for displaying a toggle
/// - Set the `value` property to an expression representing the boolean item property to be toggled
class CVUToggle extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUToggle({required this.nodeResolver});

  @override
  _CVUToggleState createState() => _CVUToggleState();
}

class _CVUToggleState extends State<CVUToggle> {
  late FutureBinding<bool>? binding;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    await widget.nodeResolver.propertyResolver.binding<bool>("value", false).then((result) {
      binding = result;
      binding?.get().then((newValue) => updateValue(newValue));
    });
  }

  bool _value = false;

  get value => _value;

  set value(newValue) {
    if (binding != null) {
      binding!.set(newValue).whenComplete(() => updateValue(newValue));
    } else {
      updateValue(newValue);
    }
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
        onChanged: (bool newValue) async {
          value = newValue;
        });
  }
}
