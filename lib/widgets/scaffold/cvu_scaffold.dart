import 'package:flutter/material.dart';
import 'package:memri/cvu/controllers/view_context_controller.dart';
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
    return Consumer<AppProvider>(
      builder: (BuildContext context, provider, _) {
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
                              provider.currentViewContext =
                                  viewContextController.previousViewContext;
                            }
                          } else {
                            provider.toggleDrawer();
                          }
                        },
                      );
                    },
                  ),
                  titleSpacing: 0,
                  title: provider.searchBarOpen
                      ? SearchTopBar(viewContext: provider.currentViewContext!)
                      : TopBarView(),
                ),
                body: child,
                bottomNavigationBar: bottomBar,
              ),
              if (provider.isDrawerOpen)
                GestureDetector(
                  onTap: provider.toggleDrawer,
                  child: Container(
                    color: Colors.black54, // Background color when drawer is open
                    child: Row(
                      children: [
                        Container(
                            width: 250, // Width of the custom drawer
                            color: Colors.white,
                            child: NavigationPaneView()),
                        Expanded(
                          child: Container(),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
