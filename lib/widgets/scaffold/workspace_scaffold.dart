import 'package:flutter/material.dart';
import 'package:memri/core/controllers/app_controller.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';

class WorkspaceScaffold extends StatelessWidget {
  const WorkspaceScaffold(
      {Key? key, required this.currentItem, required this.child})
      : super(key: key);

  final Widget child;
  final NavigationItem currentItem;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: AppController.shared.navigationIsVisible,
        builder: (BuildContext context, bool value, _) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize:
                  Size(MediaQuery.of(context).size.width, value ? 368 : 191),
              child: NavigationAppBar(currentItem: currentItem),
            ),
            body: child,
          );
        });
  }
}
