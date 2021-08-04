import 'dart:ffi';
import 'dart:io';

import 'package:memri/MemriApp/Controllers/API/Authentication.dart';
import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';

import 'package:path_provider/path_provider.dart' as paths;
import 'package:path/path.dart' as p;

import 'Database.dart';
import 'package:sqlite3/open.dart';

void setupSqlCipher() {
  open.overrideFor(OperatingSystem.android, () => DynamicLibrary.open('libsqlcipher.so'));
}

Database constructDb({bool logStatements = false, bool inMemory = false, required databaseName}) {
  setupSqlCipher();
  if (!inMemory) {
    if (Authentication.lastRootPublicKey == null) throw Exception("Root key is not defined!");

    if (Platform.isIOS || Platform.isAndroid) {
      final executor = LazyDatabase(() async {
        final dataDir = await paths.getApplicationDocumentsDirectory();
        final dbFile = File(p.join(dataDir.path + '/databases', databaseName + '.sqlite'));
        return VmDatabase(dbFile, setup: (rawDb) {
          rawDb.execute("PRAGMA key = '${Authentication.lastRootPublicKey}';");
        }, logStatements: logStatements);
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
