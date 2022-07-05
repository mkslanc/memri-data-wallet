import 'package:flutter/foundation.dart';
import 'package:memri/core/services/mixpanel_analytics_service.dart';
import 'package:memri/core/services/network_service.dart';
import 'package:memri/utilities/helpers/app_helper.dart';

class WorkspaceProvider with ChangeNotifier {
  final NetworkService _networkService;
  final MixpanelAnalyticsService _mixpanelAnalyticsService;

  WorkspaceProvider(this._networkService, this._mixpanelAnalyticsService);

  void handleGuideButton() {
    _networkService.openLink(app.settings.guideUrl);
    _mixpanelAnalyticsService.logGuideButton();
  }

  void handleDiscordButton() {
    _networkService.openLink(app.settings.discordUrl);
    _mixpanelAnalyticsService.logDiscordButton();
  }
}
