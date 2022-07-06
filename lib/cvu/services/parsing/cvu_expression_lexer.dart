import 'dart:core';

import 'cvu_expression_parser.dart';

class ExprToken {}

class ExprTokenOperator extends ExprToken {
  final ExprOperator value;
  final int i;

  ExprTokenOperator(this.value, this.i);
}

class ExprTokenBool extends ExprToken {
  final bool value;
  final int i;

  ExprTokenBool(this.value, this.i);
}

class ExprTokenIdentifier extends ExprToken {
  final String value;
  final int i;

  ExprTokenIdentifier(this.value, this.i);
}

class ExprTokenNumber extends ExprToken {
  final double value;
  final int i;

  ExprTokenNumber(this.value, this.i);
}

class ExprTokenNegation extends ExprToken {
  final int i;

  ExprTokenNegation(this.i);
}

class ExprTokenComma extends ExprToken {
  final int i;

  ExprTokenComma(this.i);
}

class ExprTokenParensOpen extends ExprToken {
  final int i;

  ExprTokenParensOpen(this.i);
}

class ExprTokenParensClose extends ExprToken {
  final int i;

  ExprTokenParensClose(this.i);
}

class ExprTokenCurlyBracketOpen extends ExprToken {
  final int i;

  ExprTokenCurlyBracketOpen(this.i);
}

class ExprTokenCurlyBracketClose extends ExprToken {
  final int i;

  ExprTokenCurlyBracketClose(this.i);
}

class ExprTokenBracketOpen extends ExprToken {
  final int i;

  ExprTokenBracketOpen(this.i);
}

class ExprTokenBracketClose extends ExprToken {
  final int i;

  ExprTokenBracketClose(this.i);
}

class ExprTokenString extends ExprToken {
  final String value;
  final int i;
  final bool isSingleQuote;
  final bool isMultiline;

  ExprTokenString(this.value, this.i,
      {this.isSingleQuote = false, this.isMultiline = false});
}

class ExprTokenPeriod extends ExprToken {
  final int i;

  ExprTokenPeriod(this.i);
}

class ExprTokenOther extends ExprToken {
  final String value;
  final int i;

  ExprTokenOther(this.value, this.i);
}

class ExprTokenColon extends ExprToken {
  final int i;

  ExprTokenColon(this.i);
}

class ExprTokenEOF extends ExprToken {}

enum ExprOperator {
  ConditionStart,
  ConditionElse,
  ConditionAND,
  ConditionOR,
  ConditionEquals,
  ConditionNotEquals,
  ConditionGreaterThan,
  ConditionGreaterThanOrEqual,
  ConditionLessThan,
  ConditionLessThanOrEqual,
  Plus,
  Minus,
  Multiplication,
  Division
}

extension ExprOperatorExtension on ExprOperator {
  static const Map<ExprOperator, String> operators = {
    ExprOperator.ConditionStart: "?",
    ExprOperator.ConditionElse: ":",
    ExprOperator.ConditionAND: "AND",
    ExprOperator.ConditionOR: "OR",
    ExprOperator.ConditionEquals: "=",
    ExprOperator.ConditionNotEquals: "!=",
    ExprOperator.ConditionGreaterThan: ">",
    ExprOperator.ConditionGreaterThanOrEqual: ">=",
    ExprOperator.ConditionLessThan: "<",
    ExprOperator.ConditionLessThanOrEqual: "<=",
    ExprOperator.Plus: "+",
    ExprOperator.Minus: "-",
    ExprOperator.Multiplication: "*",
    ExprOperator.Division: "/"
  };

  String get value => operators[this]!;

  String get rawValue => this.toString().split(".").last;

  int get precedence {
    switch (this) {
      case ExprOperator.ConditionStart:
        return 5;
      case ExprOperator.ConditionElse:
        return 10;
      case ExprOperator.ConditionOR:
        return 20;
      case ExprOperator.ConditionAND:
        return 30;
      case ExprOperator.ConditionEquals:
        return 35;
      case ExprOperator.ConditionNotEquals:
        return 35;
      case ExprOperator.ConditionGreaterThan:
        return 35;
      case ExprOperator.ConditionGreaterThanOrEqual:
        return 35;
      case ExprOperator.ConditionLessThan:
        return 35;
      case ExprOperator.ConditionLessThanOrEqual:
        return 35;
      case ExprOperator.Plus:
        return 40;
      case ExprOperator.Minus:
        return 40;
      case ExprOperator.Multiplication:
        return 50;
      case ExprOperator.Division:
        return 50;
    }
  }
}

enum Mode { idle, keyword, number, string, escapedString }

extension ModeExtension on Mode {
  int get weight {
    switch (this) {
      case Mode.idle:
        return 0;
      case Mode.keyword:
        return 10;
      case Mode.number:
        return 20;
      case Mode.string:
        return 30;
      case Mode.escapedString:
        return 35;
    }
  }
}

class CVUExpressionLexer {
  String input;
  bool startInStringMode;

  Map<String, ExprToken Function(int i)> get keywords {
    return {
      "true": (i) => ExprTokenBool(true, i),
      "True": (i) => ExprTokenBool(true, i),
      "false": (i) => ExprTokenBool(false, i),
      "False": (i) => ExprTokenBool(false, i),
      "and": (i) => ExprTokenOperator(ExprOperator.ConditionAND, i),
      "AND": (i) => ExprTokenOperator(ExprOperator.ConditionAND, i),
      "or": (i) => ExprTokenOperator(ExprOperator.ConditionOR, i),
      "OR": (i) => ExprTokenOperator(ExprOperator.ConditionOR, i),
      "equals": (i) => ExprTokenOperator(ExprOperator.ConditionEquals, i),
      "EQUALS": (i) => ExprTokenOperator(ExprOperator.ConditionEquals, i),
      "eq": (i) => ExprTokenOperator(ExprOperator.ConditionEquals, i),
      "EQ": (i) => ExprTokenOperator(ExprOperator.ConditionEquals, i),
      "neq": (i) => ExprTokenOperator(ExprOperator.ConditionNotEquals, i),
      "NEQ": (i) => ExprTokenOperator(ExprOperator.ConditionNotEquals, i),
      "gt": (i) => ExprTokenOperator(ExprOperator.ConditionGreaterThan, i),
      "GT": (i) => ExprTokenOperator(ExprOperator.ConditionGreaterThan, i),
      "lt": (i) => ExprTokenOperator(ExprOperator.ConditionLessThan, i),
      "LT": (i) => ExprTokenOperator(ExprOperator.ConditionLessThan, i),
    };
  }

  CVUExpressionLexer([this.input = "", this.startInStringMode = false]);

  List<ExprToken> tokenize() {
    final List<ExprToken> tokens = [];

    Mode isMode = startInStringMode ? Mode.string : Mode.idle;
    var conditionCount = 0;
    var keyword = <String>[];

    var i;
    addToken([ExprToken? token]) {
      if (isMode == Mode.number) {
        tokens.add(ExprTokenNumber(double.parse(keyword.join()), i));
        keyword = [];
        isMode = Mode.idle;
      } else if (isMode == Mode.keyword) {
        var kw = keyword.join();
        var f = keywords[kw];
        if (f != null) {
          tokens.add(f(i));
        } else {
          tokens.add(ExprTokenIdentifier(kw, i));
        }

        keyword = [];
        isMode = Mode.idle;
      }

      if (token != null) {
        tokens.add(token);
      }
    }

    var startChar, lastChar;
    for (i = 0; i < input.length; i++) {
      var c = input[i];

      if (lastChar != null) {
        var l = lastChar;
        lastChar = null;

        switch (l) {
          case "!":
            if (c == "=") {
              addToken(ExprTokenOperator(ExprOperator.ConditionNotEquals, i));
              continue;
            } else {
              addToken(ExprTokenNegation(i));
              break;
            }
          case ">":
            if (c == "=") {
              addToken(ExprTokenOperator(
                  ExprOperator.ConditionGreaterThanOrEqual, i));
              continue;
            } else {
              addToken(ExprTokenOperator(ExprOperator.ConditionGreaterThan, i));
              break;
            }
          case "<":
            if (c == "=") {
              addToken(
                  ExprTokenOperator(ExprOperator.ConditionLessThanOrEqual, i));
              continue;
            } else {
              addToken(ExprTokenOperator(ExprOperator.ConditionLessThan, i));
              break;
            }
          default:
            throw "Should never get here";
        }
      }

      if (isMode.weight >= Mode.string.weight) {
        if (isMode == Mode.string &&
            (c == startChar ||
                startChar == null && startInStringMode && c == "{")) {
          if (keyword.length > 0 || i > 0 || c != "{") {
            addToken(ExprTokenString(keyword.join(), i,
                isSingleQuote: c == "'", isMultiline: c == "'''"));
          }
          if (c == "{") {
            addToken(ExprTokenCurlyBracketOpen(i));
          }
          keyword = [];
          isMode = Mode.idle;
          startChar = null;
          continue;
        }

        if (isMode == Mode.escapedString) {
          keyword.add(c);
          isMode = Mode.string;
        } else if (c == "\\") {
          isMode = Mode.escapedString;
        } else {
          keyword.add(c);
        }
        continue;
      }

      switch (c) {
        case "*":
          addToken(ExprTokenOperator(ExprOperator.Multiplication, i));
          break;
        case "/":
          addToken(ExprTokenOperator(ExprOperator.Division, i));
          break;
        case "+":
          addToken(ExprTokenOperator(ExprOperator.Plus, i));
          break;
        case "-":
          addToken(ExprTokenOperator(ExprOperator.Minus, i));
          break;
        case "!":
          lastChar = c;
          continue;
        case "?":
          conditionCount++;
          addToken(ExprTokenOperator(ExprOperator.ConditionStart, i));
          break;
        case ":":
          if (conditionCount > 0) {
            addToken(ExprTokenOperator(ExprOperator.ConditionElse, i));
            conditionCount--;
          } else {
            addToken(ExprTokenColon(i));
          }
          break;
        case "(":
          addToken(ExprTokenParensOpen(i));
          break;
        case ")":
          addToken(ExprTokenParensClose(i));
          break;
        case "[":
          addToken(ExprTokenBracketOpen(i));
          break;
        case "]":
          addToken(ExprTokenBracketClose(i));
          break;
        case "=":
          addToken(ExprTokenOperator(ExprOperator.ConditionEquals, i));
          break;
        case ">":
          lastChar = c;
          continue;
        case "<":
          lastChar = c;
          continue;
        case ",":
          addToken(ExprTokenComma(i));
          break;
        case "'":
        case "\"":
          isMode = Mode.string;
          startChar = c;
          break;
        case ".":
          if (isMode == Mode.number) {
            keyword.add(c);
          } else {
            addToken(ExprTokenPeriod(i));
          }
          break;
        case " ":
        case "\t":
          addToken();
          break;
        case "0":
        case "1":
        case "2":
        case "3":
        case "4":
        case "5":
        case "6":
        case "7":
        case "8":
        case "9":
          if (isMode == Mode.idle) {
            isMode = Mode.number;
          }
          keyword.add(c);
          break;
        case "{":
          if (startInStringMode) {
            addToken(ExprTokenCurlyBracketOpen(i));
            isMode = Mode.idle;
          } else {
            throw CVUExpressionParseErrorsUnexpectedToken(
                ExprTokenCurlyBracketOpen(i));
          }
          break;
        case "}":
          if (startInStringMode) {
            addToken(ExprTokenCurlyBracketClose(i));
            isMode = Mode.string;
          } else {
            throw CVUExpressionParseErrorsUnexpectedToken(
                ExprTokenCurlyBracketOpen(i));
          }
          break;
        default:
          isMode = Mode.keyword;
          keyword.add(c);
      }

      lastChar = null;
    }

    if (keyword.length > 0) {
      addToken();
    }

    if (startInStringMode) {
      if (keyword.length > 0) {
        addToken(
            ExprTokenString(keyword.join(), input.length - keyword.length));
      }
    } else if (isMode == Mode.string) {
      throw CVUExpressionParseErrorsMissingQuoteClose();
    }

    return tokens;
  }
}
