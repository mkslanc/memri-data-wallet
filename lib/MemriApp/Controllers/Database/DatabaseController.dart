import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Model/Database.dart';
import 'DemoData.dart';
import 'Schema.dart';

/// The database controller provides access to the app's SQLite database. Generally only a single database controller will be used throughout the app
class DatabaseController {
  late Schema? _schema;

  /// This is the connection to the database used throughout the app
  late Database databasePool;
  String databaseName;
  bool inMemory;
  bool isInited = false;

  Schema get schema => _schema!; //TODO this is done because constructors can't be async

  /// Create a DatabaseController. Change the databaseName to create/access a different database file (eg. for testing purposes)
  DatabaseController(
      {this.databaseName = "memri", //TODO:
      schema,
      this.inMemory = false})
      : this._schema = schema;

  init() async {
    if (isInited) return;
    databasePool = await () async {
      return constructDb(inMemory: inMemory, databaseName: databaseName);
    }();
    _schema ??= await Schema.loadFromFile();
    isInited = true;
  }

  Future<List<ItemRecord>> search(String? searchString) async {
    var searchQuery = searchString;
    if (searchQuery == null) {
      throw Exception("Invalid search string: $searchString");
    }
    var refinedQuery = "$searchQuery*";
    return await ItemRecord.search(this, refinedQuery);
  }

  Future<bool> get hasImportedSchema async {
    var item = await this.databasePool.itemRecordFetchOneByType("ItemPropertySchema");
    return (item != null);
  }

  Future<bool> get hasImportedDefaultData async {
    var item = await this.databasePool.itemRecordFetchOneByType("NavigationItem");
    return (item != null);
  }

  Future<bool> get hasImportedDemoData async {
    var item = await this.databasePool.itemRecordFetchOneByType("Photo");
    return (item != null);
  }

  importRequiredData() async {
    if (!await hasImportedSchema) {
      await DemoData.importSchema();
    }

    if (!await hasImportedDefaultData) {
      await DemoData.importDefaultData();
    }
  }

  setupWithDemoData() async {
    if (await hasImportedDemoData) {
      // If there is already data set up, don't import
      return;
    }
    await DemoData.importDemoData(databaseController: this);
  }
}
