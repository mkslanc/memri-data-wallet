import 'dart:io';

import 'package:memri/MemriApp/Model/Database.dart';
import 'package:moor/ffi.dart';
import 'package:path_provider/path_provider.dart' as paths;
import 'package:path/path.dart' as p;

import 'Schema.dart';

/// The database controller provides access to the app's SQLite database. Generally only a single database controller will be used throughout the app
class DatabaseController {
  late Schema? _schema;

  /// This is the connection to the database used throughout the app
  late Database databasePool;
  String databaseName;
  bool inMemory;

  Schema get schema =>
      _schema!; //TODO this is done because constructors can't be async

  /// Create a DatabaseController. Change the databaseName to create/access a different database file (eg. for testing purposes)
  DatabaseController(
      {this.databaseName = "memri", //TODO:
      schema,
      this.inMemory = false})
      : this._schema = schema;

  init() async {
    databasePool = await () async {
      if (inMemory) {
        return Database(VmDatabase.memory());
      } else {
        final dataDir = await paths.getApplicationDocumentsDirectory();
        final url = File(p.join(dataDir.path, databaseName + '.sqlite'));
        print(url);
        return Database(VmDatabase(url));
      }
    }();
    _schema ??= await Schema.loadFromFile();
  }

  /// Check if the database has been setup
  bool get databaseIsSetup =>
      /*ItemRecord.fetchWithUID(db) != null ?? */ false; //TODO

/*[ItemRecord]*/ /* search(String searchString)  { //TODO:
        */ /*try read { (db) in
            guard let searchQuery = FTS3Pattern(matchingAllTokensIn: searchString) else {
                throw StringError(description: "Invalid search string: \(searchString)")
            }
            let refinedQuery = try FTS3Pattern(rawPattern: "\(searchQuery.rawPattern)*")
            let search = try ItemRecord.search(db, pattern: refinedQuery)
            return search
        }*/ /*
    }*/
}
