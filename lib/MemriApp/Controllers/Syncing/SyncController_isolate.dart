import 'dart:isolate';

import 'package:memri/MemriApp/Controllers/API/PodAPIConnectionDetails.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:memri/MemriApp/Controllers/Database/Schema.dart';
import 'package:memri/MemriApp/Model/Database.dart';
import 'package:moor/isolate.dart';

import 'SyncController.dart';

class IsolateSyncConfig {
  final SendPort port;
  final PodAPIConnectionDetails connection;
  final Schema schema;
  final String? documentsDirectory;
  final String? rootKey;
  final DriftIsolate isolate;

  IsolateSyncConfig(
      {required this.port,
      required this.connection,
      required this.schema,
      this.documentsDirectory,
      this.rootKey,
      required this.isolate});
}

runSync(IsolateSyncConfig config) async {
  SyncController.documentsDirectory = config.documentsDirectory;
  SyncController.lastRootKey = config.rootKey;
  var dbController = DatabaseController();
  dbController.schema = config.schema;
  dbController.driftIsolate = config.isolate;
  dbController.databasePool = Database.connect(await config.isolate.connect());
  final syncController = SyncController(dbController);

  Stream.periodic(const Duration(milliseconds: 3000))
      .listen((_) => syncController.sync(connectionConfig: config.connection));
}
