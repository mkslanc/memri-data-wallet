import 'package:flutter/material.dart';

import '../../../../../widgets/components/picker.dart';
import '../../../../controllers/view_context_controller.dart';
import '../../../../models/cvu_value.dart';
import '../../../../models/cvu_value_constant.dart';
import '../../../../utilities/binding.dart';


class GridRendererSettingsView extends StatefulWidget {
  final ViewContextController viewContext;

  GridRendererSettingsView({required this.viewContext});

  @override
  _GridRendererSettingsViewState createState() => _GridRendererSettingsViewState();
}

class _GridRendererSettingsViewState extends State<GridRendererSettingsView> {
  late final Binding<String> layoutBinding;
  late final Binding<String> scrollDirectionBinding;
  String? _layout;

  String get layout => _layout ?? "";
  set layout(String newValue) => setState(() => _layout = newValue);

  @override
  void initState() {
    super.initState();
    layoutBinding = Binding<String>(() {
      return widget.viewContext.rendererDefinitionPropertyResolver.string("layout") ?? "grid";
    }, (newValue) {
      widget.viewContext
          .setRendererProperty("grid", "layout", CVUValueConstant(CVUConstantArgument(newValue)));
      layout = newValue;
    });

    scrollDirectionBinding = Binding<String>(() {
      return widget.viewContext.rendererDefinitionPropertyResolver
              .string("scrollDirection") ??
          "vertical";
    }, (newValue) {
      widget.viewContext.setRendererProperty(
          "grid", "scrollDirection", CVUValueConstant(CVUConstantArgument(newValue)));
    });

    layout = layoutBinding.get();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Picker<String>("Layout", selection: layoutBinding, group: {
          "grid": "Grid",
          "photoGrid": "Photo grid",
          "waterfall": "Waterfall",
        }),
        if (layout == "grid")
          Picker<String>("Scroll direction", selection: scrollDirectionBinding, group: {
            "vertical": "Vertical",
            "horizontal": "Horizontal",
          })
      ],
    );
  }
}
