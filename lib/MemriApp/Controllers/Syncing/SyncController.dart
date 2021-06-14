//
//  SyncController.swift
//  MemriDatabase
//
//  Created by T Brennan on 1/12/20.
//

import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';

enum SyncState {
  create,
  update,
  noChanges,
  failed,
}

extension SyncStateExtension on SyncState {
  static SyncState rawValue(String value) =>
      SyncState.values.firstWhere((val) => val.inString == value);

  String get inString {
    return this.toString().split('.').last;
  }
}

class SyncController {
  final DatabaseController databaseController;

  SyncController(this.databaseController);
}
