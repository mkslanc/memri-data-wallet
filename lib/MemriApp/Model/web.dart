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
  throw 'Implement web database delete';
}
