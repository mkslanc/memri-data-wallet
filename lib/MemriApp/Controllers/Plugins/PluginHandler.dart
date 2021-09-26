import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/Controllers/AppController.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemEdgeRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import '../SceneController.dart';

class PluginHandler {
  static run(
      {required ItemRecord plugin,
      required ItemRecord runner,
      required SceneController sceneController,
      required CVUContext context}) async {
    AppController.shared.pubsubController.startObservingItemProperty(
        item: runner,
        property: "status",
        desiredValue: null,
        completion: (newValue, [error]) async {
          if (newValue is PropertyDatabaseValueString) {
            var status = newValue.value;

            switch (status) {
              case "userActionNeeded":
                presentCVUforPlugin(
                    plugin: plugin,
                    runner: runner,
                    sceneController: sceneController,
                    context: context);
                break;
              case "done":
              case "error":
                stopPlugin(
                    plugin: plugin,
                    runner: runner,
                    sceneController: sceneController,
                    status: status);
                break;
              default:
                break;
            }
            return;
          }
        });

    await AppController.shared.syncController.sync();
  }

  static stopPlugin(
      {required ItemRecord plugin,
      required ItemRecord runner,
      required SceneController sceneController,
      required String status}) async {
    AppController.shared.pubsubController
        .stopObservingItemProperty(item: runner, property: "status");

    var pluginName = (await plugin.property("pluginName"))!.$value.value;
    var item = await runner.edgeItem("account");

    await sceneController.navigateToNewContext(
        clearStack: true, animated: false, viewName: "allPlugins"); //TODO
    await sceneController.navigateToNewContext(
        animated: false,
        viewName: "${pluginName}-$status",
        pageController: sceneController.secondaryPageController,
        targetItem: item);
  }

  static presentCVUforPlugin(
      {required ItemRecord plugin,
      required ItemRecord runner,
      required SceneController sceneController,
      required CVUContext context}) async {
    var runnerRowId = runner.rowId;

    var item = await runner.edgeItem("account");

    if (item == null) {
      item = ItemRecord(type: "Account");
      item.syncState = SyncState.skip; // Don't sync it yet
      await item.save();
      var itemRowId = item.rowId;
      if (itemRowId == null) {
        return;
      }

      var edge = ItemEdgeRecord(sourceRowID: runnerRowId, name: "account", targetRowID: itemRowId);
      edge.syncState = SyncState.skip; // Don't sync it yet
      await edge.save();

      var meRowID = (await ItemRecord.me())!.rowId;
      var meEdge = ItemEdgeRecord(sourceRowID: itemRowId, name: "owner", targetRowID: meRowID);
      meEdge.syncState = SyncState.skip; // Don't sync it yet
      await meEdge.save();
    }

    var pluginName = (await plugin.property("pluginName"))!.$value.value;

    await runner.setPropertyValue("status", PropertyDatabaseValueString("cvuPresented"));

    await sceneController.navigateToNewContext(
        clearStack: true, animated: false, viewName: "allPlugins");
    await sceneController.navigateToNewContext(
        animated: false,
        viewName: "${pluginName}-userActionNeeded",
        pageController: sceneController.secondaryPageController,
        targetItem: item);
  }
}
