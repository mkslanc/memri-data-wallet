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

class SyncController {
  final DatabaseController databaseController;

  SyncController(this.databaseController);
}
