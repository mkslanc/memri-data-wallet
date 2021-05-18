import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';

import '../ViewContextController.dart';

class ChartRendererSettingsView extends StatelessWidget {
  final ViewContextController viewContext;

  ChartRendererSettingsView({required this.viewContext});

  FutureBinding<Color> get colorBinding {
    return FutureBinding<Color>(() async {
      return await viewContext.rendererDefinitionPropertyResolver.color("color") ?? Colors.blue;
    }, (newValue) async {
      var hex = newValue.value.toString();
      viewContext.setRendererProperty("chart", "color", CVUValueConstant(CVUConstantColorHex(hex)));
    });
  }

  FutureBinding<String?> get titleBinding {
    return FutureBinding<String?>(() async {
      return await viewContext.rendererDefinitionPropertyResolver.string("title");
    }, (newValue) async {
      viewContext.setRendererProperty("chart", "title",
          CVUValueConstant(newValue != null ? CVUConstantString(newValue) : CVUConstantNil()));
    });
  }

  FutureBinding<String?> get subtitleBinding {
    return FutureBinding<String?>(() async {
      return await viewContext.rendererDefinitionPropertyResolver.string("subtitle");
    }, (newValue) async {
      viewContext.setRendererProperty("chart", "subtitle",
          CVUValueConstant(newValue != null ? CVUConstantString(newValue) : CVUConstantNil()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("TODO ColorPicker "),
        Row(
          children: [Text("TODO Title:")],
        ),
        Row(
          children: [Text("TODO Subtitle:")],
        )
      ],
    );
  }
}
