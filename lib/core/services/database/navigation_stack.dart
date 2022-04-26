import 'dart:convert';
import 'dart:core';

import 'package:equatable/equatable.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/controllers/database_controller.dart';
import 'package:memri/models/database/database.dart';
import 'package:memri/models/view_context.dart';
import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class NavigationStack extends Equatable {
  late String sessionID;
  late String pageLabel;
  late List<ViewContextHolder> state;

  NavigationStack({sessionID, state, required this.pageLabel})
      : this.sessionID = sessionID ?? Uuid().v4(),
        this.state = state ?? [];

  NavigationStack.fromNavigationStateData(NavigationStateData stateData) {
    sessionID = stateData.sessionID;
    pageLabel = stateData.pageLabel;
    List jsonData = jsonDecode(Utf8Decoder().convert(stateData.state));
    state = jsonData.map((stateElement) => ViewContextHolder.fromJson(stateElement)).toList();
  }

  static Future<List<NavigationStack>> fetchAll([DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    List<NavigationStateData> navigationStateList = await db.databasePool.navigationStateFetchAll();
    return navigationStateList
        .map((navigationState) => NavigationStack.fromNavigationStateData(navigationState))
        .toList();
  }

  static Future<NavigationStack?> fetchOne(String pageLabel, [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    NavigationStateData? navigationState = await db.databasePool.navigationStateFetchOne(pageLabel);
    if (navigationState == null) {
      return null;
    }
    return NavigationStack.fromNavigationStateData(navigationState);
  }

  save([Database? db]) async {
    db ??= AppController.shared.databaseController.databasePool;
    await db.navigationStateSave(this);
  }

  delete([Database? db]) async {
    db ??= AppController.shared.databaseController.databasePool;
    await db.navigationStateDelete(this);
  }

  deleteAll([Database? db]) async {
    db ??= AppController.shared.databaseController.databasePool;
    await db.navigationStateClear();
  }

  NavigationStateCompanion toCompanion() {
    return NavigationStateCompanion(
      sessionID: Value(sessionID),
      pageLabel: Value(pageLabel),
      state: Value(Utf8Encoder().convert(jsonEncode(state))),
    );
  }

  @override
  List<Object> get props => [sessionID, state, pageLabel];
}
