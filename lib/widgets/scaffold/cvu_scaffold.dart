import 'package:flutter/material.dart';
import 'package:memri/widgets/components/layout/search_bar.dart';
import 'package:memri/widgets/components/layout/top_bar_view.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../navigation/navigation_pane_view.dart';
import 'base_scaffold.dart';

class CVUScaffold extends StatelessWidget {
  const CVUScaffold(
      {Key? key, /*required this.currentItem,*/ required this.child, this.bottomBar})
      : super(key: key);

  final Widget child;
  final Widget? bottomBar;
  //final NavigationItem currentItem;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (BuildContext context, provider, _) {
      return BaseScaffold(
        body: Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
            titleSpacing: 0,
            title: provider.searchBarOpen ? SearchTopBar(
                viewContext: provider.currentViewContext!) : TopBarView(),
          ),
          drawer: Drawer(
            child: NavigationPaneView(),
          ),
          body: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: child,
              ),
            ],
          ),
          bottomNavigationBar: bottomBar,
          bottomSheet: null,
        ),
      );
    });
  }
}
