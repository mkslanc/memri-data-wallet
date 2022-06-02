import 'package:memri/constants/app_settings.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelAnalyticsService {
  static late Mixpanel mixpanel;

  Future<void> init() async {
    mixpanel = await Mixpanel.init(
      AppSettings.mixPanelToken,
      optOutTrackingDefault: false,
    );
  }

  void logSignUp(String userId) {
    mixpanel.identify(userId);
    mixpanel.track(_AnalyticsEvents.signUp,
        properties: {_AnalyticsProperties.developersMode: AppController.shared.isDevelopersMode});
  }

  void logSignUpTime() => mixpanel.timeEvent(_AnalyticsEvents.signUp);

  void logSignIn(String userId) {
    mixpanel.timeEvent(_AnalyticsEvents.signIn);
    mixpanel.identify(userId);
    mixpanel.track(_AnalyticsEvents.signIn,
        properties: {_AnalyticsProperties.developersMode: AppController.shared.isDevelopersMode});
  }

  void logNavigationButton(String buttonText) {
    mixpanel.timeEvent(_AnalyticsEvents.navigationButton);
    mixpanel.track(_AnalyticsEvents.navigationButton,
        properties: {_AnalyticsProperties.buttonLabel: buttonText});
  }

  void logBreadCrumbButton(String buttonText) {
    mixpanel.timeEvent(_AnalyticsEvents.breadCrumbButton);
    mixpanel.track(_AnalyticsEvents.breadCrumbButton,
        properties: {_AnalyticsProperties.buttonLabel: buttonText});
  }

  void logCvuButton(String buttonText) {
    mixpanel.timeEvent(_AnalyticsEvents.cvuButton);
    mixpanel.track(_AnalyticsEvents.cvuButton,
        properties: {_AnalyticsProperties.buttonLabel: buttonText});
  }

  void logDiscordButton() {
    mixpanel.timeEvent(_AnalyticsEvents.discord);
    mixpanel.track(_AnalyticsEvents.discord);
  }

  void logGitlabButton() {
    mixpanel.timeEvent(_AnalyticsEvents.gitlab);
    mixpanel.track(_AnalyticsEvents.gitlab);
  }

  void logImporterSelect(String importerName) {
    mixpanel.timeEvent(_AnalyticsEvents.importerSelect);
    mixpanel.track(_AnalyticsEvents.importerSelect,
        properties: {_AnalyticsProperties.importerName: importerName});
  }

  void logImporterConnect(String importerName) {
    mixpanel.timeEvent(_AnalyticsEvents.importerConnect);
    mixpanel.track(_AnalyticsEvents.importerConnect,
        properties: {_AnalyticsProperties.importerName: importerName});
  }
}

class _AnalyticsEvents {
  _AnalyticsEvents._();

  static const signUp = 'sign_up';
  static const signIn = 'sign_in';

  static const navigationButton = 'navigation_button';
  static const breadCrumbButton = 'bread_crumb_button';
  static const cvuButton = 'cvu_button';

  static const discord = 'discord';
  static const gitlab = 'gitlab';

  static const importerSelect = 'importer_select';
  static const importerConnect = 'importer_connect';
}

class _AnalyticsProperties {
  _AnalyticsProperties._();

  static const buttonLabel = 'button_label';
  static const developersMode = 'developers_mode';
  static const importerName = 'importer_name';
}
