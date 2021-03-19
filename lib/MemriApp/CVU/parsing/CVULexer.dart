//
// CVULexer.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:memri/MemriApp/CVU/parsing/CVUParseErrors.dart';

enum CVUTokenType {
  Operator,
  Bool,
  Number,
  String,
  Identifier,
  NamedIdentifier,
  StringExpression,
  Expression,
  Negation,
  Comma,
  Color,
  SemiColon,
  Colon,
  Newline,
  Caret,
  CurlyBracketOpen,
  CurlyBracketClose,
  BracketOpen,
  BracketClose,
  Nil,
  EOF
}


class CVUToken {
  var value;
  int? ln;
  int? ch;
  final CVUTokenType type;

  CVUToken.operator(CVUOperator this.value, this.ln, this.ch) : type = CVUTokenType.Operator;
  CVUToken.bool(bool this.value, this.ln, this.ch) : type = CVUTokenType.Bool;
  CVUToken.number(double this.value, this.ln, this.ch) : type = CVUTokenType.Number;
  CVUToken.string(String this.value, this.ln, this.ch) : type = CVUTokenType.String;
  CVUToken.identifier(String this.value, this.ln, this.ch) : type = CVUTokenType.Identifier;
  CVUToken.namedIdentifier(String this.value, this.ln, this.ch) : type = CVUTokenType.NamedIdentifier;
  CVUToken.stringExpression(String this.value, this.ln, this.ch) : type = CVUTokenType.StringExpression;
  CVUToken.expression(String this.value, this.ln, this.ch) : type = CVUTokenType.Expression;
  CVUToken.negation(this.ln, this.ch) : type = CVUTokenType.Negation;
  CVUToken.comma(this.ln, this.ch) : type = CVUTokenType.Comma;
  CVUToken.color(String this.value, this.ln, this.ch) : type = CVUTokenType.Color;
  CVUToken.semiColon(this.ln, this.ch) : type = CVUTokenType.SemiColon;
  CVUToken.colon(this.ln, this.ch) : type = CVUTokenType.Colon;
  CVUToken.newline(this.ln, this.ch) : type = CVUTokenType.Newline;
  CVUToken.caret(this.ln, this.ch) : type = CVUTokenType.Caret;
  CVUToken.curlyBracketOpen(this.ln, this.ch) : type = CVUTokenType.CurlyBracketOpen;
  CVUToken.curlyBracketClose(this.ln, this.ch) : type = CVUTokenType.CurlyBracketClose;
  CVUToken.bracketOpen(this.ln, this.ch) : type = CVUTokenType.BracketOpen;
  CVUToken.bracketClose(this.ln, this.ch) : type = CVUTokenType.BracketClose;
  CVUToken.nil(this.ln, this.ch) : type = CVUTokenType.Nil;
  CVUToken.EOF() : type = CVUTokenType.EOF;

  List toParts() {
    List parts = [];
    switch (type) {
      case (CVUTokenType.Operator): parts += ["Operator", (value as CVUOperator).value, ln, ch]; break;
      case (CVUTokenType.Bool): parts += ["Bool", value, ln, ch]; break;
      case (CVUTokenType.Number): parts += ["Number", value, ln, ch]; break;
      case (CVUTokenType.String): parts += ["String", value, ln, ch]; break;
      case (CVUTokenType.Identifier): parts += ["Identifier", value, ln, ch]; break;
      case (CVUTokenType.NamedIdentifier): parts += ["NamedIdentifier", value, ln, ch]; break;
      case (CVUTokenType.StringExpression): parts += ["StringExpression", value, ln, ch]; break;
      case (CVUTokenType.Expression): parts += ["Expression", value, ln, ch]; break;
      case (CVUTokenType.Negation): parts += ["Negation", "", ln, ch]; break;
      case (CVUTokenType.Comma): parts += ["Comma", "", ln, ch]; break;
      case (CVUTokenType.Color): parts += ["Color", value, ln, ch]; break;
      case (CVUTokenType.SemiColon): parts += ["SemiColon", "", ln, ch]; break;
      case (CVUTokenType.Colon): parts += ["Colon", "", ln, ch]; break;
      case (CVUTokenType.Newline): parts += ["Newline", "", ln, ch]; break;
      case (CVUTokenType.Caret): parts += ["Caret", "", ln, ch]; break;
      case (CVUTokenType.CurlyBracketOpen): parts += ["CurlyBracketOpen", "", ln, ch]; break;
      case (CVUTokenType.CurlyBracketClose): parts += ["CurlyBracketClose", "", ln, ch]; break;
      case (CVUTokenType.BracketOpen): parts += ["BracketOpen", "", ln, ch]; break;
      case (CVUTokenType.BracketClose): parts += ["BracketClose", "", ln, ch]; break;
      case (CVUTokenType.Nil): parts += ["Nil", "", ln, ch]; break;
      case (CVUTokenType.EOF): parts += ["EOF", ""]; break;
      default: break;
    }

    return parts;
  }
}

enum CVUOperator {
  ConditionAND, ConditionOR, ConditionEquals
}

extension CVUOperatorExtension on CVUOperator {
  static const operators = {
    CVUOperator.ConditionAND: "AND",
    CVUOperator.ConditionOR: "OR",
    CVUOperator.ConditionEquals: "=",
  };

  String get value => operators[this]!;

  int precedence() {
    switch (this) {
      case CVUOperator.ConditionAND:
        return 20;
      case CVUOperator.ConditionOR:
        return 30;
      case CVUOperator.ConditionEquals:
        return 35;
    }
  }
}

enum Mode {
  idle,
  color,
  comment,
  keyword,
  namedIdentifier,
  number,
  expression,
  string,
  escapedString
}

extension ModeExtension on Mode {
  int get weight {
    switch (this) {
      case (Mode.idle): return 0;
      case (Mode.color): return 5;
      case (Mode.comment): return 8;
      case (Mode.keyword): return 10;
      case (Mode.namedIdentifier): return 11;
      case (Mode.number): return 20;
      case (Mode.expression): return 25;
      case (Mode.string): return 30;
      case (Mode.escapedString): return 35;
      default: return 0;
    }
  }
}

class CVULexer {
  final String input;

  CVULexer(this.input);

  final Map<String, CVUToken Function(int, int)> keywords = {
    "true": (ln, ch) => CVUToken.bool(true, ln, ch),
    "True": (ln, ch) => CVUToken.bool(true, ln, ch),
    "false": (ln, ch) => CVUToken.bool(false, ln, ch),
    "False": (ln, ch) => CVUToken.bool(false, ln, ch),
    "and": (ln, ch) => CVUToken.operator(CVUOperator.ConditionAND, ln, ch),
    "AND": (ln, ch) => CVUToken.operator(CVUOperator.ConditionAND, ln, ch),
    "or": (ln, ch) => CVUToken.operator(CVUOperator.ConditionOR, ln, ch),
    "OR": (ln, ch) => CVUToken.operator(CVUOperator.ConditionOR, ln, ch),
    "equals": (ln, ch) => CVUToken.operator(CVUOperator.ConditionEquals, ln, ch),
    "EQUALS": (ln, ch) => CVUToken.operator(CVUOperator.ConditionEquals, ln, ch),
    "not": (ln, ch) => CVUToken.negation(ln, ch),
    "NOT": (ln, ch) => CVUToken.negation(ln, ch),
    "nil": (ln, ch) => CVUToken.nil(ln, ch),
    "null": (ln, ch) => CVUToken.nil(ln, ch),
  };

  List<CVUToken> tokenize() {
    final List<CVUToken> tokens = [];

    Mode isMode = Mode.idle;
    List<String> keyword = [];

    int ln = 0, ch = -1;
    String startChar = " ", lastChar = " ";
    bool isStringExpression = false;

    addToken([CVUToken? token]) {
      if (isMode == Mode.number) {
        tokens.add(CVUToken.number(double.parse(keyword.join()), ln, ch - keyword.length));
        keyword = [];
        isMode = Mode.idle;
      } else if (isMode == Mode.color) {
        tokens.add(CVUToken.color(keyword.join(), ln, ch));
        keyword = [];
        isMode = Mode.idle;
      } else if (isMode == Mode.keyword || isMode == Mode.namedIdentifier) {
        String kw = keyword.join();

        if (keywords[kw] != null) {
          tokens.add(keywords[kw]!(ln, ch));
        } else if (isMode == Mode.namedIdentifier) {
          tokens.add(CVUToken.namedIdentifier(kw, ln, ch - kw.length - 1));
        } else {
          tokens.add(CVUToken.identifier(kw, ln, ch - kw.length));
        }

        keyword = [];
        isMode = Mode.idle;
      }

      if (token != null) {
        tokens.add(token);
      }
    }

    this.input.split("").forEach((c) {
      ch += 1;

      if (isMode.weight >= Mode.string.weight) {
        if (c == "\n") {
          ln += 1;
          ch = 0;
        }

        if (isMode == Mode.escapedString) {
          keyword.add(c.toString());
          isMode = Mode.string;
        } else if (c == "\\") {
          isMode = Mode.escapedString;
        } else if (isMode == Mode.string && c == startChar) {
          if (isStringExpression) {
            tokens.add(CVUToken.stringExpression(keyword.join(), ln, ch - keyword.length));
          } else {
            tokens.add(CVUToken.string(keyword.join(), ln, ch - keyword.length));
          }

          keyword = [];
          isMode = Mode.idle;
          isStringExpression = false;
          return;
        } else {
          keyword.add(c.toString());
        }

        if (c == "{") {
          isStringExpression = true;
        }

        return;
      }

      if (isMode == Mode.expression) {
        if (c == "}" && lastChar == "}") {
          CVUToken lastToken = tokens.removeLast();
          if (lastToken.type == CVUTokenType.CurlyBracketOpen) {
            keyword.removeLast();

            tokens.add(CVUToken.expression(keyword.join(), ln, ch));
            keyword = [];
            isMode = Mode.idle;
          }
        } else {
          keyword.add(c.toString());
          lastChar = c;
          if (c == "\n") {
            ln += 1;
            ch = 0;
          }
        }

        return;
      }

      if (isMode == Mode.comment) {
        if (c == "/" && lastChar == "*") {
          isMode = Mode.idle;
        }
        lastChar = c;
        if (c == "\n") {
          ln += 1;
          ch = 0;
        }
        return;
      }

      switch (c) {
        case "\n":
          addToken(CVUToken.newline(ln, ch));
          ln += 1;
          ch = 0;
          break;
        case "!":
          addToken(CVUToken.negation(ln, ch));
          break;
        case "[":
          addToken(CVUToken.bracketOpen(ln, ch));
          break;
        case "]":
          addToken(CVUToken.bracketClose(ln, ch));
          break;
        case "=":
          addToken(CVUToken.operator(CVUOperator.ConditionEquals, ln, ch));
          break;
        case ",":
          addToken(CVUToken.comma(ln, ch));
          break;
        case ":":
          addToken(CVUToken.colon(ln, ch));
          break;
        case ">":
          addToken(CVUToken.caret(ln, ch));
          break;
        case ";":
          addToken(CVUToken.semiColon(ln, ch));
          break;
        case "'":
        case "\"":
          isMode = Mode.string;
          startChar = c;
          break;
        case " ":
        case "\t":
          addToken();
          break;
        case "/":
          isMode = Mode.comment;
          break; // TODO: check for * after /
        case "-":
          if (isMode == Mode.idle) {
            continue number;
          } else {
            keyword.add("-");
            break;
          }
        number:
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
        case "#":
          isMode = Mode.color;
          break;
        case "{":
          if (lastChar == "{") {
            isMode = Mode.expression;
          } else {
            addToken(CVUToken.curlyBracketOpen(ln, ch));
          }
          break;
        case "}":
          addToken(CVUToken.curlyBracketClose(ln, ch));
          break;
        case ".":
          if (isMode == Mode.idle) {
            isMode = Mode.namedIdentifier;
          } else if (isMode == Mode.number) {
            keyword.add(c.toString());
          } else {
            continue defaultCase;
          }
          break;
        defaultCase:
        default:
          if (isMode == Mode.idle) {
            isMode = Mode.keyword;
          }
          keyword.add(c.toString());
      }

      lastChar = c;
    });

    if (keyword.length > 0) {
      addToken();
    }

    if (isMode == Mode.string) {
      throw CVUParseErrors.MissingQuoteClose(CVUToken.EOF());
    }
    else if (isMode == Mode.expression) {
      throw CVUParseErrors.MissingExpressionClose(CVUToken.EOF());
    }
    else if (isMode != Mode.idle) {
      // TODO:
      throw Exception("Unhandled error mode: $isMode");
    }

    return tokens;
  }
}
