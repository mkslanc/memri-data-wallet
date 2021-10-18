import 'package:idb_shim/idb.dart' as idb;
import 'package:idb_shim/idb_browser.dart';
import 'package:moor/moor.dart';
import 'package:moor/moor_web.dart';

import 'Database.dart';

Database constructDb({bool logStatements = false, bool inMemory = false, required databaseName}) {
  final executor = LazyDatabase(() async {
    return WebDatabase.withStorage(await MoorWebStorage.indexedDbIfSupported(databaseName),
        logStatements: logStatements);
  });
  return Database(executor);
}

Future<void> deleteDb(databaseName) async {
  final idbFactory = getIdbFactory();
  if (idbFactory == null) {
    throw Exception('getIdbFactory() failed');
  }

  var dbName = "moor_databases";

  var db = await idbFactory.open(dbName);

  var txn = db.transaction(dbName, idb.idbModeReadWrite);
  var store = txn.objectStore(dbName);
  await store.clear();
  await txn.completed;
}

Database createDbConnection(
    {bool logStatements = false, bool inMemory = false, required databaseName}) {
  throw 'Platform not supported';
}
