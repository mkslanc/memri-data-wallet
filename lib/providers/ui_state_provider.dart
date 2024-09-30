import 'package:flutter/material.dart';
import 'package:memri/cvu/controllers/view_context_controller.dart';

import '../screens/all_item_types_screen.dart';
import '../screens/cvu_screen.dart';

class UIStateProvider with ChangeNotifier {
  bool _isDrawerOpen = false;
  bool _filterPanelIsVisible = false;

  List<ViewContextController> _viewContexts = [];

  ViewContextController? get currentViewContext => _viewContexts.lastOrNull;

  void refreshScreen() {
    currentViewContext?.refreshScreen();
  }

  void toggleDrawer() {
    _isDrawerOpen = !_isDrawerOpen;
    notifyListeners();
  }

  bool get isDrawerOpen => _isDrawerOpen;

  bool get filterPanelIsVisible => _filterPanelIsVisible;

  set filterPanelIsVisible(bool value) {
    _filterPanelIsVisible = value;
    notifyListeners();
  }

  navigateToScreen(BuildContext context, ViewContextController viewContextController,
      {bool? clearStack = false}) {
    clearStack ??= false;
    var route = MaterialPageRoute(
      builder: (context) => viewContextController.config.viewName == "allItemTypes"
          ? AllItemTypesScreen(viewContextController: viewContextController)
          : CVUScreen(
              viewContextController: currentViewContext!,
            ),
    );
    if (clearStack) {
      _viewContexts = [];
      Navigator.pushAndRemoveUntil(context, route, (Route<dynamic> route) => false);
    } else {
      Navigator.push(context, route);
    }

    navigateToContext(viewContextController);
  }

  navigateToContext(ViewContextController viewContextController) {
    _viewContexts.add(viewContextController);
  }

  bool get canNavigateBack => _viewContexts.length > 1;

  navigateBack(BuildContext context) {
    Navigator.pop(context);
    _viewContexts.removeLast();
  }
}
