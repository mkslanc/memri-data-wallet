import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/core/services/pod_service.dart';
import 'package:memri/localization/generated/l10n.dart';
import 'package:memri/providers/app_provider.dart';
import 'package:memri/utilities/helpers/app_helper.dart';

enum AuthState {
  authentication,
  authenticating,
  authenticated,
  savedKeys,
  error,
}

enum DeveloperAuthState { devSignIn, devSignUp }

class AuthProvider with ChangeNotifier {
  final AppProvider _appProvider;
  final PodService _podService;
  // final MixpanelAnalyticsService _mixpanelAnalyticsService;

  AuthProvider(
    this._appProvider,
    this._podService,
    // this._mixpanelAnalyticsService,
  );

  AuthState state = AuthState.authentication;
  DeveloperAuthState devState = DeveloperAuthState.devSignUp;
  String errorMessage = '';
  bool _developerMode = false;

  String get ownerKey => _podService.podConfig.ownerKey;

  String get databaseKey => _podService.podConfig.databaseKey;

  bool get developerMode => _developerMode;

  Future<void> _authenticate(BuildContext context, String podUrl,
      String ownerKey, String dbKey) async {
    try {
      await _podService.authenticate(
          podAddress: podUrl, ownerKey: ownerKey, dbKey: dbKey);
      // TODO move this once not required on signup
      await _podService.createSchema();

      //TODO
      await _podService.loadDefaultData();
      await _podService.loadDemoFiles();
      _handleAuthenticated(context);

      RouteNavigator.navigateTo(
          context: context, route: Routes.saveKeys, clearStack: true);
    } on Exception catch (_) {
      _appProvider.closeLoadingDialog(context);

      if (devState == DeveloperAuthState.devSignUp) {
        _handleError(S.current.account_login_invalid_pod_url_error);
      } else {
        /// TODO should handle different error types
        _handleError(S.current.account_login_general_error);
      }
    }
  }

  Future<void> login({
    required BuildContext context,
    required String ownerKey,
    required String dbKey,
    String? podAddress,
  }) async {
    if (ownerKey.isEmpty) {
      _handleError(S.current.account_login_empty_owner_key_error);
      return;
    } else if (dbKey.isEmpty) {
      _handleError(S.current.account_login_empty_database_key_error);
      return;
    } else if (podAddress != null && podAddress.length < 3) {
      _handleError(S.current.account_login_empty_pod_url_error);
      return;
    }
    _handleAuthenticating(context);
    var podUrl = podAddress ?? app.settings.defaultPodUrl;

    // _mixpanelAnalyticsService.logSignIn(ownerKey);
    await _authenticate(context, podUrl, ownerKey, dbKey);
  }

  Future<void> signUp(BuildContext context, {String? podAddress}) async {
    if (podAddress != null && podAddress.length < 3) {
      _handleError(S.current.account_login_empty_pod_url_error);
      return;
    }
    _handleAuthenticating(context);
    var podUrl = podAddress ?? app.settings.defaultPodUrl;
    String ownerKey = _podService.generateCryptoStrongKey();
    String dbKey = _podService.generateCryptoStrongKey();

    // _mixpanelAnalyticsService.logSignUp(ownerKey);
    await _authenticate(context, podUrl, ownerKey, dbKey);
  }

  void openLoginScreen(BuildContext context, {bool developerMode = false}) {
    this._developerMode = developerMode;
    RouteNavigator.navigateTo(
        context: context,
        route: developerMode ? Routes.loginDev : Routes.login);
  }

  void copyKeysToClipboard() {
    Clipboard.setData(ClipboardData(
        text:
            "${S.current.login_key}: ${ownerKey}\n${S.current.password_key}: ${databaseKey}"));
    _handleSavedKeys();
  }

  void finishAuthentication(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        RouteNavigator.navigateTo(
            context: context, route: Routes.cvu, clearStack: true));
  }

  void _handleAuthenticating(BuildContext context) {
    state = AuthState.authenticating;
    errorMessage = '';
    notifyListeners();
    _appProvider.showLoadingDialog(context,
        message:
            S.current.authenticating + '\n' + S.current.authenticating_message);
  }

  void _handleAuthenticated(BuildContext context) {
    state = AuthState.authenticated;
    errorMessage = '';
    notifyListeners();
    _appProvider.closeLoadingDialog(context);
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

  void updateDevStateToSignIn() {
    devState = DeveloperAuthState.devSignIn;
    state = AuthState.authenticated;
    errorMessage = '';
    notifyListeners();
  }

  void updateDevStateToSignUp() {
    devState = DeveloperAuthState.devSignUp;
    state = AuthState.authenticated;
    errorMessage = '';
    notifyListeners();
  }
}
