import 'package:flutter/material.dart';
import 'package:memri/providers/app_provider.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/base_scaffold.dart';
import 'package:provider/provider.dart';

class WorkspaceScaffold extends StatelessWidget {
  const WorkspaceScaffold(
      {Key? key, required this.currentItem, required this.child})
      : super(key: key);

  final Widget child;
  final NavigationItem currentItem;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (BuildContext context, provider, _) {
      return BaseScaffold(
        appBar: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width,
              provider.navigationIsVisible ? 368 : 191),
          child: NavigationAppBar(currentItem: currentItem),
        ),
        body: child,
      );
    });
  }
}
