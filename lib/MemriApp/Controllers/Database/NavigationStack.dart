import 'dart:convert';
import 'dart:core';

import 'package:equatable/equatable.dart';
import 'package:memri/MemriApp/Model/Database.dart';
import 'package:memri/MemriApp/UI/ViewContext.dart';
import 'package:moor/moor.dart';
import 'package:uuid/uuid.dart';

import '../AppController.dart';
import 'DatabaseController.dart';

// ignore: must_be_immutable
class NavigationStack extends Equatable {
  late String sessionID;
  late List<ViewContextHolder> state;

  NavigationStack({sessionID, state})
      : this.sessionID = sessionID ?? Uuid().v4(),
        this.state = state ?? [];

  NavigationStack.fromNavigationStateData(NavigationStateData stateData) {
    sessionID = stateData.sessionID;
    List jsonData = jsonDecode(Utf8Decoder().convert(stateData.state));
    state = jsonData.map((stateElement) => ViewContextHolder.fromJson(stateElement)).toList();
  }

  static Future<NavigationStack?> fetchOne([DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    NavigationStateData? navigationState = await db.databasePool.navigationStateFetchOne();
    if (navigationState == null) {
      return null;
    }
    return NavigationStack.fromNavigationStateData(navigationState);
  }

  save([Database? db]) async {
    db ??= AppController.shared.databaseController.databasePool;
    await db.navigationStateSave(this);
  }

  NavigationStateCompanion toCompanion() {
    return NavigationStateCompanion(
      sessionID: Value(sessionID),
      state: Value(Utf8Encoder().convert(jsonEncode(state))),
    );
  }

  @override
  List<Object> get props => [sessionID, state];
}
