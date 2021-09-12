import 'package:memri/MemriApp/CVU/CVUController.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUParseErrors.dart';
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
                stopPlugin(runner);
                break;
              default:
                break;
            }
            return;
          }
        });

    await AppController.shared.syncController.sync();
  }

  static stopPlugin(ItemRecord runner) {
    AppController.shared.pubsubController
        .stopObservingItemProperty(item: runner, property: "status");
  }

  static presentCVUforPlugin(
      {required ItemRecord plugin,
      required ItemRecord runner,
      required SceneController sceneController,
      required CVUContext context}) async {
    var runnerRowId = runner.rowId;
    List<ItemRecord> viewList =
        await runner.edgeItems("view"); //TODO plugin should delete previous edge
    viewList.sort((a, b) =>
        (b.dateServerModified?.millisecondsSinceEpoch ?? 0) -
        (a.dateServerModified?.millisecondsSinceEpoch ?? 0));
    ItemRecord? view = viewList.asMap()[0];
    var cvuContent = (await view?.propertyValue("definition"))?.value;

    List<CVUParsedDefinition>? parsedDefinitions;
    if (cvuContent != null) {
      try {
        parsedDefinitions = await CVUController.parseCVU(cvuContent);
      } on CVUParseErrors catch (error) {
        print(error.toString());
      }
    }
    var parsedDefinition = parsedDefinitions?.asMap()[0];
    var cvuDefinition = parsedDefinition?.parsed;
    if (parsedDefinitions == null || parsedDefinition == null || cvuDefinition == null) {
      return;
    }

    AppController.shared.cvuController.storedDefinitions = parsedDefinitions;

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

    await runner.setPropertyValue("status", PropertyDatabaseValueString("cvuPresented"));

    await sceneController.navigateToNewContext(
        targetItem: item, viewName: parsedDefinition.name, defaultDefinition: cvuDefinition);
  }
}
