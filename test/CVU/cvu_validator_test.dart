import 'package:flutter_test/flutter_test.dart';
import 'package:memri/constants/app_logger.dart';
import 'package:memri/controllers/cvu_controller.dart';
import 'package:memri/controllers/cvu_lookup_controller.dart';
import 'package:memri/controllers/database_controller.dart';
import 'package:memri/core/cvu/parsing/cvu_parse_errors.dart';
import 'package:memri/core/cvu/parsing/cvu_parser.dart';
import 'package:memri/core/cvu/parsing/cvu_validator.dart';
import 'package:memri/models/cvu/cvu_lexer.dart';
import 'package:memri/models/cvu/cvu_parsed_definition.dart';

var databaseController = DatabaseController();
var lookupController = CVULookupController();
var validator =
    CVUValidator(databaseController: databaseController, lookupController: lookupController);

List<CVUParsedDefinition> parse(String snippet) {
  CVULexer lexer = CVULexer(snippet);
  List<CVUToken> tokens = lexer.tokenize();
  CVUParser parser = CVUParser(tokens);
  List<CVUParsedDefinition> x = parser.parse();
  return x;
}

validate(String snippet, {errors = 0, warnings = 0, CVUParseErrors? parseError}) async {
  try {
    var result = await validator.validate(parse(snippet));
    if (errors > 0 || warnings > 0) {
      expect(validator.errors.length, errors);
      expect(validator.warnings.length, warnings);
    } else {
      AppLogger.err(
          (validator.errors + validator.warnings)
              .map((annotation) => annotation.message)
              .join("\n"),
          sendCrashReport: false);
      expect(result, true);
    }
  } on CVUParseErrors catch (error) {
    expect(error, equals(parseError));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('testNamedViewDefinition', () async {
    var snippet = """.defaultButtonsForItem {
    actionButton: toggleEditMode
}""";

    await validate(snippet);
  });

  test('testDefaultCVUs', () async {
    var string = await CVUController.readCVUString();
    await validate(string);
  });

  test('testParseError', () async {
    var snippet = """Pl ugin > list {
    onPress: [
        openPlugin
        {
            plugin: {{.}}
        }
    ]
}""";

    await validate(snippet,
        parseError: CVUParseErrorsExpectedCharacter('{', CVUTokenIdentifier("ugin", 0, 3)));
  });
}
