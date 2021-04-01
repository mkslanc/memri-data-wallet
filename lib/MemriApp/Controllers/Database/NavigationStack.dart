import 'dart:core';

import 'package:equatable/equatable.dart';
import 'package:memri/MemriApp/Model/Database.dart';
import 'package:memri/MemriApp/UI/ViewContext.dart';
import 'package:uuid/uuid.dart';

import '../AppController.dart';
import 'DatabaseController.dart';

// ignore: must_be_immutable
class NavigationStack extends Equatable {
  String sessionID;
  List<ViewContextHolder> state;

  NavigationStack({sessionID, state})
      : this.sessionID = sessionID ?? Uuid().v4(),
        this.state = state ?? [];

  NavigationStack.fromNavigationStateData(NavigationStateData stateData)
      : sessionID = stateData.sessionID,
        state = stateData.state as List<ViewContextHolder>;

  static Future<NavigationStack?> fetchOne([DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    NavigationStateData? navigationState = await db.databasePool.navigationStateFetchOne();
    if (navigationState == null) {
      return null;
    }
    return NavigationStack.fromNavigationStateData(navigationState);
  }

  @override
  List<Object> get props => [sessionID];
}
