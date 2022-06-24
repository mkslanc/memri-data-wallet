import 'package:flutter_test/flutter_test.dart';
import 'package:memri/core/cvu/parsing/cvu_expression_lexer.dart';
import 'package:memri/core/cvu/parsing/cvu_expression_parser.dart';
import 'package:memri/core/models/cvu/cvu_value_constant.dart';
import 'package:memri/core/models/cvu/cvu_value_expression.dart';
import 'package:memri/core/models/cvu/cvu_value_lookup_node.dart';

parse({snippet, stringMode = false}) {
  var lexer = CVUExpressionLexer(snippet, stringMode);
  var tokens = lexer.tokenize();
  var parser = CVUExpressionParser(tokens);
  return parser.parse();
}

void main() {
  test('testArithmeticOperators', () {
    var snippet = "(5 + 10 * 4 - 3 / 10) / 10";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(CVUExpressionNodeDivision(
            CVUExpressionNodeSubtraction(
                CVUExpressionNodeAddition(
                    CVUExpressionNodeConstant(CVUConstantNumber(5)),
                    CVUExpressionNodeMultiplication(
                        CVUExpressionNodeConstant(CVUConstantNumber(10)),
                        CVUExpressionNodeConstant(CVUConstantNumber(4)))),
                CVUExpressionNodeDivision(
                    CVUExpressionNodeConstant(CVUConstantNumber(3)),
                    CVUExpressionNodeConstant(CVUConstantNumber(10))),
                true),
            CVUExpressionNodeConstant(CVUConstantNumber(10)))));
  });

  test('testAnd', () {
    var snippet = "true and false";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(CVUExpressionNodeAnd(
            CVUExpressionNodeConstant(CVUConstantBool(true)),
            CVUExpressionNodeConstant(CVUConstantBool(false)))));
  });

  test('testOr', () {
    var snippet = "true or false";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(CVUExpressionNodeOr(
            CVUExpressionNodeConstant(CVUConstantBool(true)),
            CVUExpressionNodeConstant(CVUConstantBool(false)))));
  });

  test('testSimpleCondition', () {
    var snippet = "true ? 'yes' : 'no'";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(CVUExpressionNodeConditional(
            CVUExpressionNodeConstant(CVUConstantBool(true)),
            CVUExpressionNodeConstant(CVUConstantString("yes")),
            CVUExpressionNodeConstant(CVUConstantString("no")))));
  });

  test('testMultiCondition', () {
    var snippet =
        "true ? false and true ? -1 : false or true ? 'yes' : 'no' : -1";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(CVUExpressionNodeConditional(
            CVUExpressionNodeConstant(CVUConstantBool(true)),
            CVUExpressionNodeConditional(
                CVUExpressionNodeAnd(
                    CVUExpressionNodeConstant(CVUConstantBool(false)),
                    CVUExpressionNodeConstant(CVUConstantBool(true))),
                CVUExpressionNodeSubtraction(
                    CVUExpressionNodeConstant(CVUConstantNumber(0)),
                    CVUExpressionNodeConstant(CVUConstantNumber(1))),
                CVUExpressionNodeConditional(
                    CVUExpressionNodeOr(
                        CVUExpressionNodeConstant(CVUConstantBool(false)),
                        CVUExpressionNodeConstant(CVUConstantBool(true))),
                    CVUExpressionNodeConstant(CVUConstantString("yes")),
                    CVUExpressionNodeConstant(CVUConstantString("no")))),
            CVUExpressionNodeSubtraction(
                CVUExpressionNodeConstant(CVUConstantNumber(0)),
                CVUExpressionNodeConstant(CVUConstantNumber(1))))));
  });

  test('testConditionEquals', () {
    var snippet = "true = false";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(CVUExpressionNodeAreEqual(
            CVUExpressionNodeConstant(CVUConstantBool(true)),
            CVUExpressionNodeConstant(CVUConstantBool(false)))));
  });

  test('testConditionNotEquals', () {
    var snippet = "true != false";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(CVUExpressionNodeAreNotEqual(
            CVUExpressionNodeConstant(CVUConstantBool(true)),
            CVUExpressionNodeConstant(CVUConstantBool(false)))));
  });

  test('testConditionGreaterThan', () {
    var snippet = "5 > 10";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(CVUExpressionNodeGreaterThan(
            CVUExpressionNodeConstant(CVUConstantNumber(5)),
            CVUExpressionNodeConstant(CVUConstantNumber(10)))));
  });

  test('testConditionGreaterThanOrEqual', () {
    var snippet = "5 >= 10";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(CVUExpressionNodeGreaterThanOrEqual(
            CVUExpressionNodeConstant(CVUConstantNumber(5)),
            CVUExpressionNodeConstant(CVUConstantNumber(10)))));
  });

  test('testConditionLessThan', () {
    var snippet = "5 < 10";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(CVUExpressionNodeLessThan(
            CVUExpressionNodeConstant(CVUConstantNumber(5)),
            CVUExpressionNodeConstant(CVUConstantNumber(10)))));
  });

  test('testConditionLessThanOrEqual', () {
    var snippet = "5 <= 10";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(CVUExpressionNodeLessThanOrEqual(
            CVUExpressionNodeConstant(CVUConstantNumber(5)),
            CVUExpressionNodeConstant(CVUConstantNumber(10)))));
  });

  test('testDotLookup', () {
    var snippet = ".";
    var result = parse(snippet: snippet);
    expect(
        result, equals(CVUExpressionNodeLookup([CVULookupNode.defaultLookup])));
  });

  test('testMinusPlusModifier', () {
    var snippet = "-5 + -(5+10) - +'5'";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(CVUExpressionNodeSubtraction(
            CVUExpressionNodeAddition(
                CVUExpressionNodeSubtraction(
                    CVUExpressionNodeConstant(CVUConstantNumber(0.0)),
                    CVUExpressionNodeConstant(CVUConstantNumber(5.0))),
                CVUExpressionNodeSubtraction(
                    CVUExpressionNodeConstant(CVUConstantNumber(0.0)),
                    CVUExpressionNodeAddition(
                        CVUExpressionNodeConstant(CVUConstantNumber(5.0)),
                        CVUExpressionNodeConstant(CVUConstantNumber(10.0)),
                        true))),
            CVUExpressionNodeConstant(CVUConstantString("5")))));
  });

  test('testNegation', () {
    var snippet = "!true";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(CVUExpressionNodeNegation(
            CVUExpressionNodeConstant(CVUConstantBool(true)))));
  });

  test('testStringEscaping', () {
    var snippet = "'asdadsasd\\'asdasd'";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(
            CVUExpressionNodeConstant(CVUConstantString("asdadsasd'asdasd"))));
  });

  test('testTypeConversionToNumber', () {
    var snippet = "5 + '10.34' + true";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(CVUExpressionNodeAddition(
            CVUExpressionNodeAddition(
                CVUExpressionNodeConstant(CVUConstantNumber(5.0)),
                CVUExpressionNodeConstant(CVUConstantString("10.34"))),
            CVUExpressionNodeConstant(CVUConstantBool(true)))));
  });

  test('testTypeConversionToBool', () {
    var snippet = "0 ? -1 : 1 ? '' ? -1 : 'yes' : -1";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(CVUExpressionNodeConditional(
            CVUExpressionNodeConstant(CVUConstantNumber(0.0)),
            CVUExpressionNodeSubtraction(
                CVUExpressionNodeConstant(CVUConstantNumber(0.0)),
                CVUExpressionNodeConstant(CVUConstantNumber(1.0))),
            CVUExpressionNodeConditional(
                CVUExpressionNodeConstant(CVUConstantNumber(1.0)),
                CVUExpressionNodeConditional(
                    CVUExpressionNodeConstant(CVUConstantString("")),
                    CVUExpressionNodeSubtraction(
                        CVUExpressionNodeConstant(CVUConstantNumber(0.0)),
                        CVUExpressionNodeConstant(CVUConstantNumber(1.0))),
                    CVUExpressionNodeConstant(CVUConstantString("yes"))),
                CVUExpressionNodeSubtraction(
                    CVUExpressionNodeConstant(CVUConstantNumber(0.0)),
                    CVUExpressionNodeConstant(CVUConstantNumber(1.0)))))));
  });

  test('testSelfUsageInSubExpression', () {
    var snippet = ".relation[. = me].firstName";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(CVUExpressionNodeLookup([
          CVULookupNode.defaultLookup,
          CVULookupNode(
              name: "relation",
              isArray: true,
              type: CVULookupTypeLookup([
                CVUExpressionNodeAreEqual(
                    CVUExpressionNodeLookup([CVULookupNode.defaultLookup]),
                    CVUExpressionNodeLookup([
                      CVULookupNode(
                          name: "me",
                          isArray: false,
                          type: CVULookupTypeLookup())
                    ]))
              ])),
          CVULookupNode(
              name: "firstName", isArray: false, type: CVULookupTypeLookup())
        ])));
  });

  test('testLookupItem', () {
    var snippet = ".sibling";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(CVUExpressionNodeLookup([
          CVULookupNode.defaultLookup,
          CVULookupNode(
              name: "sibling", isArray: false, type: CVULookupTypeLookup())
        ])));
  });

  test('testLookupReverseEdgeItems', () {
    var snippet = ".~sibling";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(CVUExpressionNodeLookup([
          CVULookupNode.defaultLookup,
          CVULookupNode(
              name: "~sibling", isArray: false, type: CVULookupTypeLookup())
        ])));
  });

  test('testLookupEdges', () {
    var snippet = "._sibling";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(CVUExpressionNodeLookup([
          CVULookupNode.defaultLookup,
          CVULookupNode(
              name: "_sibling", isArray: false, type: CVULookupTypeLookup())
        ])));
  });

  test('testLookupReverseEdges', () {
    var snippet = "._~sibling[]";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(CVUExpressionNodeLookup([
          CVULookupNode.defaultLookup,
          CVULookupNode(
              name: "_~sibling", isArray: true, type: CVULookupTypeLookup())
        ])));
  });

  test('testStringModeStartWithString', () {
    var snippet = "Hello {fetchName()}!";
    var result = parse(snippet: snippet, stringMode: true);
    expect(
        result,
        equals(CVUExpressionNodeStringMode([
          CVUExpressionNodeConstant(CVUConstantString("Hello ")),
          CVUExpressionNodeLookup([
            CVULookupNode(
                name: "fetchName",
                isArray: false,
                type: CVULookupTypeFunction([]))
          ]),
          CVUExpressionNodeConstant(CVUConstantString("!"))
        ])));
  });

  test('testStringModeMultipleBlocks', () {
    var snippet = "Hello {.firstName} {.lastName}";
    var result = parse(snippet: snippet, stringMode: true);
    expect(
        result,
        equals(CVUExpressionNodeStringMode([
          CVUExpressionNodeConstant(CVUConstantString("Hello ")),
          CVUExpressionNodeLookup([
            CVULookupNode.defaultLookup,
            CVULookupNode(
                name: "firstName", isArray: false, type: CVULookupTypeLookup())
          ]),
          CVUExpressionNodeConstant(CVUConstantString(" ")),
          CVUExpressionNodeLookup([
            CVULookupNode.defaultLookup,
            CVULookupNode(
                name: "lastName", isArray: false, type: CVULookupTypeLookup())
          ])
        ])));
  });

  test('testStringModeUsingOr', () {
    var snippet = "{.title or \"test\"} — {.content.plainString()}";
    var result = parse(snippet: snippet, stringMode: true);
    expect(
        result,
        equals(CVUExpressionNodeStringMode([
          CVUExpressionNodeOr(
              CVUExpressionNodeLookup([
                CVULookupNode.defaultLookup,
                CVULookupNode(
                    name: "title", isArray: false, type: CVULookupTypeLookup())
              ]),
              CVUExpressionNodeConstant(CVUConstantString("test"))),
          CVUExpressionNodeConstant(CVUConstantString(" — ")),
          CVUExpressionNodeLookup([
            CVULookupNode.defaultLookup,
            CVULookupNode(
                name: "content", isArray: false, type: CVULookupTypeLookup()),
            CVULookupNode(
                name: "plainString",
                isArray: false,
                type: CVULookupTypeFunction([]))
          ])
        ])));
  });

  test('testStringModeStartWithExpression', () {
    var snippet = "{fetchName()} Hello";
    var result = parse(snippet: snippet, stringMode: true);
    expect(
        result,
        equals(CVUExpressionNodeStringMode([
          CVUExpressionNodeLookup([
            CVULookupNode(
                name: "fetchName",
                isArray: false,
                type: CVULookupTypeFunction([]))
          ]),
          CVUExpressionNodeConstant(CVUConstantString(" Hello"))
        ])));
  });

  test('testStringModeWithQuote', () {
    var snippet = "Photo AND ANY includes.uid = {.uid}";
    var result = parse(snippet: snippet, stringMode: true);
    expect(
        result,
        equals(CVUExpressionNodeStringMode([
          CVUExpressionNodeConstant(
              CVUConstantString("Photo AND ANY includes.uid = ")),
          CVUExpressionNodeLookup([
            CVULookupNode.defaultLookup,
            CVULookupNode(
                name: "uid", isArray: false, type: CVULookupTypeLookup())
          ])
        ])));
  });

  test('testExample', () {
    var snippet =
        """!(test + -5.63537) or 4/3 ? variable.func() : me.address[primary = true].country ? ((4+5 * 10) + test[10]) : 'asdads\\'asdad' + ''""";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(CVUExpressionNodeConditional(
            CVUExpressionNodeOr(
                CVUExpressionNodeNegation(CVUExpressionNodeAddition(
                    CVUExpressionNodeLookup([
                      CVULookupNode(
                          name: "test",
                          isArray: false,
                          type: CVULookupTypeLookup())
                    ]),
                    CVUExpressionNodeSubtraction(
                        CVUExpressionNodeConstant(CVUConstantNumber(0.0)),
                        CVUExpressionNodeConstant(CVUConstantNumber(5.63537))),
                    true)),
                CVUExpressionNodeDivision(
                    CVUExpressionNodeConstant(CVUConstantNumber(4.0)),
                    CVUExpressionNodeConstant(CVUConstantNumber(3.0)))),
            CVUExpressionNodeLookup([
              CVULookupNode(
                  name: "variable",
                  isArray: false,
                  type: CVULookupTypeLookup()),
              CVULookupNode(
                  name: "func", isArray: false, type: CVULookupTypeFunction([]))
            ]),
            CVUExpressionNodeConditional(
                CVUExpressionNodeLookup([
                  CVULookupNode(
                      name: "me", isArray: false, type: CVULookupTypeLookup()),
                  CVULookupNode(
                      name: "address",
                      isArray: true,
                      type: CVULookupTypeLookup([
                        CVUExpressionNodeAreEqual(
                            CVUExpressionNodeLookup([
                              CVULookupNode(
                                  name: "primary",
                                  isArray: false,
                                  type: CVULookupTypeLookup())
                            ]),
                            CVUExpressionNodeConstant(CVUConstantBool(true)))
                      ])),
                  CVULookupNode(
                      name: "country",
                      isArray: false,
                      type: CVULookupTypeLookup())
                ]),
                CVUExpressionNodeAddition(
                    CVUExpressionNodeAddition(
                        CVUExpressionNodeConstant(CVUConstantNumber(4.0)),
                        CVUExpressionNodeMultiplication(
                            CVUExpressionNodeConstant(CVUConstantNumber(5.0)),
                            CVUExpressionNodeConstant(CVUConstantNumber(10.0))),
                        true),
                    CVUExpressionNodeLookup([
                      CVULookupNode(
                          name: "test",
                          isArray: true,
                          type: CVULookupTypeLookup([
                            CVUExpressionNodeConstant(CVUConstantNumber(10.0))
                          ]))
                    ]),
                    true),
                CVUExpressionNodeAddition(
                    CVUExpressionNodeConstant(
                        CVUConstantString("asdads\'asdad")),
                    CVUExpressionNodeConstant(CVUConstantString("")))))));
  });

  test('testErrorIncompleteCondition', () {
    var snippet = "true ? 'yes'";

    expect(
        () => parse(snippet: snippet),
        throwsA(predicate(
            (e) => e is CVUExpressionParseErrorsExpectedConditionElse)));
  });

  test('testErrorIncompleteBinaryOp', () {
    var snippet = "5 +";

    expect(
        () => parse(snippet: snippet),
        throwsA(predicate((e) =>
            e is CVUExpressionParseErrorsExpectedExpression &&
            e.value is ExprTokenEOF)));
  });

  test('testErrorUnsupportedBinaryOp', () {
    var snippet = "5 @ 4";

    expect(
        () => parse(snippet: snippet),
        throwsA(predicate((e) =>
            e is CVUExpressionParseErrorsUnexpectedToken &&
            e.value is ExprTokenIdentifier &&
            (e.value as ExprTokenIdentifier).value == "@")));
  });

  test('testErrorMissingParenClose', () {
    var snippet = "(5 + 10";

    expect(
        () => parse(snippet: snippet),
        throwsA(predicate((e) =>
            e is CVUExpressionParseErrorsExpectedCharacter && e.value == ")")));
  });

  test('testErrorMissingBracketClose', () {
    var snippet = "test[10";

    expect(
        () => parse(snippet: snippet),
        throwsA(predicate((e) =>
            e is CVUExpressionParseErrorsExpectedCharacter && e.value == "]")));
  });

  test('testErrorMissingQuoteClose', () {
    var snippet = "'asdads";

    expect(
        () => parse(snippet: snippet),
        throwsA(
            predicate((e) => e is CVUExpressionParseErrorsMissingQuoteClose)));
  });

  test('testErrorUsingCurlyBracesNotInStringMode', () {
    var snippet = "Hello {fetchName()}";

    expect(
        () => parse(snippet: snippet),
        throwsA(predicate((e) =>
            e is CVUExpressionParseErrorsUnexpectedToken &&
            e.value is ExprTokenCurlyBracketOpen &&
            (e.value as ExprTokenCurlyBracketOpen).i == 6)));
  });

  test('testErrorUsingCurlyBracesInWrongContext', () {
    var snippet = "Hello {'{fetchName()}'}";

    expect(() => parse(snippet: snippet, stringMode: true),
        throwsA(predicate((e) {
      return e is CVUExpressionParseErrorsExpectedExpression &&
          e.value is ExprTokenCurlyBracketClose &&
          (e.value as ExprTokenCurlyBracketClose).i == 22;
    })));
  });
}
