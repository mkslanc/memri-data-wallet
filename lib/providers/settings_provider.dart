import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utilities/helpers/app_helper.dart';

class SettingsProvider with ChangeNotifier {
  late final SharedPreferences _prefs;

  static const String _developerModeKey = 'cvuDeveloperMode';

  bool _cvuDeveloperMode = false;

  String _podAddress = app.settings.defaultPodUrl;

  String get podAddress => _podAddress;

  bool get cvuDeveloperMode => _cvuDeveloperMode;

  SettingsProvider(SharedPreferences prefs) {
    _prefs = prefs;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _cvuDeveloperMode = _prefs.getBool(_developerModeKey) ?? false;
    _podAddress = _prefs.getString(app.keys.podAddress) ?? app.settings.defaultPodUrl;

    notifyListeners();
  }

  Future<void> setCvuDeveloperMode(bool isEnabled) async {
    _cvuDeveloperMode = isEnabled;
    await _prefs.setBool(_developerModeKey, isEnabled);
    notifyListeners();
  }

  Future<void> setPodAddress(String address) async {
    _podAddress = address;
    await _prefs.setString(app.keys.podAddress, address);
    notifyListeners();
  }

  clear() async {
    await _prefs.clear();
  }

}
