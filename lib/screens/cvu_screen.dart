import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:memri/cvu/controllers/view_context_controller.dart';
import 'package:memri/cvu/models/cvu_parsed_definition.dart';
import 'package:memri/cvu/widgets/cvu_editor.dart';
import 'package:memri/cvu/widgets/scene_content_view.dart';
import 'package:memri/widgets/empty.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';

import '../core/services/database/schema.dart';
import '../cvu/controllers/cvu_controller.dart';
import '../widgets/scaffold/cvu_scaffold.dart';

class CVUScreen extends StatefulWidget {
  const CVUScreen({Key? key}) : super(key: key);

  @override
  State<CVUScreen> createState() => _CVUScreenState();
}

class _CVUScreenState extends State<CVUScreen> {
  late Future _init;

  initState() {
    super.initState();
    _init = init();
  }

  init() async {
    //TODO CVU test: this part is just for testing
    var cvuController = GetIt.I<CVUController>();
    await GetIt.I<Schema>().load();
    await cvuController.loadStoredDefinitions();
    if (cvuController.storedDefinitions.isEmpty) {
      await cvuController.init();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Empty();
          }
          return CVUScaffold(
            currentItem: NavigationItem.cvu,
            child: SceneContentView(
              viewContext: ViewContextController.fromParams(
                  viewName: "messageChannelView"),
            ),
            editor: CVUEditor(
              viewDefinition: GetIt.I<CVUController>()
                  .definitionFor(
                      viewName: "messageChannelView",
                      type: CVUDefinitionType.view)!
                  .toCVUString(0, "  ", false),
            ),
          );
        });
  }
}
