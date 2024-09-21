import 'package:flutter/material.dart';
import 'package:memri/cvu/controllers/view_context_controller.dart';
import 'package:memri/providers/connection_provider.dart';
import 'package:memri/providers/ui_state_provider.dart';
import 'package:memri/widgets/components/layout/search_bar.dart';
import 'package:memri/widgets/components/layout/top_bar_view.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../navigation/navigation_pane_view.dart';
import 'base_scaffold.dart';

class CVUScaffold extends StatelessWidget {
  const CVUScaffold({
    Key? key,
    required this.child,
    this.bottomBar,
    required this.viewContextController,
  }) : super(key: key);

  final Widget child;
  final Widget? bottomBar;
  final ViewContextController viewContextController;

  @override
  Widget build(BuildContext context) {
    // Provide ViewContextController here
    return ChangeNotifierProvider<ViewContextController>.value(
      value: viewContextController,
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final uiStateProvider = Provider.of<UIStateProvider>(context);
    return BaseScaffold(
      body: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: Navigator.canPop(context) ? Icon(Icons.arrow_back) : Icon(Icons.menu),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                        if (viewContextController.previousViewContext != null) {
                          uiStateProvider.currentViewContext =
                              viewContextController.previousViewContext;
                        }
                      } else {
                        uiStateProvider.toggleDrawer();
                      }
                    },
                  );
                },
              ),
              titleSpacing: 0,
              title: uiStateProvider.searchBarOpen
                  ? SearchTopBar(
                      viewContext: uiStateProvider.currentViewContext!,
                    )
                  : TopBarView(),
            ),
            body: Column(
              children: [
                // Notification Banner
                Consumer<ConnectionProvider>(
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
                ),
                // Main Content
                Expanded(
                  child: child,
                ),
              ],
            ),
            bottomNavigationBar: bottomBar,
          ),
          if (uiStateProvider.isDrawerOpen)
            GestureDetector(
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
            ),
        ],
      ),
    );
  }
}
