//
//  ExprLookupTests.swift
//  MemriDatabaseTests
//
//  Created by T Brennan on 24/12/20.
//

import 'package:flutter_test/flutter_test.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUExpressionLexer.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUExpressionParser.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/CVU/resolving/CVULookupController.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';


ExpressionNode parse(String snippet, [bool stringMode = false]) {
  var lexer = CVUExpressionLexer(snippet, stringMode);
  var tokens =  lexer.tokenize();
  var parser = CVUExpressionParser(tokens);
  return parser.parse();
}

var databaseController = DatabaseController();
var lookupController = CVULookupController(LookupMock(true, "Memri", 10));

bool? interpretAsBool(ExpressionNode expr) {
  return lookupController.resolve<bool>(value: CVUValue.expression(expr), context: CVUContext(), db: databaseController);
}

double? interpretAsDouble(ExpressionNode expr) {
  return lookupController.resolve<double>(value: CVUValue.expression(expr), context: CVUContext(), db: databaseController);
}

String? interpretAsString(ExpressionNode expr) {
  return lookupController.resolve<String>(value: CVUValue.expression(expr), context: CVUContext(), db: databaseController);
}

void main() {
  test('testArithmeticOperators', () {
    var snippet = "(5 + 10 * 4 - 3 / 10) / 10";

    var expr = parse(snippet);
    var result = interpretAsDouble(expr);

    expect(result, (5 + 10 * 4 - 3 / 10) / 10);
  });

  test('testAnd', () {
    var snippet = "true and false";

    var expr = parse(snippet);
    var result = interpretAsBool(expr);

    expect(result, false);
  });

  test('testOr', () {
    var snippet = "true or false";

    var expr = parse(snippet);
    var result = interpretAsBool(expr);

    expect(result, true);
  });

  test('testEqualsTrue', () {
    var snippet = "1 = '1'";

    var expr = parse(snippet);
    var result = interpretAsBool(expr);

    expect(result, true);
  });

  test('testEqualsFalse', () {
    var snippet = "1 = 2";

    var expr = parse(snippet);
    var result = interpretAsBool(expr);

    expect(result, false);
  });

  test('testOrValue', () {
    var snippet = "10 or 0";

    var expr = parse(snippet);
    var result = interpretAsDouble(expr);

    expect(result, 10);
  });

  test('testSimpleCondition', () {
    var snippet = "true ? 'yes' : 'no'";

    var expr = parse(snippet);
    var result = interpretAsString(expr);

    expect(result, "yes");
  });

  test('testMultiCondition', () {
    var snippet = "true ? false and true ? -1 : false or true ? 'yes' : 'no' : -1";

    var expr = parse(snippet);
    var result = interpretAsString(expr);

    expect(result, "yes");
  });

  test('testConditionEquals', () {
    var snippet = "true = false";

    var expr = parse(snippet);
    var result = interpretAsBool(expr);

    expect(result, false);
  });

  test('testConditionNotEquals', () {
    var snippet = "true != false";

    var expr = parse(snippet);
    var result = interpretAsBool(expr);

    expect(result, true);
  });

  test('testConditionGreaterThan', () {
    var snippet = "5 > 10";

    var expr = parse(snippet);
    var result = interpretAsBool(expr);

    expect(result, false);
  });

  test('testConditionGreaterThanOrEqual', () {
    var snippet = "5 >= 5";

    var expr = parse(snippet);
    var result = interpretAsBool(expr);

    expect(result, true);
  });

  test('testConditionLessThan', () {
    var snippet = "5 < 10";

    var expr = parse(snippet);
    var result = interpretAsBool(expr);

    expect(result, true);
  });

  test('testConditionLessThanOrEqual', () {
    var snippet = "5 <= 5";

    var expr = parse(snippet);
    var result = interpretAsBool(expr);

    expect(result, true);
  });

  test('testMinusPlusModifier', () {
    var snippet = "-5 + -(5+10) - +'5'";

    var expr = parse(snippet);
    var result = interpretAsDouble(expr);

    expect(result, -25);
  });

  test('testNegation', () {
    var snippet = "!true";

    var expr = parse(snippet);
    var result = interpretAsBool(expr);

    expect(result, false);
  });

  test('testStringEscaping', () {
    var snippet = "'asdadsasd\\'asdasd'";

    var expr = parse(snippet);
    var result = interpretAsString(expr);

    expect(result, "asdadsasd'asdasd");
  });

  test('testTypeConversionToNumber', () {
    var snippet = "5 + '10.34' + true";

    var expr = parse(snippet);
    var result = interpretAsDouble(expr);

    expect(result, 16.34);
  });

  test('testNanStringToInt', () {
    var snippet = "+'asdasd'";

    var expr = parse(snippet);
    var result = interpretAsDouble(expr);

    expect(result == null, true);
  });

  test('testTypeConversionToBool', () {
    var snippet = "0 ? -1 : 1 ? '' ? -1 : 'yes' : -1";

    var expr = parse(snippet);
    var result = interpretAsString(expr);

    expect(result, "yes");
  });

  test('testTypeConversionStringToBool', () {
    var snippet = "''";

    var expr = parse(snippet);
    var result = interpretAsBool(expr);

    expect(result, false);
  });

  test('testStringModeStartWithString', () {
    var snippet = "Hello {fetchName()}!";

    var expr = parse(snippet, true);
    var result = interpretAsString(expr);

    expect(result, "Hello Memri!");
  });

  test('testStringModeStartWithExpression', () {
    var snippet = "{fetchName()} Hello";

    var expr = parse(snippet, true);
    var result = interpretAsString(expr);

    expect(result, "Memri Hello");
  });
}