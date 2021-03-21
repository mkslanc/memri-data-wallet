//
//  CVUAction.swift
//  MemriDatabase
//
//  Created by T Brennan on 8/1/21.
//


import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/CVU/resolving/CVULookupController.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUPropertyResolver.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUViewArguments.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

abstract class CVUAction {
  void execute(SceneController sceneController, CVUContext context);
}

/// Used to look up the concrete type matching a CVU action name
CVUAction Function({Map? vars})? cvuAction(String named) {//TODO dart promised to fix passing constructor as callables https://github.com/dart-lang/language/issues/216
  switch (named.toLowerCase()) {
    case "openview":
      return ({Map? vars}) => CVUAction_OpenView(vars: vars);
    case "back":
      return ({Map? vars}) => CVUAction_NavigateBack(vars: vars);
    case "forward":
      return ({Map? vars}) => CVUAction_NavigateBack(vars: vars);
    case "additem":
      return ({Map? vars}) => CVUAction_AddItem(vars: vars);
    case "copytoclipboard":
      return ({Map? vars}) => CVUAction_CopyToClipboard(vars: vars);
    case "toggleeditmode":
      return ({Map? vars}) => CVUAction_ToggleEditMode(vars: vars);
    case "togglefilterpanel":
      return ({Map? vars}) => CVUAction_ToggleFilterPanel(vars: vars);
    case "togglenavigation":
      return ({Map? vars}) => CVUAction_ToggleNavigation(vars: vars);
    case "togglefullscreen":
      return ({Map? vars}) => CVUAction_ToggleFullScreen(vars: vars);
    case "delete":
      return ({Map? vars}) => CVUAction_Delete(vars: vars);
    case "selectall":
      return ({Map? vars}) => CVUAction_SelectAll(vars: vars);
    case "deselectall":
      return ({Map? vars}) => CVUAction_DeselectAll(vars: vars);
    default:
      return null;
  }
}

class CVUAction_OpenView extends CVUAction {
  Map<String, CVUValue> vars;

  String? viewName;
  String? renderer;
  List<String>? uids;
  DateTimeRange? dateRange;

  CVUAction_OpenView({
    vars,
    this.viewName,
    this.renderer,
    this.uids,
    this.dateRange
  }) : this.vars = vars ?? {};

  @override
  void execute(SceneController sceneController, CVUContext context) {
    CVUDefinitionContent? viewDefinition;
    if (vars["view"] != null && (vars["view"] as CVUValue).type == CVUValueType.subdefinition) {
      viewDefinition = (vars["view"] as CVUValue).value;
    }
    CVUViewArguments viewArguments;
    if (vars["viewArguments"] != null && (vars["viewArguments"] as CVUValue).type == CVUValueType.subdefinition) {
      viewArguments = CVUViewArguments(args: (vars["viewArguments"] as CVUValue).value.properties, argumentItem: context.currentItem, parentArguments: context.viewArguments);
    } else {
      viewArguments = CVUViewArguments();
    }
    DatabaseController db = DatabaseController();//TODO = sceneController.appController.databaseController;
    var resolver = CVUPropertyResolver(context: context, lookup: CVULookupController(), db: db, properties: this.vars);
    // sceneController.navigateToNewContext({
    // viewName: this.viewName ?? resolver.string("viewName") ?? "customView",
    // inheritDatasource: resolver.bool("inheritDatasource", true),
    // overrideRenderer: this.renderer ?? resolver.string("renderer"),
    // defaultRenderer: "singleItem",
    // targetItem: context.currentItem,
    // overrideUIDs: this.uids,
    // dateRange: this.dateRange, customDefinition: viewDefinition,
    // viewArguments: viewArguments
    // })
  }

}

class CVUAction_NavigateBack extends CVUAction {
  Map<String, CVUValue> vars;

  CVUAction_NavigateBack({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) {
    // sceneController.navigateBack();
  }

}

class CVUAction_CopyToClipboard extends CVUAction {
  Map<String, CVUValue> vars;

  CVUAction_CopyToClipboard({vars}) : this.vars = vars ?? {};

  @override
  void execute(SceneController sceneController, CVUContext context) {
    // TODO: implement execute
  }
}

class CVUAction_AddItem extends CVUAction {
  Map<String, CVUValue> vars;

  CVUAction_AddItem({vars}) : this.vars = vars ?? {};

  @override
  void execute(SceneController sceneController, CVUContext context) {
    // TODO: implement execute
  }

}


class CVUAction_ToggleEditMode extends CVUAction {
  Map<String, CVUValue> vars;

  CVUAction_ToggleEditMode({vars}) : this.vars = vars ?? {};

  @override
  void execute(SceneController sceneController, CVUContext context) {
    // TODO: implement execute
  }
}

class CVUAction_ToggleFilterPanel extends CVUAction {
  Map<String, CVUValue> vars;

  CVUAction_ToggleFilterPanel({vars}) : this.vars = vars ?? {};

  @override
  void execute(SceneController sceneController, CVUContext context) {
    // TODO: implement execute
  }
}


class CVUAction_ToggleNavigation extends CVUAction {
  Map<String, CVUValue> vars;

  CVUAction_ToggleNavigation({vars}) : this.vars = vars ?? {};

  @override
  void execute(SceneController sceneController, CVUContext context) {
    // TODO: implement execute
  }
}

class CVUAction_ToggleFullScreen extends CVUAction {
  Map<String, CVUValue> vars;

  CVUAction_ToggleFullScreen({vars}) : this.vars = vars ?? {};

  @override
  void execute(SceneController sceneController, CVUContext context) {
    // TODO: implement execute
  }
}

class CVUAction_Delete extends CVUAction {
  Map<String, CVUValue> vars;

  CVUAction_Delete({vars}) : this.vars = vars ?? {};

  @override
  void execute(SceneController sceneController, CVUContext context) {
    // TODO: implement execute
  }
}


class CVUAction_SelectAll extends CVUAction {
  Map<String, CVUValue> vars;

  CVUAction_SelectAll({vars}) : this.vars = vars ?? {};

  @override
  void execute(SceneController sceneController, CVUContext context) {
    // TODO: implement execute
  }
}

class CVUAction_DeselectAll extends CVUAction {
  Map<String, CVUValue> vars;

  CVUAction_DeselectAll({vars}) : this.vars = vars ?? {};

  @override
  void execute(SceneController sceneController, CVUContext context) {
    // TODO: implement execute
  }
}
