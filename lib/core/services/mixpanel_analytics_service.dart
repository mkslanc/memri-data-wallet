import 'package:memri/constants/app_settings.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelAnalyticsService {
  late Mixpanel mixpanel;

  Future<void> init() async {
    this.mixpanel = await Mixpanel.init(
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

  void logCvuButton(String buttonText) {
    mixpanel.track(_AnalyticsEvents.cvuButton,
        properties: {_AnalyticsProperties.buttonLabel: buttonText});
  }
}

class _AnalyticsEvents {
  _AnalyticsEvents._();

  static const signUp = 'sign_up';
  static const signIn = 'sign_in';
  static const cvuButton = 'cvu_button';
}

class _AnalyticsProperties {
  _AnalyticsProperties._();

  static const buttonLabel = 'button_label';
  static const developersMode = 'developers_mode';
}
