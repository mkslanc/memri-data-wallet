//  Created by T Brennan on 8/1/21.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memri/constants/app_logger.dart';
import 'package:memri/cvu/controllers/cvu_lookup_controller.dart';
import 'package:memri/cvu/models/cvu_value.dart';
import 'package:memri/cvu/models/cvu_value_constant.dart';
import 'package:memri/cvu/services/resolving/cvu_context.dart';
import 'package:memri/cvu/services/resolving/cvu_property_resolver.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../screens/cvu_screen.dart';
import '../controllers/view_context_controller.dart';
import '../models/cvu_parsed_definition.dart';
import '../models/cvu_view_arguments.dart';

abstract class CVUAction {
  execute(CVUContext context, BuildContext buildContext);

  Map<String, CVUValue> get defaultVars {
    return {};
  }

  late Map<String, CVUValue> vars;

  String? getString(String key, CVUContext context) {
    var resolver = CVUPropertyResolver(
        context: context,
        lookup: CVULookupController(),
        properties: vars[key] != null ? vars : defaultVars);
    return resolver.string(key);
  }
}

/// Used to look up the concrete type matching a CVU action name
CVUAction Function({Map<String, CVUValue>? vars})? cvuAction(String named) {
  //TODO fix this when when Dart fixes passing constructors as callables https://github.com/dart-lang/language/issues/216
  switch (named.toLowerCase()) {
    case "openlink":
      return ({Map? vars}) => CVUActionOpenLink(vars: vars);
    case "copytoclipboard":
      return ({Map? vars}) => CVUActionCopyToClipboard(vars: vars);
    case "openview":
      return ({Map? vars}) => CVUActionOpenView(vars: vars);
    case "validate":
      return ({Map? vars}) => CVUActionValidate(vars: vars);
    case "wait":
      return ({Map? vars}) => CVUActionWait(vars: vars);
    default:
      return null;
  }
}

class CVUActionOpenLink extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionOpenLink({vars}) : this.vars = vars ?? {};

  @override
  Future execute(CVUContext context, BuildContext buildContext) async {
    var link = vars["link"];
    if (link != null) {
      var resolver =
          CVUPropertyResolver(context: context, lookup: CVULookupController(), properties: vars);
      var url = resolver.string("link");
      if (url != null) {
        if (url.toLowerCase().contains('discord.com')) {
          // MixpanelAnalyticsService().logDiscordButton();
        } else if (url.toLowerCase().contains('gitlab.memri.io')) {
          // MixpanelAnalyticsService().logGitlabButton();
        }
        await canLaunchUrlString(url)
            ? await launchUrlString(url)
            : AppLogger.err('Could not launch $url');
      }
    }
  }
}

class CVUActionCopyToClipboard extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionCopyToClipboard({vars}) : this.vars = vars ?? {};

  @override
  execute(CVUContext context, BuildContext buildContext) async {
    var resolver =
        CVUPropertyResolver(context: context, lookup: CVULookupController(), properties: vars);
    var value = resolver.string("value");
    if (value != null) {
      Clipboard.setData(ClipboardData(text: value));
    }
  }
}

class CVUActionValidate extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionValidate({vars}) : this.vars = vars ?? {};

  @override
  execute(CVUContext context, BuildContext buildContext) async {
    var resolver =
        CVUPropertyResolver(context: context, lookup: CVULookupController(), properties: vars);

    var rules = resolver.subdefinitionArray("rules");

    for (var rule in rules) {
      var exp = (rule.boolean("expression", false, true))!;
      if (!exp) {
        var error = rule.string("error") ?? "Error on ${rule.properties["expression"].toString()}";
        throw error;
      }
    }
  }
}

class CVUActionWait extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionWait({vars}) : this.vars = vars ?? {};

  @override
  execute(CVUContext context, BuildContext buildContext) async {
    var seconds = vars["seconds"];

    if (seconds != null && seconds is CVUValueConstant && seconds.value is CVUConstantNumber) {
      await Future.delayed(Duration(seconds: (seconds.value.value as num).toInt()), () {});
    }
  }
}

class CVUActionOpenView extends CVUAction {
  Map<String, CVUValue> vars;

  String? viewName;
  String? renderer;
  Set<int>? uids;
  DateTimeRange? dateRange;
  CVUDefinitionContent? viewDefinition;

  CVUActionOpenView(
      {vars, this.viewName, this.renderer, this.uids, this.dateRange, this.viewDefinition})
      : this.vars = vars ?? {};

  @override
  Future execute(CVUContext context, BuildContext buildContext) async {
    var customDefinition = viewDefinition;
    if (customDefinition == null) {
      var view = vars["view"];
      if (view is CVUValueSubdefinition) {
        customDefinition = view.value;
      }
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
    var resolver =
        CVUPropertyResolver(context: context, lookup: CVULookupController(), properties: this.vars);

    var route = MaterialPageRoute(
      builder: (buildContext) => CVUScreen(
          viewContextController: ViewContextController.fromParams(
              viewName: viewName ?? resolver.string("viewName") ?? "customView",
              //inheritDatasource: (resolver.boolean("inheritDatasource", true))!,
              overrideRenderer: renderer ?? resolver.string("renderer"),
              defaultRenderer: "singleItem",
              focusedItem: context.currentItem,
              //overrideRowIDs: uids,
              //dateRange: dateRange,
              customDefinition: customDefinition,
              viewArguments: viewArguments)),
    );

    if (resolver.boolean("clearStack") ?? false) {
      Navigator.pushAndRemoveUntil(buildContext, route, (Route<dynamic> route) => false);
    } else {
      Navigator.push(buildContext, route);
    }
  }
}
