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
}