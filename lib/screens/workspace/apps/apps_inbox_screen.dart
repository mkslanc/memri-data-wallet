import 'package:flutter/material.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';

class AppsInboxScreen extends StatefulWidget {
  final showMainNavigation;
  final String? importer;

  AppsInboxScreen({this.showMainNavigation = true, this.importer});

  @override
  _AppsInboxScreenState createState() => _AppsInboxScreenState();
}

class _AppsInboxScreenState extends State<AppsInboxScreen> {
  @override
  Widget build(BuildContext context) {
    return WorkspaceScaffold(
      currentItem: NavigationItem.apps,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(30, 30, 0, 30),
        child: Container(child: Text(widget.importer ?? "")),
      ),
    );
  }
}
