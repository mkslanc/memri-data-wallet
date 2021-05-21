import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';
import 'package:memri/MemriApp/UI/Components/Picker.dart';
import 'package:memri/MemriApp/UI/Renderers/TimelineRendererModel.dart';

import '../ViewContextController.dart';

class TimelineRendererSettingsView extends StatelessWidget {
  final ViewContextController viewContext;

  TimelineRendererSettingsView({required this.viewContext});

  FutureBinding<TimelineDetailLevel> get detailLevelBinding =>
      FutureBinding<TimelineDetailLevel>(() async {
        return TimelineDetailLevelExtension.init(
                await viewContext.rendererDefinitionPropertyResolver.string("detailLevel")) ??
            TimelineDetailLevel.day;
      }, (newValue) async {
        await viewContext.setRendererProperty(
            "timeline", "detailLevel", CVUValueConstant(CVUConstantArgument(newValue.value)));
      });

  @override
  Widget build(BuildContext context) {
    return Picker<TimelineDetailLevel>("Detail level", selection: detailLevelBinding, group: {
      TimelineDetailLevel.year: "Year",
      TimelineDetailLevel.month: "Month",
      TimelineDetailLevel.day: "Day",
      TimelineDetailLevel.hour: "Hour",
    });
  }
}
