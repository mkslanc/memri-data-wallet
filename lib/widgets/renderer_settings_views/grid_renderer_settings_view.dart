import 'package:flutter/material.dart';
import 'package:memri/core/controllers/view_context_controller.dart';
import 'package:memri/core/models/cvu/cvu_value.dart';
import 'package:memri/core/models/cvu/cvu_value_constant.dart';
import 'package:memri/utilities/binding.dart';
import 'package:memri/widgets/components/picker.dart';

class GridRendererSettingsView extends StatefulWidget {
  final ViewContextController viewContext;

  GridRendererSettingsView({required this.viewContext});

  @override
  _GridRendererSettingsViewState createState() =>
      _GridRendererSettingsViewState();
}

class _GridRendererSettingsViewState extends State<GridRendererSettingsView> {
  late final FutureBinding<String> layoutBinding;
  late final FutureBinding<String> scrollDirectionBinding;
  String? _layout;

  String get layout => _layout ?? "";

  set layout(String newValue) => setState(() => _layout = newValue);

  @override
  void initState() {
    super.initState();
    layoutBinding = FutureBinding<String>(() async {
      return await widget.viewContext.rendererDefinitionPropertyResolver
              .string("layout") ??
          "grid";
    }, (newValue) async {
      await widget.viewContext.setRendererProperty(
          "grid", "layout", CVUValueConstant(CVUConstantArgument(newValue)));
      layout = newValue;
    });

    scrollDirectionBinding = FutureBinding<String>(() async {
      return await widget.viewContext.rendererDefinitionPropertyResolver
              .string("scrollDirection") ??
          "vertical";
    }, (newValue) async {
      await widget.viewContext.setRendererProperty("grid", "scrollDirection",
          CVUValueConstant(CVUConstantArgument(newValue)));
    });

    layoutBinding.get().then((value) {
      layout = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Picker<String>("layout", selection: layoutBinding, group: {
          "grid": "Grid",
          "photoGrid": "Photo grid",
          "waterfall": "Waterfall",
        }),
        if (layout == "grid")
          Picker<String>("Scroll direction",
              selection: scrollDirectionBinding,
              group: {
                "vertical": "Vertical",
                "horizontal": "Horizontal",
              })
      ],
    );
  }
}
