import 'dart:isolate';

import 'package:memri/controllers/database_controller.dart';
import 'package:memri/core/apis/pod/pod_connection_details.dart';
import 'package:memri/core/services/database/schema.dart';
import 'package:memri/models/database/database.dart';
import 'package:moor/isolate.dart';

import 'sync_controller.dart';

class IsolateSyncConfig {
  final SendPort port;
  final PodConnectionDetails connection;
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
