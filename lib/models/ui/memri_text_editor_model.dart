import 'dart:ui';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:memri/constants/app_logger.dart';
import 'package:memri/constants/cvu/cvu_color.dart';

class MemriTextEditorModel {
  late Future<String?>? title;
  late Future<String> body;

  MemriTextEditorModel({required this.title, body}) : this.body = body ?? Future(() => "");

  MemriTextEditorModel.html(String html) {
    var splitted = MemriTextEditorModel.splitHTML(html);
    title = Future(() => splitted[0]);
    body = Future(() => splitted[1] ?? "");
  }

  Future<String> get html async {
    return await MemriTextEditorModel.combineHTML(title: title, body: body);
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
      AppLogger.err(e);
      return [null, string];
    }
  }

  static Future<String> combineHTML({Future<String?>? title, required Future<String> body}) async {
    try {
      var doc = parse(await body);
      Element titleElement = Element.tag("h1");

      titleElement.id = "title";
      titleElement.text = await title ?? "";
      return titleElement.outerHtml + (doc.body?.innerHtml ?? "");
    } catch (e) {
      AppLogger.err(e);
      return await body;
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
