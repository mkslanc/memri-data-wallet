import 'dart:io';

import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';

import 'package:path_provider/path_provider.dart' as paths;
import 'package:path/path.dart' as p;

import 'Database.dart';

Database constructDb({bool logStatements = false, bool inMemory = false, required databaseName}) {
  if (!inMemory) {
    if (Platform.isIOS || Platform.isAndroid) {
      final executor = LazyDatabase(() async {
        final dataDir = await paths.getApplicationDocumentsDirectory();
        final dbFile = File(p.join(dataDir.path, databaseName + '.sqlite'));
        return VmDatabase(dbFile, logStatements: logStatements);
      });
      return Database(executor);
    }
    if (Platform.isMacOS || Platform.isLinux) {
      final file = File(databaseName + '.sqlite');
      return Database(VmDatabase(file, logStatements: logStatements));
    }
  }
  return Database(VmDatabase.memory(logStatements: logStatements));
}
