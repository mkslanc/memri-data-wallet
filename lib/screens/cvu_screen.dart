import 'package:flutter/material.dart';
import 'package:memri/cvu/controllers/view_context_controller.dart';
import 'package:memri/cvu/widgets/scene_content_view.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';

class CVUScreen extends StatelessWidget {
  const CVUScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WorkspaceScaffold(
      currentItem: NavigationItem.cvu,
      child: SizedBox(
          height: 800,
          child: SceneContentView(
            viewContext: ViewContextController.fromParams(viewName: "allData"),
          )),
    );
  }
}
