import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/core/controllers/authentication.dart';
import 'package:memri/core/services/pod_service.dart';
import 'package:memri/cvu/controllers/view_context_controller.dart';
import 'package:memri/localization/generated/l10n.dart';
import 'package:memri/widgets/blur_dialog.dart';
import 'package:memri/widgets/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/database/schema.dart';
import '../cvu/controllers/cvu_controller.dart';
import '../utilities/helpers/app_helper.dart';

enum AppState { init, loading, success, error, unauthenticated, authenticating, loggedIn }

class AppProvider with ChangeNotifier {
  final PodService _podService;

  AppProvider(this._podService);

  AppState state = AppState.init;
  String? podVersion;
  String? appVersion;
  String errorMessage = '';
  String welcomeMessage = S.current.check_server_status;

  bool _filterPanelIsVisible = false;
  bool _isLoadingOpened = false;
  bool _checkAuth = true;
  ViewContextController? currentViewContext;
  bool isInEditMode = false;
  bool searchBarOpen = false;
  bool _isDrawerOpen = false;

  bool get isDrawerOpen => _isDrawerOpen;

  void toggleDrawer() {
    _isDrawerOpen = !_isDrawerOpen;
    notifyListeners();
  }

  toggleEditMode() {
    isInEditMode = !isInEditMode;
    notifyListeners();
  }

  toggleSearchBar() {
    searchBarOpen = !searchBarOpen;
    notifyListeners();
  }

  get filterPanelIsVisible => _filterPanelIsVisible;
  set filterPanelIsVisible(value) {
    _filterPanelIsVisible = !_filterPanelIsVisible;
    notifyListeners();
  }

  bool _isConnectionError = false;

  bool get isConnectionError => _isConnectionError;

  void set isConnectionError(bool value) {
    if (_isConnectionError != value) {
      _isConnectionError = value;
      notifyListeners();
    }
  }

  void retryConnection() {
    currentViewContext?.refreshScreen();
  }

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
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.remove(app.keys.podAddress);
    await Authentication.instance.removeAll();
  }
}
