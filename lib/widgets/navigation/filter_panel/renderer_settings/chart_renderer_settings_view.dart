import 'package:flutter/material.dart';

import '../../../../cvu/controllers/view_context_controller.dart';
import '../../../../cvu/models/cvu_value.dart';
import '../../../../cvu/models/cvu_value_constant.dart';
import '../../../../cvu/utilities/binding.dart';

class ChartRendererSettingsView extends StatelessWidget {
  final ViewContextController viewContext;

  ChartRendererSettingsView({required this.viewContext});

  Binding<Color> get colorBinding {
    return Binding<Color>(() {
      return viewContext.rendererDefinitionPropertyResolver.color("color") ?? Colors.blue;
    }, (newValue) async {
      var hex = newValue.value.toString();
      viewContext.setRendererProperty("chart", "color", CVUValueConstant(CVUConstantColorHex(hex)));
    });
  }

  Binding<String?> get titleBinding {
    return Binding<String?>(() {
      return viewContext.rendererDefinitionPropertyResolver.string("title");
    }, (newValue) {
      viewContext.setRendererProperty("chart", "title",
          CVUValueConstant(newValue != null ? CVUConstantString(newValue) : CVUConstantNil()));
    });
  }

  Binding<String?> get subtitleBinding {
    return Binding<String?>(() {
      return viewContext.rendererDefinitionPropertyResolver.string("subtitle");
    }, (newValue) {
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
