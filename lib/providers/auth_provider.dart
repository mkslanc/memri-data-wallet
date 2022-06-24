import 'package:flutter/foundation.dart';

enum AuthState {
  setup,
  keySaving,
  authentication,
  authenticated,
  incompatibleDevice,
  incompatibleBrowser,
  maintenance
}

class AuthProvider with ChangeNotifier {}
