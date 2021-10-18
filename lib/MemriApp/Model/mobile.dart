import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:memri/MemriApp/Controllers/API/Authentication_mobile.dart';
import 'package:memri/MemriApp/Controllers/AppController.dart';
import 'package:moor/ffi.dart';
import 'package:moor/isolate.dart';
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

Future<void> deleteDb(databaseName) async {
  final dataDir = await paths.getApplicationDocumentsDirectory();
  final dbFile = File(p.join(dataDir.path + '/databases', databaseName + '.sqlite'));

  await dbFile.delete();
}

void _backgroundConnection(_IsolateStartRequest request) {
  setupSqlCipher();
  QueryExecutor executor = VmDatabase.memory();
  if (!request.inMemory) {
    if (request.rootKey == null) throw Exception("Root key is not defined!");
    if (Platform.isIOS || Platform.isAndroid) {
      executor = LazyDatabase(() async {
        final dbFile = File(request.path!);
        return VmDatabase(dbFile, logStatements: true, setup: (rawDb) {
          rawDb.execute("PRAGMA key = '${Authentication.lastRootPublicKey}';");
        });
      });
    }
    if (Platform.isMacOS || Platform.isLinux) {
      final file = File('memri.sqlite');
      executor = VmDatabase(file);
    }
  }
  final moorIsolate = MoorIsolate.inCurrent(
    () => DatabaseConnection.fromExecutor(executor),
  );
  IsolateNameServer.registerPortWithName(moorIsolate.connectPort, Database.databasePortName);
  request.sendDriftIsolate.send(moorIsolate);
}

Future<SendPort> _createDriftIsolate(
    {bool logStatements = false, bool inMemory = false, required databaseName}) async {
  final receivePort = ReceivePort();
  String? path;
  if (!inMemory) {
    final dataDir = await paths.getApplicationDocumentsDirectory();
    path = p.join(dataDir.path + '/databases', databaseName + '.sqlite');
  }

  AppController.shared.databaseController.moorIsolate = await Isolate.spawn(
      _backgroundConnection,
      _IsolateStartRequest(
          sendDriftIsolate: receivePort.sendPort,
          rootKey: Authentication.lastRootPublicKey,
          inMemory: inMemory,
          path: path));
  return (await receivePort.first).connectPort as SendPort;
}

Database createDbConnection(
    {bool logStatements = false, bool inMemory = false, required databaseName}) {
  final dbPort = IsolateNameServer.lookupPortByName(Database.databasePortName);
  return Database.connect(DatabaseConnection.delayed(() async {
    return MoorIsolate.fromConnectPort(dbPort ??
            await _createDriftIsolate(
                logStatements: logStatements, inMemory: inMemory, databaseName: databaseName))
        .connect(isolateDebugLog: false);
  }()));
}

class _IsolateStartRequest {
  final SendPort sendDriftIsolate;
  final String? rootKey;
  final String? path;
  final bool inMemory;

  _IsolateStartRequest(
      {required this.sendDriftIsolate, this.rootKey, required this.path, required this.inMemory});
}
