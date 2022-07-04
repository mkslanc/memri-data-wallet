import 'dart:isolate';

import 'package:memri/core/models/pod/pod_config.dart';
import 'package:memri/core/services/database/schema.dart';
import 'package:moor/isolate.dart';

class SyncConfig {
  final PodConfig connection;
  final Schema schema;

  SyncConfig({required this.connection, required this.schema});
}

class IsolateSyncConfig extends SyncConfig {
  final SendPort port;
  final PodConfig connection;
  final Schema schema;
  final String? documentsDirectory;
  final String? rootKey;
  final DriftIsolate isolate;

  IsolateSyncConfig({
    required this.port,
    required this.connection,
    required this.isolate,
    required this.schema,
    this.documentsDirectory,
    this.rootKey,
  }) : super(connection: connection, schema: schema);
}
