//
//  ExprLookupTests.swift
//  MemriDatabaseTests
//
//  Created by T Brennan on 24/12/20.
//

import 'package:flutter_test/flutter_test.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Expression.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUExpressionLexer.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUExpressionParser.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/CVU/resolving/CVULookupController.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';

CVUExpressionNode parse(String snippet, [bool stringMode = false]) {
  var lexer = CVUExpressionLexer(snippet, stringMode);
  var tokens = lexer.tokenize();
  var parser = CVUExpressionParser(tokens);
  return parser.parse();
}

var databaseController = DatabaseController();
var lookupController = CVULookupController(LookupMock(true, "Memri", 10));

Future<bool?> interpretAsBool(CVUExpressionNode expr) async {
  return await lookupController.resolve<bool>(
      value: CVUValueExpression(expr),
      context: CVUContext(),
      db: databaseController);
}

Future<double?> interpretAsDouble(CVUExpressionNode expr) async {
  return await lookupController.resolve<double>(
      value: CVUValueExpression(expr),
      context: CVUContext(),
      db: databaseController);
}

Future<String?> interpretAsString(CVUExpressionNode expr) async {
  return await lookupController.resolve<String>(
      value: CVUValueExpression(expr),
      context: CVUContext(),
      db: databaseController);
}

void main() {
  test('testArithmeticOperators', () async {
    var snippet = "(5 + 10 * 4 - 3 / 10) / 10";

    var expr = parse(snippet);
    var result = await interpretAsDouble(expr);

    expect(result, (5 + 10 * 4 - 3 / 10) / 10);
  });

  test('testAnd', () async {
    var snippet = "true and false";

    var expr = parse(snippet);
    var result = await interpretAsBool(expr);

    expect(result, false);
  });

  test('testOr', () async {
    var snippet = "true or false";

    var expr = parse(snippet);
    var result = await interpretAsBool(expr);

    expect(result, true);
  });

  test('testEqualsTrue', () async {
    var snippet = "1 = '1'";

    var expr = parse(snippet);
    var result = await interpretAsBool(expr);

    expect(result, true);
  });

  test('testEqualsFalse', () async {
    var snippet = "1 = 2";

    var expr = parse(snippet);
    var result = await interpretAsBool(expr);

    expect(result, false);
  });

  test('testOrValue', () async {
    var snippet = "10 or 0";

    var expr = parse(snippet);
    var result = await interpretAsDouble(expr);

    expect(result, 10);
  });

  test('testSimpleCondition', () async {
    var snippet = "true ? 'yes' : 'no'";

    var expr = parse(snippet);
    var result = await interpretAsString(expr);

    expect(result, "yes");
  });

  test('testMultiCondition', () async {
    var snippet =
        "true ? false and true ? -1 : false or true ? 'yes' : 'no' : -1";

    var expr = parse(snippet);
    var result = await interpretAsString(expr);

    expect(result, "yes");
  });

  test('testConditionEquals', () async {
    var snippet = "true = false";

    var expr = parse(snippet);
    var result = await interpretAsBool(expr);

    expect(result, false);
  });

  test('testConditionNotEquals', () async {
    var snippet = "true != false";

    var expr = parse(snippet);
    var result = await interpretAsBool(expr);

    expect(result, true);
  });

  test('testConditionGreaterThan', () async {
    var snippet = "5 > 10";

    var expr = parse(snippet);
    var result = await interpretAsBool(expr);

    expect(result, false);
  });

  test('testConditionGreaterThanOrEqual', () async {
    var snippet = "5 >= 5";

    var expr = parse(snippet);
    var result = await interpretAsBool(expr);

    expect(result, true);
  });

  test('testConditionLessThan', () async {
    var snippet = "5 < 10";

    var expr = parse(snippet);
    var result = await interpretAsBool(expr);

    expect(result, true);
  });

  test('testConditionLessThanOrEqual', () async {
    var snippet = "5 <= 5";

    var expr = parse(snippet);
    var result = await interpretAsBool(expr);

    expect(result, true);
  });

  test('testMinusPlusModifier', () async {
    var snippet = "-5 + -(5+10) - +'5'";

    var expr = parse(snippet);
    var result = await interpretAsDouble(expr);

    expect(result, -25);
  });

  test('testNegation', () async {
    var snippet = "!true";

    var expr = parse(snippet);
    var result = await interpretAsBool(expr);

    expect(result, false);
  });

  test('testStringEscaping', () async {
    var snippet = "'asdadsasd\\'asdasd'";

    var expr = parse(snippet);
    var result = await interpretAsString(expr);

    expect(result, "asdadsasd'asdasd");
  });

  test('testTypeConversionToNumber', () async {
    var snippet = "5 + '10.34' + true";

    var expr = parse(snippet);
    var result = await interpretAsDouble(expr);

    expect(result, 16.34);
  });

  test('testNanStringToInt', () async {
    var snippet = "+'asdasd'";

    var expr = parse(snippet);
    var result = await interpretAsDouble(expr);

    expect(result == null, true);
  });

  test('testTypeConversionToBool', () async {
    var snippet = "0 ? -1 : 1 ? '' ? -1 : 'yes' : -1";

    var expr = parse(snippet);
    var result = await interpretAsString(expr);

    expect(result, "yes");
  });

  test('testTypeConversionStringToBool', () async {
    var snippet = "''";

    var expr = parse(snippet);
    var result = await interpretAsBool(expr);

    expect(result, false);
  });

  test('testStringModeStartWithString', () async {
    var snippet = "Hello {fetchName()}!";

    var expr = parse(snippet, true);
    var result = await interpretAsString(expr);

    expect(result, "Hello Memri!");
  });

  test('testStringModeStartWithExpression', () async {
    var snippet = "{fetchName()} Hello";

    var expr = parse(snippet, true);
    var result = await interpretAsString(expr);

    expect(result, "Memri Hello");
  });
}
