import 'package:flutter/foundation.dart';
import 'package:memri/core/services/database/demo_data.dart';
import 'package:memri/core/services/database/schema.dart';
import 'package:memri/core/services/database/shared.dart';
import 'package:memri/models/database/database.dart';
import 'package:memri/models/database/item_record.dart';
import 'package:memri/utils/extensions/collection.dart';
import 'package:memri/utils/extensions/string.dart';
import 'package:moor/isolate.dart';
import 'package:moor/moor.dart';

/// The database controller provides access to the app's SQLite database. Generally only a single database controller will be used throughout the app
class DatabaseController {
  Schema schema;

  /// This is the connection to the database used throughout the app
  late Database databasePool;
  String databaseName;
  bool inMemory;
  bool isInited = false;
  DriftIsolate? driftIsolate;
  late DatabaseConnection connection;

  /// Create a DatabaseController. Change the databaseName to create/access a different database file (eg. for testing purposes)
  DatabaseController({this.databaseName = "memri", Schema? schema, this.inMemory = false})
      : this.schema = schema ?? Schema();

  init() async {
    if (isInited) return;
    if (!kIsWeb) {
      driftIsolate = await createDriftIsolate(inMemory: inMemory, databaseName: databaseName);
      connection = await driftIsolate!.connect();
    } else {
      connection = connectToWorker();
    }

    databasePool = Database.connect(connection);

    if (await hasImportedSchema) {
      await schema.load(databasePool);
    }

    isInited = true;
  }

  Future<void> delete() async {
    await databasePool.close();
    databasePool.attachedDatabase.close();
    if (!inMemory || kIsWeb) {
      await deleteDb(databaseName);
    }
    isInited = false;
  }

  Future<List<ItemRecord>> search(String? searchString) async {
    var searchQuery = searchString?.replaceAll('"', "");
    if (searchQuery == null) {
      throw Exception("Invalid search string: $searchString");
    }
    searchQuery =
        searchQuery.split(" ").compactMap((e) => e.nullIfBlank == null ? null : '"$e"').join(" ");
    var refinedQuery = '$searchQuery*';
    return await ItemRecord.search(this, refinedQuery);
  }

  Future<bool> get hasImportedSchema async {
    var item = await databasePool.itemRecordFetchOneByType("ItemPropertySchema");
    return (item != null);
  }

  Future<bool> get hasImportedDefaultData async {
    var item = await databasePool.itemRecordFetchOneByType("NavigationItem");
    return (item != null);
  }

  Future<bool> get hasImportedDemoData async {
    var item = await databasePool.itemRecordFetchOneByType("Photo");
    return (item != null);
  }

  importRequiredData({bool throwIfAgainstSchema = false}) async {
    if (!await hasImportedSchema) {
      await DemoData.importSchemaOnce(
          databaseController: this, throwIfAgainstSchema: throwIfAgainstSchema);
    }

    if (!await hasImportedDefaultData) {
      await DemoData.importDefaultData(
          databaseController: this, throwIfAgainstSchema: throwIfAgainstSchema);
    }
  }

  setupWithDemoData({bool throwIfAgainstSchema = false}) async {
    if (await hasImportedDemoData) {
      // If there is already data set up, don't import
      return;
    }
    await DemoData.importDemoData(
        databaseController: this, throwIfAgainstSchema: throwIfAgainstSchema);
  }

  //TODO: hope this is temporary solution
  Map<String, dynamic> storage = {};
}
