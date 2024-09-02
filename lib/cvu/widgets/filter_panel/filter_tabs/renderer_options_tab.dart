import 'package:flutter/material.dart';

import 'package:memri/cvu/widgets/filter_panel/filter_tabs/renderer_settings/chart_renderer_settings_view.dart';
import 'package:memri/cvu/widgets/filter_panel/filter_tabs/renderer_settings/grid_renderer_settings_view.dart';
import 'package:memri/cvu/widgets/filter_panel/filter_tabs/renderer_settings/timeline_renderer_settings_view.dart';

import '../../../../utilities/helpers/app_helper.dart';
import '../../../controllers/view_context_controller.dart';

class RendererOptionsTab extends StatelessWidget {
  final ViewContextController viewContext;

  const RendererOptionsTab(this.viewContext);

  @override
  Widget build(BuildContext context) {
    switch (viewContext.config.rendererName.toLowerCase()) {
      case "timeline":
        return TimelineRendererSettingsView(viewContext: viewContext);
      case "chart":
        return ChartRendererSettingsView(viewContext: viewContext);
      case "grid":
        return GridRendererSettingsView(viewContext: viewContext);
      default:
    }
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("No configurable settings for this renderer.", style: TextStyle(fontSize: 14, color: app.colors.brandGreyText)),
        ],
      ),
    );
  }
}