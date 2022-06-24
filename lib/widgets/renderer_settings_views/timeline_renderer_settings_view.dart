import 'package:flutter/material.dart';
import 'package:memri/core/controllers/view_context_controller.dart';
import 'package:memri/core/models/cvu/cvu_value.dart';
import 'package:memri/core/models/cvu/cvu_value_constant.dart';
import 'package:memri/core/models/ui/timeline_renderer_model.dart';
import 'package:memri/utilities/binding.dart';
import 'package:memri/widgets/components/picker.dart';

class TimelineRendererSettingsView extends StatelessWidget {
  final ViewContextController viewContext;

  TimelineRendererSettingsView({required this.viewContext});

  FutureBinding<TimelineDetailLevel> get detailLevelBinding =>
      FutureBinding<TimelineDetailLevel>(() async {
        return TimelineDetailLevelExtension.init(await viewContext
                .rendererDefinitionPropertyResolver
                .string("detailLevel")) ??
            TimelineDetailLevel.day;
      }, (newValue) async {
        await viewContext.setRendererProperty("timeline", "detailLevel",
            CVUValueConstant(CVUConstantArgument(newValue.value)));
      });

  @override
  Widget build(BuildContext context) {
    return Picker<TimelineDetailLevel>("Detail level",
        selection: detailLevelBinding,
        group: {
          TimelineDetailLevel.year: "Year",
          TimelineDetailLevel.month: "Month",
          TimelineDetailLevel.day: "Day",
          TimelineDetailLevel.hour: "Hour",
        });
  }
}
