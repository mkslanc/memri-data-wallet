import 'dart:ui';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

import '../../../cvu/constants/cvu_color.dart';

class MemriTextEditorModel {
  late String? title;
  late String body;

  MemriTextEditorModel({required this.title, body}) : this.body = body ?? "";

  MemriTextEditorModel.html(String html) {
    var splitted = MemriTextEditorModel.splitHTML(html);
    title = splitted[0];
    body = splitted[1] ?? "";
  }

  String get html {
    return MemriTextEditorModel.combineHTML(title: title, body: body);
  }

  static List<String?> splitHTML(String string) {
    try {
      var doc = parse(string);
      var titleElement = doc.body?.children
          .firstWhere((element) => element.localName == "h1" && element.id == "title");
      var title = titleElement?.innerHtml;
      titleElement?.remove();
      var body = doc.body?.innerHtml ?? "";
      return [title, body];
    } catch (e) {
      print(e);
      return [null, string];
    }
  }

  static String combineHTML({String? title, required String body}) {
    try {
      var doc = parse(body);
      Element titleElement = Element.tag("h1");

      titleElement.id = "title";
      titleElement.text = title ?? "";
      return titleElement.outerHtml + (doc.body?.innerHtml ?? "");
    } catch (e) {
      print(e);
      return body;
    }
  }
}

enum MemriTextEditorColor { red, orange, yellow, green, blue, purple, pink }

extension MemriTextEditorColorExtension on MemriTextEditorColor {
  static Map<MemriTextEditorColor, String> color = {
    MemriTextEditorColor.red: "--text-color-red",
    MemriTextEditorColor.orange: "--text-color-orange",
    MemriTextEditorColor.yellow: "--text-color-yellow",
    MemriTextEditorColor.green: "--text-color-green",
    MemriTextEditorColor.blue: "--text-color-blue",
    MemriTextEditorColor.purple: "--text-color-purple",
    MemriTextEditorColor.pink: "--text-color-pink"
  };

  get cssVar => "var(${MemriTextEditorColorExtension.color[this]})";

  Color? get dartColor {
    switch (this) {
      case MemriTextEditorColor.red:
        return CVUColor.system("red");
      case MemriTextEditorColor.orange:
        return CVUColor.system("orange");
      case MemriTextEditorColor.yellow:
        return CVUColor.system("yellow");
      case MemriTextEditorColor.green:
        return CVUColor.system("green");
      case MemriTextEditorColor.blue:
        return CVUColor.system("blue");
      case MemriTextEditorColor.purple:
        return CVUColor.system("purple");
      case MemriTextEditorColor.pink:
        return CVUColor.system("pink");
    }
  }
}
