import 'dart:core';
import 'CVUExpressionParser.dart';

class ExprToken {
}

class ExprToken_Operator extends ExprToken {
  String? value;
  int? i;

  ExprToken_Operator(this.value, this.i);
}

class ExprToken_Bool extends ExprToken {
  bool? value;
  int? i;

  ExprToken_Bool(this.value, this.i);
}

class ExprToken_Identifier extends ExprToken {
  String? value;
  int? i;

  ExprToken_Identifier(this.value, this.i);
}

class ExprToken_Number extends ExprToken {
  double? value;
  int? i;

  ExprToken_Number(this.value, this.i);
}

class ExprToken_Negation extends ExprToken {
  int? i;

  ExprToken_Negation(this.i);
}

class ExprToken_Comma extends ExprToken {
  int? i;

  ExprToken_Comma(this.i);
}

class ExprToken_ParensOpen extends ExprToken {
  int? i;

  ExprToken_ParensOpen(this.i);
}

class ExprToken_ParensClose extends ExprToken {
  int? i;

  ExprToken_ParensClose(this.i);
}

class ExprToken_CurlyBracketOpen extends ExprToken {
  int? i;

  ExprToken_CurlyBracketOpen(this.i);
}

class ExprToken_CurlyBracketClose extends ExprToken {
  int? i;

  ExprToken_CurlyBracketClose(this.i);
}

class ExprToken_BracketOpen extends ExprToken {
  int? i;

  ExprToken_BracketOpen(this.i);
}

class ExprToken_BracketClose extends ExprToken {
  int? i;

  ExprToken_BracketClose(this.i);
}

class ExprToken_String extends ExprToken {
  String? value;
  int? i;

  ExprToken_String(this.value, this.i);
}

class ExprToken_Period extends ExprToken {
  int? i;

  ExprToken_Period(this.i);
}

class ExprToken_Other extends ExprToken {
  String? value;
  int? i;

  ExprToken_Other(this.value, this.i);
}

class ExprToken_EOF extends ExprToken {}

class ExprOperator {
  static const ConditionStart = "?";
  static const ConditionElse = ":";
  static const ConditionAND = "AND";
  static const ConditionOR = "OR";
  static const ConditionEquals = "=";
  static const ConditionNotEquals = "!=";
  static const ConditionGreaterThan = ">";
  static const ConditionGreaterThanOrEqual = ">=";
  static const ConditionLessThan = "<";
  static const ConditionLessThanOrEqual = "<=";
  static const Plus = "+";
  static const Minus = "-";
  static const Multiplication = "*";
  static const Division = "/";

  static int? precedence(operator) {
    switch (operator) {
      case ExprOperator.ConditionStart:
        return 5;
      case ExprOperator.ConditionElse:
        return 10;
      case ExprOperator.ConditionAND:
        return 20;
      case ExprOperator.ConditionOR:
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

class Mode {
  static const idle = 0;
  static const keyword = 10;
  static const number = 20;
  static const string = 30;
  static const escapedString = 35;
}

class CVUExpressionLexer {
  String input;
  bool startInStringMode;

  Map<String, ExprToken Function(int i)> get keywords {
    return {
      "true": (i) => ExprToken_Bool(true, i),
      "True": (i) => ExprToken_Bool(true, i),
      "false": (i) => ExprToken_Bool(false, i),
      "False": (i) => ExprToken_Bool(false, i),
      "and": (i) => ExprToken_Operator(ExprOperator.ConditionAND, i),
      "AND": (i) => ExprToken_Operator(ExprOperator.ConditionAND, i),
      "or": (i) => ExprToken_Operator(ExprOperator.ConditionOR, i),
      "OR": (i) => ExprToken_Operator(ExprOperator.ConditionOR, i),
      "equals": (i) => ExprToken_Operator(ExprOperator.ConditionEquals, i),
      "EQUALS": (i) => ExprToken_Operator(ExprOperator.ConditionEquals, i),
      "eq": (i) => ExprToken_Operator(ExprOperator.ConditionEquals, i),
      "EQ": (i) => ExprToken_Operator(ExprOperator.ConditionEquals, i),
      "neq": (i) => ExprToken_Operator(ExprOperator.ConditionNotEquals, i),
      "NEQ": (i) => ExprToken_Operator(ExprOperator.ConditionNotEquals, i),
      "gt": (i) => ExprToken_Operator(ExprOperator.ConditionGreaterThan, i),
      "GT": (i) => ExprToken_Operator(ExprOperator.ConditionGreaterThan, i),
      "lt": (i) => ExprToken_Operator(ExprOperator.ConditionLessThan, i),
      "LT": (i) => ExprToken_Operator(ExprOperator.ConditionLessThan, i),
    };
  }

  CVUExpressionLexer({this.input = "", this.startInStringMode = false});

  List<ExprToken> tokenize() {
    final List<ExprToken> tokens = [];

    int isMode = startInStringMode ? Mode.string : Mode.idle;
    var keyword = <String>[];

    var i;
    addToken([ExprToken? token]) {
      if (isMode == Mode.number) {
        tokens.add(ExprToken_Number(double.parse(keyword.join()), i));
        keyword = [];
        isMode = Mode.idle;
      } else if (isMode == Mode.keyword) {
        var kw = keyword.join();
        var f = keywords[kw];
        if (f != null) {
          tokens.add(f(i));
        } else {
          tokens.add(ExprToken_Identifier(kw, i));
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
              addToken(ExprToken_Operator(ExprOperator.ConditionNotEquals, i));
              continue;
            } else {
              addToken(ExprToken_Negation(i));
              break;
            }
          case ">":
            if (c == "=") {
              addToken(ExprToken_Operator(ExprOperator.ConditionGreaterThanOrEqual, i));
              continue;
            } else {
              addToken(ExprToken_Operator(ExprOperator.ConditionGreaterThan, i));
              break;
            }
          case "<":
            if (c == "=") {
              addToken(ExprToken_Operator(ExprOperator.ConditionLessThanOrEqual, i));
              continue;
            } else {
              addToken(ExprToken_Operator(ExprOperator.ConditionLessThan, i));
              break;
            }
          default:
            throw "Should never get here";
        }
      }

      if (isMode >= Mode.string) {
        if (isMode == Mode.string &&
            (c == startChar || startChar == null && startInStringMode && c == "{")) {
          if (keyword.length > 0 || i > 0 || c != "{") {
            addToken(ExprToken_String(keyword.join(), i));
          }
          if (c == "{") {
            addToken(ExprToken_CurlyBracketOpen(i));
          }
          keyword = [];
          isMode = Mode.idle;
          startChar = null;
          continue;
        }

        if (isMode == Mode.escapedString) {
          keyword.add(c.toString());
          isMode = Mode.string;
        } else if (c == "\\") {
          isMode = Mode.escapedString;
        } else {
          keyword.add(c.toString());
        }
        continue;
      }

      switch (c) {
        case "*":
          addToken(ExprToken_Operator(ExprOperator.Multiplication, i));
          break;
        case "/":
          addToken(ExprToken_Operator(ExprOperator.Division, i));
          break;
        case "+":
          addToken(ExprToken_Operator(ExprOperator.Plus, i));
          break;
        case "-":
          addToken(ExprToken_Operator(ExprOperator.Minus, i));
          break;
        case "!":
          lastChar = c;
          continue;
        case "?":
          addToken(ExprToken_Operator(ExprOperator.ConditionStart, i));
          break;
        case ":":
          addToken(ExprToken_Operator(ExprOperator.ConditionElse, i));
          break;
        case "(":
          addToken(ExprToken_ParensOpen(i));
          break;
        case ")":
          addToken(ExprToken_ParensClose(i));
          break;
        case "[":
          addToken(ExprToken_BracketOpen(i));
          break;
        case "]":
          addToken(ExprToken_BracketClose(i));
          break;
        case "=":
          addToken(ExprToken_Operator(ExprOperator.ConditionEquals, i));
          break;
        case ">":
          lastChar = c;
          continue;
        case "<":
          lastChar = c;
          continue;
        case ",":
          addToken(ExprToken_Comma(i));
          break;
        case "'":
        case "\"":
          isMode = Mode.string;
          startChar = c;
          break;
        case ".":
          if (isMode == Mode.number) {
            keyword.add(c.toString());
          } else {
            addToken(ExprToken_Period(i));
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
          keyword.add(c.toString());
          break;
        case "{":
          if (startInStringMode) {
            addToken(ExprToken_CurlyBracketOpen(i));
            isMode = Mode.idle;
          } else {
            throw CVUExpressionParseErrors_UnexpectedToken(ExprToken_CurlyBracketOpen(i));
          }
          break;
        case "}":
          if (startInStringMode) {
            addToken(ExprToken_CurlyBracketClose(i));
            isMode = Mode.string;
          } else {
            throw CVUExpressionParseErrors_UnexpectedToken(ExprToken_CurlyBracketOpen(i));
          }
          break;
        default:
          isMode = Mode.keyword;
          keyword.add(c.toString());
      }

      lastChar = null;
    }

    if (keyword.length > 0) {
      addToken();
    }

    if (startInStringMode) {
      if (keyword.length > 0) {
        addToken(ExprToken_String(keyword.join(), input.length - keyword.length));
      }
    } else if (isMode == Mode.string) {
      throw CVUExpressionParseErrors_MissingQuoteClose;
    }

    return tokens;
  }
}
