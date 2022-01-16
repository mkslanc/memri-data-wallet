import 'package:flutter_test/flutter_test.dart';
import 'package:memri/MemriApp/CVU/CVUController.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/parsing/CVULexer.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUParseErrors.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUParser.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUValidator.dart';
import 'package:memri/MemriApp/CVU/resolving/CVULookupController.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';

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
      print((validator.errors + validator.warnings)
          .map((annotation) => annotation.message)
          .join("\n"));
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
