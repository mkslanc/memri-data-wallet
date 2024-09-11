//  Created by T Brennan on 8/1/21.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memri/constants/app_logger.dart';
import 'package:memri/cvu/controllers/cvu_lookup_controller.dart';
import 'package:memri/cvu/models/cvu_value.dart';
import 'package:memri/cvu/models/cvu_value_constant.dart';
import 'package:memri/cvu/services/resolving/cvu_context.dart';
import 'package:memri/cvu/services/resolving/cvu_property_resolver.dart';
import 'package:memri/providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../screens/cvu_screen.dart';
import '../controllers/view_context_controller.dart';
import '../models/cvu_parsed_definition.dart';
import '../models/cvu_view_arguments.dart';
import '../widgets/filter_panel/filter_panel_view.dart';

abstract class CVUAction {
  execute(CVUContext cvuContext, BuildContext context);

  Map<String, CVUValue> get defaultVars {
    return {};
  }

  late Map<String, CVUValue> vars;

  String? getString(String key, CVUContext cvuContext) {
    var resolver = CVUPropertyResolver(
        context: cvuContext,
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
    case "toggleeditmode":
      return ({Map? vars}) => CVUActionToggleEditMode(vars: vars);
    case "togglefilterpanel":
      return ({Map? vars}) => CVUActionToggleFilterPanel(vars: vars);
    case "star":
      return ({Map? vars}) => CVUActionStar(vars: vars);
    case "showstarred":
      return ({Map? vars}) => CVUActionShowStarred(vars: vars);
    default:
      return ({Map? vars}) => CVUActionNoop(vars: vars);
  }
}

class CVUActionOpenLink extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionOpenLink({vars}) : this.vars = vars ?? {};

  @override
  Future execute(CVUContext cvuContext, BuildContext context) async {
    var link = vars["link"];
    if (link != null) {
      var resolver =
          CVUPropertyResolver(context: cvuContext, lookup: CVULookupController(), properties: vars);
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
  execute(CVUContext cvuContext, BuildContext context) async {
    var resolver =
        CVUPropertyResolver(context: cvuContext, lookup: CVULookupController(), properties: vars);
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
  execute(CVUContext cvuContext, BuildContext context) async {
    var resolver =
        CVUPropertyResolver(context: cvuContext, lookup: CVULookupController(), properties: vars);

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
  execute(CVUContext cvuContext, BuildContext context) async {
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
  Future execute(CVUContext cvuContext, BuildContext context) async {
    var currentContext = Provider.of<AppProvider>(context, listen: false).currentViewContext;
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
          argumentItem: cvuContext.currentItem,
          parentArguments: cvuContext.viewArguments);
    } else {
      viewArguments = CVUViewArguments();
    }
    var resolver = CVUPropertyResolver(
        context: cvuContext, lookup: CVULookupController(), properties: this.vars);

    var route = MaterialPageRoute(
      builder: (context) => CVUScreen(
          viewContextController: ViewContextController.fromParams(
              viewName: viewName ?? resolver.string("viewName") ?? "customView",
              inheritDatasource: (resolver.boolean("inheritDatasource", true))!,
              overrideRenderer: renderer ?? resolver.string("renderer"),
              defaultRenderer: "generalEditor",
              focusedItem: cvuContext.currentItem,
              //overrideRowIDs: uids,
              //dateRange: dateRange,
              customDefinition: customDefinition,
              items: cvuContext.items,
              viewArguments: viewArguments,
              previousContext: currentContext
          )),
    );

    if (resolver.boolean("clearStack") ?? false) {
      Navigator.pushAndRemoveUntil(context, route, (Route<dynamic> route) => false);
    } else {
      Navigator.push(context, route);
    }
  }
}

class CVUActionNoop extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionNoop({vars}) : this.vars = vars ?? {};

  @override
  execute(CVUContext cvuContext, BuildContext context) {}
}

class CVUActionToggleFilterPanel extends CVUAction {
  Map<String, CVUValue> vars;

  Map<String, CVUValue> get defaultVars {
    return {"icon": CVUValueConstant(CVUConstantString("rhombus.fill"))};
  }

  CVUActionToggleFilterPanel({vars}) : this.vars = vars ?? {};

  @override
  execute(CVUContext cvuContext, BuildContext context) async {
    var appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.filterPanelIsVisible = true; //TODO set to false on modal close

    var viewContextController = appProvider.currentViewContext!;
    return showModalBottomSheet(
      constraints: BoxConstraints(minWidth: double.infinity),
      context: context,
      builder: (BuildContext context) {
        return FilterPanelView(viewContext: viewContextController);
      },
    );
  }
}

class CVUActionStar extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionStar({vars}) : this.vars = vars ?? {};

  @override
  Future execute(CVUContext cvuContext, BuildContext context) async {
    var currentItem = cvuContext.currentItem;
    if (currentItem == null) {
      return;
    }

    var prop = "starred";
    var currentVal = currentItem.get<bool>(prop) ?? false;
    currentItem.set<bool>(prop, !currentVal);
  }
}

class CVUActionShowStarred extends CVUAction {
  Map<String, CVUValue> vars;
  String icon = "star";

  Map<String, CVUValue> get defaultVars {
    return {"icon": CVUValueConstant(CVUConstantString(icon))};
  }

  CVUActionShowStarred({vars}) : this.vars = vars ?? {};

  @override
  execute(CVUContext cvuContext, BuildContext context) async {
    var currentContext = Provider.of<AppProvider>(context, listen: false).currentViewContext;
    if (currentContext == null) {
      print("shouldn't get here");
      return;
    }
    var query = currentContext.config.query;
    var property = "starred";
    if (query.existsPropertyCondition(property)) {
      query.removePropertyCondition(property);
      icon = "star";
    } else {
      query.addPropertyCondition("starred", true);
      icon = "star.fill";
    }
  }
}

class CVUActionToggleEditMode extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionToggleEditMode({vars}) : this.vars = vars ?? {};

  @override
  execute(CVUContext cvuContext, BuildContext context) async {
    Provider.of<AppProvider>(context, listen: false).toggleEditMode();
  }
}
