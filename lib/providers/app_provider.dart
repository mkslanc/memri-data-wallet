import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/core/services/pod_service.dart';
import 'package:memri/cvu/controllers/view_context_controller.dart';
import 'package:memri/localization/generated/l10n.dart';
import 'package:memri/widgets/blur_dialog.dart';
import 'package:memri/widgets/loading_indicator.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum AppState { init, loading, success, error, unauthenticated, authenticating }

class AppProvider with ChangeNotifier {
  final PodService _podService;

  AppProvider(this._podService);

  AppState state = AppState.init;
  PackageInfo? _packageInfo;
  String? podVersion;
  String? appVersion;
  String errorMessage = '';
  String welcomeMessage = S.current.check_server_status;
  bool navigationIsVisible = false;
  bool _isLoadingOpened = false;
  bool _checkAuth = true;
  ViewContextController? currentViewContext;

  closeMenu() {
    navigationIsVisible = false;
    notifyListeners();
  }

  openMenu() {
    navigationIsVisible = true;
    notifyListeners();
  }

  PodService get podService => _podService;

  Future<void> initialize() async {
    try {
      state = AppState.init;
      if (appVersion == null || podVersion == null) {
        _packageInfo = await PackageInfo.fromPlatform();
        appVersion = _packageInfo!.version +
            '.' +
            (_packageInfo?.buildNumber == null ||
                    _packageInfo!.buildNumber.isEmpty
                ? '0'
                : _packageInfo!.buildNumber);
        await _updateWelcomeMessage(S.current.welcome);
        podVersion = await _podService.podVersion();
        _handleLoading();
        await Future.delayed(Duration(milliseconds: 700));
      }

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
}
