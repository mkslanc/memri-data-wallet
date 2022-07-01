import 'package:flutter/material.dart';
import 'package:memri/core/controllers/app_controller.dart';
import 'package:memri/cvu/controllers/view_context_controller.dart';
import 'package:memri/cvu/models/cvu_parsed_definition.dart';
import 'package:memri/cvu/widgets/cvu_editor.dart';
import 'package:memri/cvu/widgets/scene_content_view.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';

import '../widgets/scaffold/cvu_scaffold.dart';

class CVUScreen extends StatelessWidget {
  const CVUScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CVUScaffold(
      currentItem: NavigationItem.cvu,
      child: SceneContentView(
        viewContext: ViewContextController.fromParams(viewName: "allData"),
      ),
      editor: CVUEditor(
        viewDefinition: AppController.shared.cvuController
            .definitionFor(viewName: "allData", type: CVUDefinitionType.view)!
            .toCVUString(0, "  ", false),
      ),
    );
  }
}
