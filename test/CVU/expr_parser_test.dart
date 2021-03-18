import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUExpressionLexer.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUExpressionParser.dart';
import 'package:test/test.dart';

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
        equals(ExpressionNode.division(
            ExpressionNode.subtraction(
                ExpressionNode.addition(
                    ExpressionNode.constant(CVUValue_Constant.number(5)),
                    ExpressionNode.multiplication(
                        ExpressionNode.constant(CVUValue_Constant.number(10)),
                        ExpressionNode.constant(CVUValue_Constant.number(4)))),
                ExpressionNode.division(ExpressionNode.constant(CVUValue_Constant.number(3)),
                    ExpressionNode.constant(CVUValue_Constant.number(10)))),
            ExpressionNode.constant(CVUValue_Constant.number(10)))));
  });

  test('testAnd', () {
    var snippet = "true and false";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(ExpressionNode.and(ExpressionNode.constant(CVUValue_Constant.bool(true)),
            ExpressionNode.constant(CVUValue_Constant.bool(false)))));
  });

  test('testOr', () {
    var snippet = "true or false";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(ExpressionNode.or(ExpressionNode.constant(CVUValue_Constant.bool(true)),
            ExpressionNode.constant(CVUValue_Constant.bool(false)))));
  });

  test('testSimpleCondition', () {
    var snippet = "true ? 'yes' : 'no'";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(ExpressionNode.conditional(
            ExpressionNode.constant(CVUValue_Constant.bool(true)),
            ExpressionNode.constant(CVUValue_Constant.string("yes")),
            ExpressionNode.constant(CVUValue_Constant.string("no")))));
  });

  test('testMultiCondition', () {
    var snippet = "true ? false and true ? -1 : false or true ? 'yes' : 'no' : -1";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(ExpressionNode.conditional(
            ExpressionNode.constant(CVUValue_Constant.bool(true)),
            ExpressionNode.conditional(
                ExpressionNode.and(ExpressionNode.constant(CVUValue_Constant.bool(false)),
                    ExpressionNode.constant(CVUValue_Constant.bool(true))),
                ExpressionNode.subtraction(ExpressionNode.constant(CVUValue_Constant.number(0)),
                    ExpressionNode.constant(CVUValue_Constant.number(1))),
                ExpressionNode.conditional(
                    ExpressionNode.or(ExpressionNode.constant(CVUValue_Constant.bool(false)),
                        ExpressionNode.constant(CVUValue_Constant.bool(true))),
                    ExpressionNode.constant(CVUValue_Constant.string("yes")),
                    ExpressionNode.constant(CVUValue_Constant.string("no")))),
            ExpressionNode.subtraction(ExpressionNode.constant(CVUValue_Constant.number(0)),
                ExpressionNode.constant(CVUValue_Constant.number(1))))));
  });

  test('testConditionEquals', () {
    var snippet = "true = false";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(ExpressionNode.areEqual(ExpressionNode.constant(CVUValue_Constant.bool(true)),
            ExpressionNode.constant(CVUValue_Constant.bool(false)))));
  });

  test('testConditionNotEquals', () {
    var snippet = "true != false";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(ExpressionNode.areNotEqual(ExpressionNode.constant(CVUValue_Constant.bool(true)),
            ExpressionNode.constant(CVUValue_Constant.bool(false)))));
  });

  test('testConditionGreaterThan', () {
    var snippet = "5 > 10";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(ExpressionNode.greaterThan(ExpressionNode.constant(CVUValue_Constant.number(5)),
            ExpressionNode.constant(CVUValue_Constant.number(10)))));
  });

  test('testConditionGreaterThanOrEqual', () {
    var snippet = "5 >= 10";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(ExpressionNode.greaterThanOrEqual(
            ExpressionNode.constant(CVUValue_Constant.number(5)),
            ExpressionNode.constant(CVUValue_Constant.number(10)))));
  });

  test('testConditionLessThan', () {
    var snippet = "5 < 10";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(ExpressionNode.lessThan(ExpressionNode.constant(CVUValue_Constant.number(5)),
            ExpressionNode.constant(CVUValue_Constant.number(10)))));
  });

  test('testConditionLessThanOrEqual', () {
    var snippet = "5 <= 10";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(ExpressionNode.lessThanOrEqual(ExpressionNode.constant(CVUValue_Constant.number(5)),
            ExpressionNode.constant(CVUValue_Constant.number(10)))));
  });

  test('testLookup', () {
    var snippet = ".bar and bar.foo(10) and bar[foo = 10] or shouldNeverGetHere";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(ExpressionNode.and(
            ExpressionNode.and(
                ExpressionNode.lookup([
                  LookupNode.defaultLookup,
                  LookupNode(name: "bar", isArray: false, type: LookupType.lookup())
                ]),
                ExpressionNode.lookup([
                  LookupNode(name: "bar", isArray: false, type: LookupType.lookup()),
                  LookupNode(
                      name: "foo",
                      isArray: false,
                      type: LookupType.function(
                          [ExpressionNode.constant(CVUValue_Constant.number(10.0))]))
                ])),
            ExpressionNode.or(
                ExpressionNode.lookup([
                  LookupNode(
                      name: "bar",
                      isArray: false,
                      type: LookupType.lookup(ExpressionNode.areEqual(
                          ExpressionNode.lookup(
                              [LookupNode(name: "foo", isArray: false, type: LookupType.lookup())]),
                          ExpressionNode.constant(CVUValue_Constant.number(10.0)))))
                ]),
                ExpressionNode.lookup([
                  LookupNode(name: "shouldNeverGetHere", isArray: false, type: LookupType.lookup())
                ])))));
  });

  test('testDotLookup', () {
    var snippet = ".";
    var result = parse(snippet: snippet);
    expect(result, equals(ExpressionNode.lookup([LookupNode.defaultLookup])));
  });

  test('testMinusPlusModifier', () {
    var snippet = "-5 + -(5+10) - +'5'";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(ExpressionNode.subtraction(
            ExpressionNode.addition(
                ExpressionNode.subtraction(ExpressionNode.constant(CVUValue_Constant.number(0.0)),
                    ExpressionNode.constant(CVUValue_Constant.number(5.0))),
                ExpressionNode.subtraction(
                    ExpressionNode.constant(CVUValue_Constant.number(0.0)),
                    ExpressionNode.addition(ExpressionNode.constant(CVUValue_Constant.number(5.0)),
                        ExpressionNode.constant(CVUValue_Constant.number(10.0))))),
            ExpressionNode.constant(CVUValue_Constant.string("5")))));
  });

  test('testNegation', () {
    var snippet = "!true";
    var result = parse(snippet: snippet);
    expect(result,
        equals(ExpressionNode.negation(ExpressionNode.constant(CVUValue_Constant.bool(true)))));
  });

  test('testStringEscaping', () {
    var snippet = "'asdadsasd\\'asdasd'";
    var result = parse(snippet: snippet);
    expect(result, equals(ExpressionNode.constant(CVUValue_Constant.string("asdadsasd'asdasd"))));
  });

  test('testTypeConversionToNumber', () {
    var snippet = "5 + '10.34' + true";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(ExpressionNode.addition(
            ExpressionNode.addition(ExpressionNode.constant(CVUValue_Constant.number(5.0)),
                ExpressionNode.constant(CVUValue_Constant.string("10.34"))),
            ExpressionNode.constant(CVUValue_Constant.bool(true)))));
  });

  test('testTypeConversionToBool', () {
    var snippet = "0 ? -1 : 1 ? '' ? -1 : 'yes' : -1";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(ExpressionNode.conditional(
            ExpressionNode.constant(CVUValue_Constant.number(0.0)),
            ExpressionNode.subtraction(ExpressionNode.constant(CVUValue_Constant.number(0.0)),
                ExpressionNode.constant(CVUValue_Constant.number(1.0))),
            ExpressionNode.conditional(
                ExpressionNode.constant(CVUValue_Constant.number(1.0)),
                ExpressionNode.conditional(
                    ExpressionNode.constant(CVUValue_Constant.string("")),
                    ExpressionNode.subtraction(
                        ExpressionNode.constant(CVUValue_Constant.number(0.0)),
                        ExpressionNode.constant(CVUValue_Constant.number(1.0))),
                    ExpressionNode.constant(CVUValue_Constant.string("yes"))),
                ExpressionNode.subtraction(ExpressionNode.constant(CVUValue_Constant.number(0.0)),
                    ExpressionNode.constant(CVUValue_Constant.number(1.0)))))));
  });

  test('testSelfUsageInSubExpression', () {
    var snippet = ".relation[. = me].firstName";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(ExpressionNode.lookup([
          LookupNode.defaultLookup,
          LookupNode(
              name: "relation",
              isArray: false,
              type: LookupType.lookup(ExpressionNode.areEqual(
                  ExpressionNode.lookup([LookupNode.defaultLookup]),
                  ExpressionNode.lookup(
                      [LookupNode(name: "me", isArray: false, type: LookupType.lookup())])))),
          LookupNode(name: "firstName", isArray: false, type: LookupType.lookup())
        ])));
  });

  test('testLookupItem', () {
    var snippet = ".sibling";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(ExpressionNode.lookup([
          LookupNode.defaultLookup,
          LookupNode(name: "sibling", isArray: false, type: LookupType.lookup())
        ])));
  });

  test('testLookupReverseEdgeItems', () {
    var snippet = ".~sibling";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(ExpressionNode.lookup([
          LookupNode.defaultLookup,
          LookupNode(name: "~sibling", isArray: false, type: LookupType.lookup())
        ])));
  });

  test('testLookupEdges', () {
    var snippet = "._sibling";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(ExpressionNode.lookup([
          LookupNode.defaultLookup,
          LookupNode(name: "_sibling", isArray: false, type: LookupType.lookup())
        ])));
  });

  test('testLookupReverseEdges', () {
    var snippet = "._~sibling[]";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(ExpressionNode.lookup([
          LookupNode.defaultLookup,
          LookupNode(name: "_~sibling", isArray: true, type: LookupType.lookup())
        ])));
  });

  test('testStringModeStartWithString', () {
    var snippet = "Hello {fetchName()}!";
    var result = parse(snippet: snippet, stringMode: true);
    expect(
        result,
        equals(ExpressionNode.stringMode([
          ExpressionNode.constant(CVUValue_Constant.string("Hello ")),
          ExpressionNode.lookup(
              [LookupNode(name: "fetchName", isArray: false, type: LookupType.function([]))]),
          ExpressionNode.constant(CVUValue_Constant.string("!"))
        ])));
  });

  test('testStringModeMultipleBlocks', () {
    var snippet = "Hello {.firstName} {.lastName}";
    var result = parse(snippet: snippet, stringMode: true);
    expect(
        result,
        equals(ExpressionNode.stringMode([
          ExpressionNode.constant(CVUValue_Constant.string("Hello ")),
          ExpressionNode.lookup([
            LookupNode.defaultLookup,
            LookupNode(name: "firstName", isArray: false, type: LookupType.lookup())
          ]),
          ExpressionNode.constant(CVUValue_Constant.string(" ")),
          ExpressionNode.lookup([
            LookupNode.defaultLookup,
            LookupNode(name: "lastName", isArray: false, type: LookupType.lookup())
          ])
        ])));
  });

  test('testStringModeUsingOr', () {
    var snippet = "{.title or \"test\"} — {.content.plainString()}";
    var result = parse(snippet: snippet, stringMode: true);
    expect(
        result,
        equals(ExpressionNode.stringMode([
          ExpressionNode.or(
              ExpressionNode.lookup([
                LookupNode.defaultLookup,
                LookupNode(name: "title", isArray: false, type: LookupType.lookup())
              ]),
              ExpressionNode.constant(CVUValue_Constant.string("test"))),
          ExpressionNode.constant(CVUValue_Constant.string(" — ")),
          ExpressionNode.lookup([
            LookupNode.defaultLookup,
            LookupNode(name: "content", isArray: false, type: LookupType.lookup()),
            LookupNode(name: "plainString", isArray: false, type: LookupType.function([]))
          ])
        ])));
  });

  test('testStringModeStartWithExpression', () {
    var snippet = "{fetchName()} Hello";
    var result = parse(snippet: snippet, stringMode: true);
    expect(
        result,
        equals(ExpressionNode.stringMode([
          ExpressionNode.lookup(
              [LookupNode(name: "fetchName", isArray: false, type: LookupType.function([]))]),
          ExpressionNode.constant(CVUValue_Constant.string(" Hello"))
        ])));
  });

  test('testStringModeWithQuote', () {
    var snippet = "Photo AND ANY includes.uid = {.uid}";
    var result = parse(snippet: snippet, stringMode: true);
    expect(
        result,
        equals(ExpressionNode.stringMode([
          ExpressionNode.constant(CVUValue_Constant.string("Photo AND ANY includes.uid = ")),
          ExpressionNode.lookup([
            LookupNode.defaultLookup,
            LookupNode(name: "uid", isArray: false, type: LookupType.lookup())
          ])
        ])));
  });

  test('testExample', () {
    var snippet = """!(test + -5.63537) or 4/3 ? variable.func() : me.address[primary = true].country ? ((4+5 * 10) + test[10]) : 'asdads\\'asdad' + ''""";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(ExpressionNode.conditional(
            ExpressionNode.or(
                ExpressionNode.negation(ExpressionNode.addition(
                    ExpressionNode.lookup(
                        [LookupNode(name: "test", isArray: false, type: LookupType.lookup())]),
                    ExpressionNode.subtraction(
                        ExpressionNode.constant(CVUValue_Constant.number(0.0)),
                        ExpressionNode.constant(CVUValue_Constant.number(5.63537))))),
                ExpressionNode.division(ExpressionNode.constant(CVUValue_Constant.number(4.0)),
                    ExpressionNode.constant(CVUValue_Constant.number(3.0)))),
            ExpressionNode.lookup([
              LookupNode(name: "variable", isArray: false, type: LookupType.lookup()),
              LookupNode(name: "func", isArray: false, type: LookupType.function([]))
            ]),
            ExpressionNode.conditional(
                ExpressionNode.lookup([
                  LookupNode(name: "me", isArray: false, type: LookupType.lookup()),
                  LookupNode(
                      name: "address",
                      isArray: false,
                      type: LookupType.lookup(ExpressionNode.areEqual(
                          ExpressionNode.lookup([
                            LookupNode(name: "primary", isArray: false, type: LookupType.lookup())
                          ]),
                          ExpressionNode.constant(CVUValue_Constant.bool(true))))),
                  LookupNode(name: "country", isArray: false, type: LookupType.lookup())
                ]),
                ExpressionNode.addition(
                    ExpressionNode.addition(
                        ExpressionNode.constant(CVUValue_Constant.number(4.0)),
                        ExpressionNode.multiplication(
                            ExpressionNode.constant(CVUValue_Constant.number(5.0)),
                            ExpressionNode.constant(CVUValue_Constant.number(10.0)))),
                    ExpressionNode.lookup([
                      LookupNode(
                          name: "test",
                          isArray: false,
                          type: LookupType.lookup(
                              ExpressionNode.constant(CVUValue_Constant.number(10.0))))
                    ])),
                ExpressionNode.addition(
                    ExpressionNode.constant(CVUValue_Constant.string("asdads\'asdad")),
                    ExpressionNode.constant(CVUValue_Constant.string("")))))));
  });

  test('testErrorIncompleteCondition', () {
    var snippet = "true ? 'yes'";

    expect(() => parse(snippet: snippet),
        throwsA(predicate((e) => e is CVUExpressionParseErrors_ExpectedConditionElse)));
  });

  test('testErrorIncompleteBinaryOp', () {
    var snippet = "5 +";

    expect(
        () => parse(snippet: snippet),
        throwsA(predicate(
            (e) => e is CVUExpressionParseErrors_ExpectedExpression && e.value is ExprToken_EOF)));
  });

  test('testErrorUnsupportedBinaryOp', () {
    var snippet = "5 @ 4";

    expect(
        () => parse(snippet: snippet),
        throwsA(predicate((e) =>
            e is CVUExpressionParseErrors_UnexpectedToken &&
            e.value is ExprToken_Identifier &&
            (e.value as ExprToken_Identifier).value == "@")));
  });

  test('testErrorMissingParenClose', () {
    var snippet = "(5 + 10";

    expect(
        () => parse(snippet: snippet),
        throwsA(
            predicate((e) => e is CVUExpressionParseErrors_ExpectedCharacter && e.value == ")")));
  });

  test('testErrorMissingBracketClose', () {
    var snippet = "test[10";

    expect(
        () => parse(snippet: snippet),
        throwsA(
            predicate((e) => e is CVUExpressionParseErrors_ExpectedCharacter && e.value == "]")));
  });

  test('testErrorMissingQuoteClose', () {
    var snippet = "'asdads";

    expect(() => parse(snippet: snippet),
        throwsA(predicate((e) => e is CVUExpressionParseErrors_MissingQuoteClose)));
  });

  test('testErrorUsingCurlyBracesNotInStringMode', () {
    var snippet = "Hello {fetchName()}";

    expect(
        () => parse(snippet: snippet),
        throwsA(predicate((e) =>
            e is CVUExpressionParseErrors_UnexpectedToken &&
            e.value is ExprToken_CurlyBracketOpen &&
            (e.value as ExprToken_CurlyBracketOpen).i == 6)));
  });

  test('testErrorUsingCurlyBracesInWrongContext', () {
    var snippet = "Hello {'{fetchName()}'}";

    expect(() => parse(snippet: snippet, stringMode: true), throwsA(predicate((e) {
      return e is CVUExpressionParseErrors_ExpectedExpression &&
          e.value is ExprToken_CurlyBracketClose &&
          (e.value as ExprToken_CurlyBracketClose).i == 22;
    })));
  });
}
