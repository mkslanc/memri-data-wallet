//  Created by T Brennan on 8/1/21.

import 'package:flutter/services.dart';
import 'package:memri/constants/app_logger.dart';
import 'package:memri/cvu/controllers/cvu_lookup_controller.dart';
import 'package:memri/core/services/mixpanel_analytics_service.dart';
import 'package:memri/cvu/models/cvu_value.dart';
import 'package:memri/cvu/models/cvu_value_constant.dart';
import 'package:memri/cvu/services/resolving/cvu_context.dart';
import 'package:memri/cvu/services/resolving/cvu_property_resolver.dart';
import 'package:url_launcher/url_launcher_string.dart';

abstract class CVUAction {
  execute(CVUContext context);

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
  Future execute(CVUContext context) async {
    var link = vars["link"];
    if (link != null) {
      var resolver = CVUPropertyResolver(
          context: context, lookup: CVULookupController(), properties: vars);
      var url = resolver.string("link");
      if (url != null) {
        if (url.toLowerCase().contains('discord.com')) {
          MixpanelAnalyticsService().logDiscordButton();
        } else if (url.toLowerCase().contains('gitlab.memri.io')) {
          MixpanelAnalyticsService().logGitlabButton();
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
  execute(CVUContext context) async {
    var resolver = CVUPropertyResolver(
        context: context, lookup: CVULookupController(), properties: vars);
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
  execute(CVUContext context) async {
    var resolver = CVUPropertyResolver(
        context: context, lookup: CVULookupController(), properties: vars);

    var rules = resolver.subdefinitionArray("rules");

    for (var rule in rules) {
      var exp = (rule.boolean("expression", false, true))!;
      if (!exp) {
        var error = rule.string("error") ??
            "Error on ${rule.properties["expression"].toString()}";
        throw error;
      }
    }
  }
}

class CVUActionWait extends CVUAction {
  Map<String, CVUValue> vars;

  CVUActionWait({vars}) : this.vars = vars ?? {};

  @override
  execute(CVUContext context) async {
    var seconds = vars["seconds"];

    if (seconds != null &&
        seconds is CVUValueConstant &&
        seconds.value is CVUConstantNumber) {
      await Future.delayed(
          Duration(seconds: (seconds.value.value as num).toInt()), () {});
    }
  }
}
