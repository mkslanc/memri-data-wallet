import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:memri/cvu/utilities/binding.dart';
import 'package:provider/provider.dart';

import '../../../../providers/ui_state_provider.dart';
import '../../../../widgets/components/toggle.dart';
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
  late Binding<bool>? binding;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    binding = widget.nodeResolver.propertyResolver.binding("value", false) as Binding<bool>;
  }

  @override
  Widget build(BuildContext context) {
    var isEditing = GetIt.I<UIStateProvider>().currentViewContext!.isInEditMode;
    return Toggle(binding: binding, isEditing: isEditing);
  }
}
