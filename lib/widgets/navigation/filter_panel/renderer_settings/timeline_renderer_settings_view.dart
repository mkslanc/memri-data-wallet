import 'package:flutter/material.dart';

import '../../../../cvu/controllers/view_context_controller.dart';
import '../../../../cvu/models/cvu_value.dart';
import '../../../../cvu/models/cvu_value_constant.dart';
import '../../../../cvu/utilities/binding.dart';
import '../../../../cvu/widgets/renderers/timeline_renderer_model.dart';
import '../../../components/picker.dart';

class TimelineRendererSettingsView extends StatelessWidget {
  final ViewContextController viewContext;

  TimelineRendererSettingsView({required this.viewContext});

  Binding<TimelineDetailLevel> get detailLevelBinding =>
      Binding<TimelineDetailLevel>(() {
        return TimelineDetailLevelExtension.init(
                viewContext.rendererDefinitionPropertyResolver.string("detailLevel")) ??
            TimelineDetailLevel.day;
      }, (newValue) {
        viewContext.setRendererProperty(
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
