import 'package:memri/controllers/app_controller.dart';
import 'package:memri/controllers/page_controller.dart' as memri;
import 'package:memri/core/cvu/resolving/cvu_context.dart';
import 'package:memri/core/services/database/property_database_value.dart';
import 'package:memri/models/database/item_edge_record.dart';
import 'package:memri/models/database/item_record.dart';

class PluginHandler {
  static run(
      {required ItemRecord plugin,
      required ItemRecord runner,
      required memri.PageController pageController,
      required CVUContext context}) async {
    AppController.shared.pubSubController.startObservingItemProperty(
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
                    pageController: pageController,
                    context: context);
                break;
              case "done":
              case "daemon":
              case "error":
                //TODO: do we have better solution?
                pageController.sceneController.scheduleUIUpdate();
                stopPlugin(
                    plugin: plugin, runner: runner, pageController: pageController, status: status);
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
      required memri.PageController pageController,
      required String status}) async {
    AppController.shared.pubSubController
        .stopObservingItemProperty(item: runner, property: "status");
  }

  static presentCVUforPlugin(
      {required ItemRecord plugin,
      required ItemRecord runner,
      required memri.PageController pageController,
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

    await pageController.sceneController.navigateToNewContext(
        animated: false,
        viewName: "${pluginName}-userActionNeeded",
        pageController: pageController,
        targetItem: item);
  }
}
