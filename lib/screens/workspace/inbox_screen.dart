import 'package:flutter/material.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';

class InboxScreen extends StatefulWidget {
  final showMainNavigation;

  InboxScreen({this.showMainNavigation = true});

  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  Widget build(BuildContext context) {
    return WorkspaceScaffold(
      currentItem: NavigationItem.apps,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(30, 30, 0, 30),
        child: Container(),
      ),
    );
  }
}
