import 'package:moor/moor_web.dart';

import 'Database.dart';

Database constructDb({bool logStatements = false, bool inMemory = false, required databaseName}) {
  return Database(WebDatabase(databaseName, logStatements: logStatements));
}
