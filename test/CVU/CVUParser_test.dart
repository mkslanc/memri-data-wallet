//
// CVUParserTests.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter_test/flutter_test.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/parsing/CVULexer.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUParseErrors.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUParser.dart';

List<CVUParsedDefinition> parse(String snippet) {
  CVULexer lexer = CVULexer(snippet);
  List<CVUToken> tokens = lexer.tokenize();
  CVUParser parser = CVUParser(tokens);
  List<CVUParsedDefinition> x = parser.parse();
  return x;
}

String toCVUString(List<CVUParsedDefinition> list) {
  return list.map(($0) => $0.toCVUString(0, "    ", true)).join("\n\n");
}

String parseToCVUString(String snippet) {
  var parsed = parse(snippet);
  return toCVUString(parsed);
}

void main() {
  test('testRendererDefinition', () {
    var snippet = """[renderer = generalEditor] {
    sequence: labels starred other dates
}""";
    expect(parseToCVUString(snippet), """[renderer = generalEditor] {
    sequence: labels starred other dates
}""");
  });

  test('testNamedViewDefinition', () {
    var snippet = """.defaultButtonsForItem {
    editActionButton: toggleEditMode
}""";
    expect(parseToCVUString(snippet), snippet);
  });

  test('testTypeViewDefinition', () {
    var snippet = """Person {
    title: "{.firstName}"
}""";
    expect(parseToCVUString(snippet), snippet);
  });

  test('testListViewDefinition', () {
    var snippet = """Person[] {
    title: "All People"
}""";
    expect(parseToCVUString(snippet), snippet);
  });

  test('testNestedObjects', () {
    var snippet = """Person {
    group {
        key: value
    }
}""";
    expect(parseToCVUString(snippet), """Person {
    group: {
        key: value
    }
}""");
  });

  test('testNestedObjectsUsingColon', () {
    var snippet = """Person: {
    group: {
        key: value
    }
}""";
    expect(parseToCVUString(snippet), """Person {
    group: {
        key: value
    }
}""");
  });

  test('testNestedObjectsWithKeysBefore', () {
    var snippet = """Person {
    key: 10
    group {
        key: value
    }
}""";
    expect(parseToCVUString(snippet), """Person {
    group: {
        key: value
    }
    key: 10
}""");
  });

  test('testEscapedStringProperty', () {
    var snippet = '''
[language = Dutch] {
    sharewith: "Deel \\"met..."
}''';

    expect(parseToCVUString(snippet), snippet);
  });

  test('testMixedQuoteTypeProperty', () {
    var snippet = """[language = Dutch] {
    addtolist: "Voeg 'toe' aan lijst..."
}""";
    expect(parseToCVUString(snippet), snippet);
  });

  test('testArrayStringProperty', () {
    var snippet = """Person {
    sequence: labels starred other dates
}""";
    expect(parseToCVUString(snippet), """Person {
    sequence: labels starred other dates
}""");
  });

  test('testArrayMixedProperty', () {
    var snippet = """Person {
    sequence: labels 5 "other" test
}""";
    expect(parseToCVUString(snippet), """Person {
    sequence: labels 5 "other" test
}""");
  });

  test('testArrayMultilineProperty', () {
    var snippet = """Person {
    sequence: [
        openViewByName { title: "{\$sharewith}" }
        toggleEditMode { title: "{\$addtolist}" }
        duplicate { title: "{\$duplicate} {type}" }
    ]

    key: value
}""";
    expect(parseToCVUString(snippet), """Person {
    key: value
    sequence: [
        openViewByName
        {
            title: "{\$sharewith}"
        }
        toggleEditMode
        {
            title: "{\$addtolist}"
        }
        duplicate
        {
            title: "{\$duplicate} {type}"
        }
    ]
}""");
  });

  test('testNestedRendererDefinition', () {
    var snippet = """Person {
    [renderer = timeline] {
        timeProperty: dateCreated
    }
}""";
    expect(parseToCVUString(snippet), """Person {
    [renderer = timeline] {
        timeProperty: dateCreated
    }
}""");
  });

  test('testNestedRendererDefinitionAfterProperty', () {
    var snippet = """Person {
    key: 10
    [renderer = timeline] {
        timeProperty: dateCreated
    }
}""";
    expect(parseToCVUString(snippet), """Person {
    key: 10

    [renderer = timeline] {
        timeProperty: dateCreated
    }
}""");
  });

  test('testStringExpressionProperty', () {
    var snippet = """Person {
    title: "{.firstName}"
}""";
    expect(parseToCVUString(snippet), snippet);
  });

  test('testExpressionProperty', () {
    var snippet = """Person {
    title: {{.firstName}}
}""";
    expect(parseToCVUString(snippet), snippet);
  });

  test('testStringProperty', () {
    var snippet = """Person { title: "hello" }""";
    expect(parseToCVUString(snippet), """Person {
    title: "hello"
}""");
  });

  test('testMultilineStringProperty', () {
    var snippet = """Person { title: "hello
                 world!" }""";
    expect(parseToCVUString(snippet), """Person {
    title: "hello
                 world!"
}""");
  });

  test('testNumberProperty', () {
    var snippet = """Person { title: -5.34 }""";
    expect(parseToCVUString(snippet), """Person {
    title: -5.34
}""");
  });

  test('testBoolProperty', () {
    var snippet = """Person { title: true }""";
    expect(parseToCVUString(snippet), """Person {
    title: true
}""");
  });

  test('testNilProperty', () {
    var snippet = """Person { title: nil }""";
    expect(parseToCVUString(snippet), """Person {
    title: nil
}""");
  });

  test('testIdentifierProperty', () {
    var snippet = """Person { defaultRenderer: grid }""";
    expect(parseToCVUString(snippet), """Person {
    defaultRenderer: grid
}""");
  });

  test('testColorProperty', () {
    var snippet = """Person { color: #f0f }""";
    expect(parseToCVUString(snippet), """Person {
    color: #f0f
}""");
  });

  test('testJSONCompatibility', () {
    var snippet = """"Person": {
    "string": "test",
    "array": ["10", 5],
    "object": { "test": 10 },
    "bool": false,
    "number": 10,
}""";
    // Notice the trailing comma, its there on purpose

    expect(parseToCVUString(snippet), """Person {
    array: "10" 5
    bool: false
    number: 10
    object: {
        test: 10
    }
    string: "test"
}""");
  });

  test('testSingleLineJSONSyntax', () {
    var snippet =
        """"Person": { "string": "test", "array": ["10", 5], "object": { "test": 10 }, "bool": false, "number": 10, }""";
    expect(parseToCVUString(snippet), """Person {
    array: "10" 5
    bool: false
    number: 10
    object: {
        test: 10
    }
    string: "test"
}""");
  });

  test('testCSSLikeSyntax', () {
    var snippet = """Person {
    background: #fff;
    border: 1 red;
    padding: 1 2 3 4;
}""";
    expect(parseToCVUString(snippet), """Person {
    background: #fff
    border: 1 red
    padding: 1 2 3 4
}""");
  });

  test('testSingleLineCSSLikeSyntax', () {
    var snippet = """Person { background: #fff; border: 1 red; padding: 1 2 3 4; }""";
    expect(parseToCVUString(snippet), """Person {
    background: #fff
    border: 1 red
    padding: 1 2 3 4
}""");
  });

  test('testSingleLineSyntax', () {
    var snippet =
        """Person { background: #fff, border: 1 red, padding: 1 2 3 4, object: { test: 1 } }""";
    expect(parseToCVUString(snippet), """Person {
    background: #fff
    border: 1 red
    object: {
        test: 1
    }
    padding: 1 2 3 4
}""");
  });

  test('testCurlyBracketsOnSeparateLine', () {
    var snippet = """Person
{
    background: #fff
    object:
        { test: 1 }
    bla:
    {
        test: 1
    }
}""";
    expect(parseToCVUString(snippet), """Person {
    background: #fff
    bla: {
        test: 1
    }
    object: {
        test: 1
    }
}""");
  });

  test('testComments', () {
    var snippet = """/* Hello */
Person {
    /* World */
    key: value
}""";
    expect(parseToCVUString(snippet), """Person {
    key: value
}""");
  });

  test('testUserState', () {
    var snippet = """Person {
    userState: {
        showStarred: true
    }
}""";
    var parsed = parse(snippet)[0];
    var string = toCVUString([parsed]);
    expect(string, snippet);
  });

  test('testEmptyArray', () {
    var snippet = """Person {
    userState: {
        selection: []
    }
}""";
    var parsed = parse(snippet)[0];
    expect(toCVUString([parsed]), snippet);
  });

  test('testCVUViewArguments', () {
    var snippet = """Person {
    viewArguments: {
        readOnly: true
    }
}""";

    var parsed = parse(snippet)[0];
    expect(toCVUString([parsed]), snippet);
  });

  test('testUIElementProperties', () {
    var snippet = """Person {
    VStack {
        alignment: left
        font: 14

        Text {
            alignment: top
            font: 12 light
            textAlign: center
        }

        Text {
            border: #ff0000 1
            cornerRadius: 10
            maxHeight: 500
        }
    }
}""";
    expect(parseToCVUString(snippet), snippet);
  });

  test('testUIElementWithoutProperties', () {
    var snippet = """Person {
    VStack {
        alignment: left
        Text { font: 12 light }
        Spacer
        Text { maxheight: 500 }
    }
}""";

    expect(parseToCVUString(snippet), """Person {
    VStack {
        alignment: left

        Text {
            font: 12 light
        }

        Spacer

        Text {
            maxheight: 500
        }
    }
}""");
  });

  // testSerialization

  test('testNestedViews', () {
    var snippet = """Person {
    [renderer = generalEditor] {
        picturesOfPerson: {
            title: "Photos of {.computedTitle()}"

            SubView {
                view: {
                    defaultRenderer: "thumbnail.grid"

                    [datasource = pod] {
                        query: "Photo AND ANY includes.uid = {.uid}"
                    }

                    [renderer = thumbnail.grid] {
                        columns: 5
                        itemInset: 0
                    }
                }
            }
        }
    }
}""";
    expect(parseToCVUString(snippet), snippet);
  });

  test('testActionStar', () {
    var snippet = """Person {
    [renderer = list] {
        onPress: star
    }
}""";
    expect(parseToCVUString(snippet), snippet);
  });

  test('testActionAddItem', () {
    var snippet = """Person {
    [renderer = list] {
        onPress: addItem {
            template: {
                name: {{.name}}
                _type: "ImporterRun"
            }
        }
    }
}""";
    expect(parseToCVUString(snippet), """Person {
    [renderer = list] {
        onPress: [
            addItem
            {
                template: {
                    _type: "ImporterRun"
                    name: {{.name}}
                }
            }
        ]
    }
}""");
  });

  test('testMultipleActions', () {
    var snippet = """Person {
    [renderer = list] {
        onPress: [
            link
            {
                dataItem: {{dataItem}}
                property: {{property}}
            }
            closePopup
        ]
    }
}""";
    expect(parseToCVUString(snippet), snippet);
  });

  test('testErrorMissingCurlBracketClose', () {
    var snippet = """Person {
    test: 1""";

    expect(
        () => parse(snippet),
        throwsA(predicate((e) =>
            e is CVUParseErrors && e is CVUParseErrorsUnexpectedToken && e.token is CVUTokenEOF)));
  });

  test('testErrorMissingBracketCloseInDefinition', () {
    var snippet = """[color = "test" {
    test: 1
}""";

    expect(
        () => parse(snippet),
        throwsA(predicate((e) =>
            e is CVUParseErrors &&
            e is CVUParseErrorsExpectedCharacter &&
            e.character == "]" &&
            e.token is CVUTokenCurlyBracketOpen &&
            e.token.ln == 0 &&
            e.token.ch == 16)));
  });

  //testErrorMissingBracketCloseInArray

  test('testErrorMissingExprCloseBracket', () {
    var snippet = """Person {
    expr: {{.test}
}""";

    expect(
        () => parse(snippet),
        throwsA(predicate((e) =>
            e is CVUParseErrors &&
            e is CVUParseErrorsMissingExpressionClose &&
            e.token is CVUTokenEOF)));
  });

  test('testErrorMissingExprCloseBrackets', () {
    var snippet = """Person {
    expr: {{.test
}""";

    expect(
        () => parse(snippet),
        throwsA(predicate((e) =>
            e is CVUParseErrors &&
            e is CVUParseErrorsMissingExpressionClose &&
            e.token is CVUTokenEOF)));
  });

  test('testErrorExtraBracket', () {
    var snippet = """Person {
    expr: [adasd, 5[]
}""";

    expect(
        () => parse(snippet),
        throwsA(predicate((e) =>
            e is CVUParseErrors &&
            e is CVUParseErrorsExpectedIdentifier &&
            e.token is CVUTokenBracketClose &&
            e.token.ln == 1 &&
            e.token.ch == 21)));
  });

  test('testErrorTopLevelBracket', () {
    var snippet = """[5,3,4,]""";

    expect(
        () => parse(snippet),
        throwsA(predicate((e) =>
            e is CVUParseErrors &&
            e is CVUParseErrorsExpectedIdentifier &&
            e.token is CVUTokenNumber &&
            (e.token as CVUTokenNumber).value == 5 &&
            e.token.ln == 0 &&
            e.token.ch == 1))); //TODO in swift there is 2, but doesn't seem correct
  });

  test('testErrorExtraCurlyBracket', () {
    var snippet = """Person {
    expr: [adasd, 5{]
}""";

    expect(
        () => parse(snippet),
        throwsA(predicate((e) =>
            e is CVUParseErrors &&
            e is CVUParseErrorsUnexpectedToken &&
            e.token is CVUTokenBracketClose &&
            e.token.ln == 1 &&
            e.token.ch == 21)));
  });

  test('testErrorExtraColonInArray', () {
    var snippet = """Person {
    expr: ["asdads": asdasd]
}""";

    expect(
        () => parse(snippet),
        throwsA(predicate((e) =>
            e is CVUParseErrors &&
            e is CVUParseErrorsExpectedKey &&
            e.token is CVUTokenColon &&
            e.token.ln == 1 &&
            e.token.ch == 20)));
  });

  test('testErrorExtraColonInProperty', () {
    var snippet = """Person {
    expr: asdads: asdasd
}""";

    expect(
        () => parse(snippet),
        throwsA(predicate((e) =>
            e is CVUParseErrors &&
            e is CVUParseErrorsExpectedKey &&
            e.token is CVUTokenColon &&
            e.token.ln == 1 &&
            e.token.ch == 17)));
  });

  test('testErrorMissingQuoteClose', () {
    var snippet = """Person {
    string: "value
}""";

    expect(
        () => parse(snippet),
        throwsA(predicate((e) =>
            e is CVUParseErrors &&
            e is CVUParseErrorsMissingQuoteClose &&
            e.token is CVUTokenEOF)));
  });

  //testErrorMultilineQuote

  test('testViewSpecificDefinition', () {
    var snippet = """.inbox {
    Note > list {
        Text {
            text: "TEST"
        }
    }
}""";
    expect(parseToCVUString(snippet), snippet);
  });
}
