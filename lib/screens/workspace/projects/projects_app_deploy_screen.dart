import 'package:flutter/material.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';

class ProjectsAppDeployScreen extends StatelessWidget {
  const ProjectsAppDeployScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WorkspaceScaffold(
      currentItem: NavigationItem.data,
      child: Container(),
    );
  }
}
