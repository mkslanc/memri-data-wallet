import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:memri/cvu/controllers/view_context_controller.dart';
import 'package:memri/providers/connection_provider.dart';
import 'package:memri/providers/ui_state_provider.dart';
import 'package:memri/widgets/components/layout/search_bar.dart';
import 'package:memri/widgets/components/layout/top_bar_view.dart';
import 'package:provider/provider.dart';

import '../navigation/navigation_pane_view.dart';
import 'base_scaffold.dart';

class CVUScaffold extends StatelessWidget {
  CVUScaffold({
    Key? key,
    required this.child,
    this.bottomBar,
    required this.viewContextController,
  }) : super(key: key);

  final Widget child;
  final Widget? bottomBar;
  final ViewContextController viewContextController;

  UIStateProvider get uiStateProvider => GetIt.I<UIStateProvider>();


  @override
  @override
  Widget build(BuildContext context) {
    return Consumer<UIStateProvider>(
      builder: (context, provider, _) {
        return ChangeNotifierProvider<ViewContextController>.value(
          value: viewContextController,
          child: Consumer<ViewContextController>(
            builder: (context, provider, _) {
              return _buildScaffold(context);
            },
          ),
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return BaseScaffold(
      body: Stack(
        children: [
          Scaffold(
            appBar: _appBar,
            body: Column(
              children: [
                _notificationBanner,
                Expanded(
                  child: child,
                ),
              ],
            ),
            bottomNavigationBar: bottomBar,
          ),
          if (uiStateProvider.isDrawerOpen)
            _drawer,
        ],
      ),
    );
  }
  AppBar get _appBar => AppBar(
    leading: Builder(
      builder: (context) {
        return IconButton(
          icon: uiStateProvider.canNavigateBack ? Icon(Icons.arrow_back) : Icon(Icons.menu),
          onPressed: () {
            if (uiStateProvider.canNavigateBack) {
              uiStateProvider.navigateBack(context);
            } else {
              uiStateProvider.toggleDrawer();
            }
          },
        );
      },
    ),
    titleSpacing: 0,
    title: viewContextController.searchBarOpen
        ? SearchTopBar(
      viewContext: viewContextController,
    )
        : TopBarView(),
  );

  Widget get _notificationBanner => Consumer<ConnectionProvider>(
    builder: (context, controller, _) {
      if (controller.isConnectionError) {
        return Container(
          width: double.infinity,
          color: Colors.orangeAccent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Unable to refresh data due to connectivity issues.',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              TextButton(
                onPressed: () {
                  uiStateProvider.refreshScreen();
                },
                child: Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return SizedBox.shrink();
      }
    },
  );

  Widget get _drawer => GestureDetector(
    onTap: uiStateProvider.toggleDrawer,
    child: Container(
      color: Colors.black54,
      child: Row(
        children: [
          Container(
            width: 250,
            color: Colors.white,
            child: NavigationPaneView(),
          ),
          Expanded(child: Container()),
        ],
      ),
    ),
  );
}
