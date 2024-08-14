import 'package:flutter/material.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../utilities/helpers/app_helper.dart';
import '../navigation/navigation_pane_view.dart';

class CVUScaffold extends StatelessWidget {
  const CVUScaffold(
      {Key? key, /*required this.currentItem,*/ required this.child, required this.editor})
      : super(key: key);

  final Widget child;
  final Widget editor;
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
        ),
        drawer: Drawer(child: NavigationPaneView(),),
        body: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: child,
            ),
            /* SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: editor,
          )*/
          ],
        ),
      );
    });
  }
}
