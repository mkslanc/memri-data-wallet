import 'package:flutter/material.dart';
import 'package:memri/cvu/controllers/view_context_controller.dart';

class UIStateProvider with ChangeNotifier {
  bool isInEditMode = false;
  bool searchBarOpen = false;
  bool _isDrawerOpen = false;
  bool _filterPanelIsVisible = false;
  ViewContextController? currentViewContext;

  void refreshScreen() {
    currentViewContext?.refreshScreen();
  }

  void toggleDrawer() {
    _isDrawerOpen = !_isDrawerOpen;
    notifyListeners();
  }

  bool get isDrawerOpen => _isDrawerOpen;

  void toggleEditMode() {
    isInEditMode = !isInEditMode;
    notifyListeners();
  }

  void toggleSearchBar() {
    searchBarOpen = !searchBarOpen;
    notifyListeners();
  }

  bool get filterPanelIsVisible => _filterPanelIsVisible;

  set filterPanelIsVisible(bool value) {
    _filterPanelIsVisible = value;
    notifyListeners();
  }
}
