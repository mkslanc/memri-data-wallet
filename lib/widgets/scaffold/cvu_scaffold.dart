import 'package:flutter/material.dart';
import 'package:memri/widgets/components/layout/top_bar_view.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../navigation/navigation_pane_view.dart';

class CVUScaffold extends StatelessWidget {
  const CVUScaffold(
      {Key? key, /*required this.currentItem,*/ required this.child})
      : super(key: key);

  final Widget child;

  //final NavigationItem currentItem;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (BuildContext context, provider, _) {
      return Scaffold(
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
          title: TopBarView(),
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
      );
    });
  }
}
