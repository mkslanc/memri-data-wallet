import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/core/services/mixpanel_analytics_service.dart';
import 'package:memri/core/services/pod_service.dart';
import 'package:memri/utilities/helpers/app_helper.dart';

enum AuthState {
  authentication,
  authenticating,
  authenticated,
  savedKeys,
  error,
}

class PodProvider with ChangeNotifier {
  final PodService _podService;
  final MixpanelAnalyticsService _mixpanelAnalyticsService;

  PodProvider(this._podService, this._mixpanelAnalyticsService);

  AuthState state = AuthState.authentication;
  String errorMessage = '';
  bool _developerMode = false;

  String get ownerKey => _podService.podConfig.ownerKey;

  String get databaseKey => _podService.podConfig.databaseKey;

  bool get developerMode => _developerMode;

  Future<void> _authenticate(
    BuildContext context,
    String podUrl,
    String ownerKey,
    String dbKey,
  ) async {
    try {
      await _podService.authenticate(
          podAddress: podUrl, ownerKey: ownerKey, dbKey: dbKey);
      RouteNavigator.navigateTo(
          context: context, route: Routes.saveKeys, clearStack: true);

      _handleAuthenticated();
    } on Exception catch (e) {
      _handleError(e);
    }
  }

  Future<void> login({
    required BuildContext context,
    required String ownerKey,
    required String dbKey,
    String? podAddress,
  }) async {
    _handleAuthenticating();
    var podUrl = podAddress ?? app.settings.defaultPodUrl;

    _mixpanelAnalyticsService.logSignIn(ownerKey);
    await _authenticate(context, podUrl, ownerKey, dbKey);
  }

  Future<void> signUp(BuildContext context, {String? podAddress}) async {
    _handleAuthenticating();
    var podUrl = podAddress ?? app.settings.defaultPodUrl;
    String ownerKey = _podService.generateCryptoStrongKey();
    String dbKey = _podService.generateCryptoStrongKey();

    _mixpanelAnalyticsService.logSignUp(ownerKey);
    await _authenticate(context, podUrl, ownerKey, dbKey);
  }

  void openLoginScreen(BuildContext context, {bool developerMode = false}) {
    this._developerMode = developerMode;
    WidgetsBinding.instance!.addPostFrameCallback((_) =>
        RouteNavigator.navigateTo(
            context: context,
            route: developerMode ? Routes.loginDev : Routes.login));
  }

  void copyKeysToClipboard() {
    Clipboard.setData(ClipboardData(
        text: "Owner Key: ${ownerKey}\nDatabase Key: ${databaseKey}"));
    _handleSavedKeys();
  }

  void finishAuthentication(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) =>
        RouteNavigator.navigateTo(
            context: context, route: Routes.workspace, clearStack: true));
  }

  void _handleAuthenticating() {
    state = AuthState.authenticating;
    errorMessage = '';
    notifyListeners();
  }

  void _handleAuthenticated() {
    state = AuthState.authenticated;
    errorMessage = '';
    notifyListeners();
  }

  void _handleSavedKeys() {
    state = AuthState.savedKeys;
    errorMessage = '';
    notifyListeners();
  }

  void _handleError(e) {
    state = AuthState.error;
    errorMessage = e.toString();
    notifyListeners();
  }
}
