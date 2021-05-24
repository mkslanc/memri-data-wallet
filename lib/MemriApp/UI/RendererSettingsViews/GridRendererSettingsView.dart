import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';
import 'package:memri/MemriApp/UI/Components/Picker.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import '../ViewContextController.dart';

class GridRendererSettingsView extends StatefulWidget {
  final ViewContextController viewContext;

  GridRendererSettingsView({required this.viewContext});

  @override
  _GridRendererSettingsViewState createState() => _GridRendererSettingsViewState();
}

class _GridRendererSettingsViewState extends State<GridRendererSettingsView> {
  late final FutureBinding<String> layoutBinding;
  late final FutureBinding<String> scrollDirectionBinding;

  @override
  void initState() {
    super.initState();
    layoutBinding = FutureBinding<String>(() async {
      return await widget.viewContext.rendererDefinitionPropertyResolver.string("layout") ?? "grid";
    }, (newValue) async {
      await widget.viewContext
          .setRendererProperty("grid", "layout", CVUValueConstant(CVUConstantArgument(newValue)));
      setState(() {});
    });

    scrollDirectionBinding = FutureBinding<String>(() async {
      return await widget.viewContext.rendererDefinitionPropertyResolver
              .string("scrollDirection") ??
          "vertical";
    }, (newValue) async {
      await widget.viewContext.setRendererProperty(
          "grid", "scrollDirection", CVUValueConstant(CVUConstantArgument(newValue)));
    });
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
        FutureBuilder<String>(
          future: layoutBinding.get(),
          builder: (context, snapshot) => snapshot.hasData && snapshot.data == "grid"
              ? Picker<String>("Scroll direction", selection: scrollDirectionBinding, group: {
                  "vertical": "Vertical",
                  "horizontal": "Horizontal",
                })
              : Empty(),
        )
      ],
    );
  }
}
