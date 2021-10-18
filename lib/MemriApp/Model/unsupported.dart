import 'package:moor/isolate.dart';

import 'Database.dart';

Database constructDb({bool logStatements = false, bool inMemory = false, required databaseName}) {
  throw 'Platform not supported';
}

Future<void> deleteDb(databaseName) async {
  throw 'Platform not supported';
}

Future<DriftIsolate> createDriftIsolate(
    {bool logStatements = false, bool inMemory = false, required databaseName}) {
  throw 'Platform not supported';
}
