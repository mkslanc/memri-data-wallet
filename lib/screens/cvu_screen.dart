import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:memri/cvu/controllers/view_context_controller.dart';
import 'package:memri/cvu/models/cvu_parsed_definition.dart';
import 'package:memri/cvu/widgets/cvu_editor.dart';
import 'package:memri/cvu/widgets/scene_content_view.dart';
import 'package:memri/widgets/empty.dart';

import '../core/services/database/schema.dart';
import '../cvu/controllers/cvu_controller.dart';
import '../widgets/scaffold/cvu_scaffold.dart';

class CVUScreen extends StatefulWidget {
  final ViewContextController viewContextController;
  const CVUScreen({Key? key, required this.viewContextController}) : super(key: key);

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
    try {
      //TODO CVU test: this part is just for testing
      var cvuController = GetIt.I<CVUController>();
      await GetIt.I<Schema>().loadFromPod();
      await cvuController.loadStoredDefinitions();
      if (cvuController.storedDefinitions.isEmpty) {
        await cvuController.init();
      }
      return true;
    } catch (error) {
      return false;
    }
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
            // currentItem: NavigationItem.cvu,
            child: SceneContentView(
              viewContext: widget.viewContextController,
            ),
            editor: CVUEditor(
              viewDefinition: GetIt.I<CVUController>()
                      .definitionFor(viewName: "messageChannelView", type: CVUDefinitionType.view)
                      ?.toCVUString(0, "  ", false) ??
                  "",
            ),
          );
        });
  }
}
