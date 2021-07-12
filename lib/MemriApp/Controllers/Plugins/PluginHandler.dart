import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/Controllers/AppController.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemEdgeRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import '../SceneController.dart';

class PluginHandler {
  static start(
      {required ItemRecord plugin,
      required ItemRecord runner,
      required SceneController sceneController,
      required CVUContext context}) async {
    AppController.shared.pubsubController.startObservingItemProperty(
        item: runner,
        property: "state",
        desiredValue: null,
        completion: (newValue, [error]) async {
          if (newValue is PropertyDatabaseValueString) {
            var state = newValue.value;

            switch (state) {
              case "userActionNeeded":
                presentCVUforPlugin(
                    plugin: plugin,
                    runner: runner,
                    sceneController: sceneController,
                    context: context);
                break;
              default:
                break;
            }
            return;
          }
        });

    await AppController.shared.syncController.sync();
  }

  static presentCVUforPlugin(
      {required ItemRecord plugin,
      required ItemRecord runner,
      required SceneController sceneController,
      required CVUContext context}) async {
    var runnerRowId = runner.rowId;
    var view = await plugin.edgeItem("view");
    var viewName = (await view?.propertyValue("definition"))?.value;
    if (runnerRowId == null || viewName == null) {
      AppController.shared.pubsubController
          .stopObservingItemProperty(item: runner, property: "state");
      return;
    }

    var item = ItemRecord(type: "Account");
    item.syncState = SyncState.skip; // Don't sync it yet
    await item.save();
    var itemRowId = item.rowId;
    if (itemRowId == null) {
      return;
    }

    var edge = ItemEdgeRecord(sourceRowID: runnerRowId, name: "account", targetRowID: itemRowId);
    edge.syncState = SyncState.skip; // Don't sync it yet
    await edge.save();

    var newVars = <String, CVUValue>{};
    newVars["viewArguments"] = CVUValueSubdefinition(
        CVUDefinitionContent(properties: {"readOnly": CVUValueConstant(CVUConstantBool(false))}));
    await CVUActionOpenView(viewName: viewName, renderer: "generalEditor")
        .execute(sceneController, context.replacingItem(item));
    sceneController.isInEditMode.value = true;
  }
}
