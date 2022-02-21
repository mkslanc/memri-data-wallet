import 'package:memri/models/database/database.dart';
import 'package:moor/isolate.dart';
import 'package:moor/moor.dart';

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

DatabaseConnection connectToWorker() {
  throw 'Platform not supported';
}
