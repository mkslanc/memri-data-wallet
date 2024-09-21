import 'package:flutter/material.dart';

class ConnectionProvider with ChangeNotifier {
  bool _isConnectionError = false;

  bool get isConnectionError => _isConnectionError;

  set isConnectionError(bool value) {
    if (_isConnectionError != value) {
      _isConnectionError = value;
      notifyListeners();
    }
  }

}
