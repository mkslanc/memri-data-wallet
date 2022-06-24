import 'package:flutter_test/flutter_test.dart';
import 'package:memri/core/controllers/cvu_lookup_controller.dart';
import 'package:memri/core/controllers/database_controller.dart';
import 'package:memri/core/cvu/parsing/cvu_expression_lexer.dart';
import 'package:memri/core/cvu/parsing/cvu_expression_parser.dart';
import 'package:memri/core/cvu/resolving/cvu_context.dart';
import 'package:memri/core/models/cvu/cvu_value.dart';
import 'package:memri/core/models/cvu/cvu_value_expression.dart';
import 'package:memri/core/models/database/item_record.dart';
import 'package:moor/moor.dart';

CVUExpressionNode parse(String snippet, [bool stringMode = false]) {
  var lexer = CVUExpressionLexer(snippet, stringMode);
  var tokens = lexer.tokenize();
  var parser = CVUExpressionParser(tokens);
  return parser.parse();
}

var lookupController = CVULookupController();

Future<bool?> interpretAsBool(
    CVUExpressionNode expr, DatabaseController databaseController,
    [CVUContext? context]) async {
  context ??= CVUContext();
  return await lookupController.resolve<bool>(
      value: CVUValueExpression(expr),
      context: context,
      db: databaseController);
}

Future<double?> interpretAsDouble(
    CVUExpressionNode expr, DatabaseController databaseController,
    [CVUContext? context]) async {
  context ??= CVUContext();
  return await lookupController.resolve<double>(
      value: CVUValueExpression(expr),
      context: context,
      db: databaseController);
}

Future<String?> interpretAsString(
    CVUExpressionNode expr, DatabaseController databaseController,
    [CVUContext? context]) async {
  context ??= CVUContext();
  return await lookupController.resolve<String>(
      value: CVUValueExpression(expr),
      context: context,
      db: databaseController);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DatabaseController databaseController;

  setUp(() async {
    databaseController = DatabaseController(inMemory: true);
    await databaseController.init();
    await databaseController.importRequiredData(throwIfAgainstSchema: true);
    await databaseController.setupWithDemoData(throwIfAgainstSchema: true);
  });

  test('testStringModeStartWithString', () async {
    var snippet = "Note title: {.title}";

    var expr = parse(snippet, true);
    var note = (await databaseController.databasePool
            .itemRecordsCustomSelect("type = ?", [Variable.withString("Note")]))
        .asMap()[0];
    if (note != null) {
      var noteRecord = ItemRecord.fromItem(note);
      var noteString =
          (await noteRecord.propertyValue("title", databaseController))
              ?.asString();
      var context = CVUContext(currentItem: noteRecord);
      var result = await interpretAsString(expr, databaseController, context);

      expect(result, "Note title: $noteString");
    } else {
      throw ("No item");
    }
  });

  test('testStringModeStartWithStringTwo', () async {
    var snippet = "Filename: {.file.filename}";

    var expr = parse(snippet, true);
    var note = (await databaseController.databasePool
            .itemRecordsCustomSelect("type = ?", [Variable.withString("Note")]))
        .asMap()[1];
    if (note != null) {
      var noteRecord = ItemRecord.fromItem(note);
      var context = CVUContext(currentItem: noteRecord);
      var result = await interpretAsString(expr, databaseController, context);

      expect(result, "Filename: unsplash-image2");
    } else {
      throw ("No item");
    }
  });
}
