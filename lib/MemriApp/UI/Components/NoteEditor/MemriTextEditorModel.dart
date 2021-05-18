import 'package:html/dom.dart';
import 'package:html/parser.dart';

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
      print(e);
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
      print(e);
      return await body;
    }
  }
}

/*
TODO
enum MemriTextEditorColor: String, CaseIterable {
    case `default` = "--text-color"
    case red = "--text-color-red"
    case orange = "--text-color-orange"
    case yellow = "--text-color-yellow"
    case green = "--text-color-green"
    case blue = "--text-color-blue"
    case purple = "--text-color-purple"
    case pink = "--text-color-pink"

    var cssVar: String {
        "var(\(rawValue))"
    }

    var swiftColor: Color? {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .orange: return .orange
        case .pink: return .pink
        case .purple: return .purple
        case .red: return .red
        case .yellow: return .yellow
        default: return nil
        }
    }
}
*/
