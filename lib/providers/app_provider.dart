import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/core/controllers/authentication.dart';
import 'package:memri/core/services/pod_service.dart';
import 'package:memri/localization/generated/l10n.dart';
import 'package:memri/providers/settings_provider.dart';
import 'package:memri/widgets/blur_dialog.dart';
import 'package:memri/widgets/loading_indicator.dart';

import '../core/services/database/schema.dart';
import '../cvu/controllers/cvu_controller.dart';
import 'ui_state_provider.dart';

enum AppState { init, loading, success, error, unauthenticated, authenticating }

class AppProvider with ChangeNotifier {
  final PodService _podService;

  AppProvider(this._podService);

  AppState state = AppState.init;
  String? podVersion;
  String? appVersion;
  String errorMessage = '';
  String welcomeMessage = S.current.check_server_status;

  bool _isLoadingOpened = false;
  bool _checkAuth = true;

  PodService get podService => _podService;

  Future<void> initialize() async {
    try {
      state = AppState.init;

      if (_checkAuth) {
        if (_podService.podConfig.ownerKey.isEmpty) {
          _handleUnauthenticated();
        } else {
          _handleSuccess();
        }
      } else {
        _handleSuccess();
      }
    } on Exception catch (e) {
      _handleError(e);
    }
  }

  void initAccountsAuthState() {
    _checkAuth = false;
    state = AppState.authenticating;
  }

  void showLoadingDialog(BuildContext context, {String message = ''}) {
    _isLoadingOpened = true;
    showDialog(
      context: context,
      builder: (context) =>
          BlurDialog(child: LoadingIndicator(message: message)),
      barrierDismissible: false,
    );
  }

  initCVUDefinitions() async {
    var cvuController = GetIt.I<CVUController>();
    await GetIt.I<Schema>().loadFromPod();
    await cvuController.init();
  }


  void closeLoadingDialog(BuildContext context) {
    if (_isLoadingOpened) {
      RouteNavigator.navigateBack(context);
      _isLoadingOpened = false;
    }
  }

  Future<void> _updateWelcomeMessage(String message) async {
    await Future.delayed(Duration(milliseconds: 350));
    welcomeMessage = message;
    notifyListeners();
  }

  void _handleLoading() {
    state = AppState.loading;
    errorMessage = '';
    notifyListeners();
  }

  void _handleUnauthenticated() {
    state = AppState.unauthenticated;
    errorMessage = '';
    notifyListeners();
  }

  void _handleSuccess() {
    state = AppState.success;
    errorMessage = '';
    notifyListeners();
  }

  void _handleError(e) {
    state = AppState.error;
    errorMessage = e.toString();
    notifyListeners();
  }

  resetApp() async {
    await GetIt.I<SettingsProvider>().clear();
    await Authentication.instance.removeAll();
    GetIt.I<UIStateProvider>().closeDrawer();
  }
}
