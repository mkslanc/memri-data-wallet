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
CVUAction Function({Map? vars})? cvuAction(String named) {
  //TODO fix this when when Dart fixes passing constructors as callables https://github.com/dart-lang/language/issues/216
  switch (named.toLowerCase()) {
    case "openview":
      return ({Map? vars}) => CVUActionOpenView(vars: vars);
    case "back":
      return ({Map? vars}) => CVUActionNavigateBack(vars: vars);
    case "forward":
      return ({Map? vars}) => CVUActionNavigateBack(vars: vars);
    case "additem":
      return ({Map? vars}) => CVUActionAddItem(vars: vars);
    case "copytoclipboard":
      return ({Map? vars}) => CVUActionCopyToClipboard(vars: vars);
    case "toggleeditmode":
      return ({Map? vars}) => CVUActionToggleEditMode(vars: vars);
    case "togglefilterpanel":
      return ({Map? vars}) => CVUActionToggleFilterPanel(vars: vars);
    case "togglenavigation":
      return ({Map? vars}) => CVUActionToggleNavigation(vars: vars);
    case "togglefullscreen":
      return ({Map? vars}) => CVUActionToggleFullScreen(vars: vars);
    case "delete":
      return ({Map? vars}) => CVUActionDelete(vars: vars);
    case "selectall":
      return ({Map? vars}) => CVUActionSelectAll(vars: vars);
    case "deselectall":
      return ({Map? vars}) => CVUActionDeselectAll(vars: vars);
    default:
      return null;
  }
}

class CVUActionOpenView extends CVUAction {
  Map<String, CVUValue> vars;

  String? viewName;
  String? renderer;
  Set<int>? uids;
  DateTimeRange? dateRange;

  CVUActionOpenView({vars, this.viewName, this.renderer, this.uids, this.dateRange})
      : this.vars = vars ?? {};

  @override
  void execute(SceneController sceneController, CVUContext context) async {
    CVUDefinitionContent? viewDefinition;
    var view = vars["view"];
    if (view is CVUValueSubdefinition) {
      viewDefinition = view.value;
    }
    CVUViewArguments viewArguments;
    var viewArgs = vars["viewArguments"];
    if (viewArgs is CVUValueSubdefinition) {
      viewArguments = CVUViewArguments(
          args: viewArgs.value.properties,
          argumentItem: context.currentItem,
          parentArguments: context.viewArguments);
    } else {
      viewArguments = CVUViewArguments();
    }
    DatabaseController db = sceneController.appController.databaseController;
    var resolver = CVUPropertyResolver(
        context: context, lookup: CVULookupController(), db: db, properties: this.vars);
    sceneController.navigateToNewContext(
        viewName: viewName ?? await resolver.string("viewName") ?? "customView",
        inheritDatasource: (await resolver.boolean("inheritDatasource", true))!,
        overrideRenderer: renderer ?? await resolver.string("renderer"),
        defaultRenderer: "singleItem",
        targetItem: context.currentItem,
        overrideRowIDs: uids,
        dateRange: dateRange,
        customDefinition: viewDefinition,
        viewArguments: viewArguments);
  }
}

class CVUActionNavigateBack extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionNavigateBack({vars}) : this.vars = vars ?? {};

  @override
  execute(SceneController sceneController, CVUContext context) {
    // sceneController.navigateBack();
  }
}

class CVUActionCopyToClipboard extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionCopyToClipboard({vars}) : this.vars = vars ?? {};

  @override
  void execute(SceneController sceneController, CVUContext context) {
    // TODO: implement execute
  }
}

class CVUActionAddItem extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionAddItem({vars}) : this.vars = vars ?? {};

  @override
  void execute(SceneController sceneController, CVUContext context) {
    // TODO: implement execute
  }
}

class CVUActionToggleEditMode extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionToggleEditMode({vars}) : this.vars = vars ?? {};

  @override
  void execute(SceneController sceneController, CVUContext context) {
    // TODO: implement execute
  }
}

class CVUActionToggleFilterPanel extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionToggleFilterPanel({vars}) : this.vars = vars ?? {};

  @override
  void execute(SceneController sceneController, CVUContext context) {
    // TODO: implement execute
  }
}

class CVUActionToggleNavigation extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionToggleNavigation({vars}) : this.vars = vars ?? {};

  @override
  void execute(SceneController sceneController, CVUContext context) {
    // TODO: implement execute
  }
}

class CVUActionToggleFullScreen extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionToggleFullScreen({vars}) : this.vars = vars ?? {};

  @override
  void execute(SceneController sceneController, CVUContext context) {
    // TODO: implement execute
  }
}

class CVUActionDelete extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionDelete({vars}) : this.vars = vars ?? {};

  @override
  void execute(SceneController sceneController, CVUContext context) {
    // TODO: implement execute
  }
}

class CVUActionSelectAll extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionSelectAll({vars}) : this.vars = vars ?? {};

  @override
  void execute(SceneController sceneController, CVUContext context) {
    // TODO: implement execute
  }
}

class CVUActionDeselectAll extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionDeselectAll({vars}) : this.vars = vars ?? {};

  @override
  void execute(SceneController sceneController, CVUContext context) {
    // TODO: implement execute
  }
}
