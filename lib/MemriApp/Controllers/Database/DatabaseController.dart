import 'dart:io';

import 'package:memri/MemriApp/Model/Database.dart';
import 'package:moor/ffi.dart';
import 'package:path_provider/path_provider.dart' as paths;
import 'package:path/path.dart' as p;

import '../../../globals.dart' as globals;
import 'Schema.dart';

/// The database controller provides access to the app's SQLite database. Generally only a single database controller will be used throughout the app
class DatabaseController {
  String databaseName;

  /// Create a DatabaseController. Change the databaseName to create/access a different database file (eg. for testing purposes)
  DatabaseController(
      [this.databaseName = "memri", //TODO:
      this.schema]);

  init() async {
    databasePool = await () async {
      final dataDir = await paths.getApplicationDocumentsDirectory();
      final url = File(p.join(dataDir.path, databaseName + '.sqlite'));
      print(url);

      if (globals.isRunningTests) {
        return Database(VmDatabase.memory());
      } else {
        return Database(VmDatabase(url));
      }
    }();
    schema = schema ?? await Schema.loadFromFile();
  }

  late Schema? schema;

  /// This is the connection to the database used throughout the app
  late Database databasePool;

  /// Check if the database has been setup //TODO:
//bool get databaseIsSetup => ItemRecord.fetchOne(db) != null ?? false;

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
