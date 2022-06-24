//
// CVULexer.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:memri/core/cvu/parsing/cvu_parse_errors.dart';

part 'cvu_lexer.g.dart';

class CVUTokenOperator extends CVUToken {
  final CVUOperator value;

  CVUTokenOperator(this.value, ln, ch) : super(ln, ch);
}

class CVUTokenBool extends CVUToken {
  final bool value;

  CVUTokenBool(this.value, ln, ch) : super(ln, ch);
}

class CVUTokenNumber extends CVUToken {
  final double value;

  CVUTokenNumber(this.value, ln, ch) : super(ln, ch);
}

class CVUTokenString extends CVUToken {
  final String value;

  CVUTokenString(this.value, ln, ch) : super(ln, ch);
}

class CVUTokenIdentifier extends CVUToken {
  final String value;

  CVUTokenIdentifier(this.value, ln, ch) : super(ln, ch);
}

class CVUTokenNamedIdentifier extends CVUToken {
  final String value;

  CVUTokenNamedIdentifier(this.value, ln, ch) : super(ln, ch);
}

class CVUTokenStringExpression extends CVUToken {
  final String value;

  CVUTokenStringExpression(this.value, ln, ch) : super(ln, ch);
}

class CVUTokenExpression extends CVUToken {
  final String value;

  CVUTokenExpression(this.value, ln, ch) : super(ln, ch);
}

class CVUTokenNegation extends CVUToken {
  CVUTokenNegation(ln, ch) : super(ln, ch);
}

class CVUTokenComma extends CVUToken {
  CVUTokenComma(ln, ch) : super(ln, ch);
}

class CVUTokenColor extends CVUToken {
  final String value;

  CVUTokenColor(this.value, ln, ch) : super(ln, ch);
}

class CVUTokenSemiColon extends CVUToken {
  CVUTokenSemiColon(ln, ch) : super(ln, ch);
}

class CVUTokenColon extends CVUToken {
  CVUTokenColon(ln, ch) : super(ln, ch);
}

class CVUTokenNewline extends CVUToken {
  CVUTokenNewline(ln, ch) : super(ln, ch);
}

class CVUTokenCaret extends CVUToken {
  CVUTokenCaret(ln, ch) : super(ln, ch);
}

class CVUTokenCurlyBracketOpen extends CVUToken {
  CVUTokenCurlyBracketOpen(ln, ch) : super(ln, ch);
}

class CVUTokenCurlyBracketClose extends CVUToken {
  CVUTokenCurlyBracketClose(ln, ch) : super(ln, ch);
}

class CVUTokenBracketOpen extends CVUToken {
  CVUTokenBracketOpen(ln, ch) : super(ln, ch);
}

class CVUTokenBracketClose extends CVUToken {
  CVUTokenBracketClose(ln, ch) : super(ln, ch);
}

class CVUTokenNil extends CVUToken {
  CVUTokenNil(ln, ch) : super(ln, ch);
}

class CVUTokenEOF extends CVUToken {
  CVUTokenEOF() : super();
}

@JsonSerializable()
class CVUTokenLocation {
  final int ln;
  final int ch;

  CVUTokenLocation(this.ln, this.ch);

  factory CVUTokenLocation.fromJson(Map<String, dynamic> json) =>
      _$CVUTokenLocationFromJson(json);

  Map<String, dynamic> toJson() => _$CVUTokenLocationToJson(this);
}

abstract class CVUToken with EquatableMixin {
  final int? ln;
  final int? ch;

  get value => null;

  late final CVUTokenLocation? location;

  CVUToken([this.ln, this.ch]) {
    if (ln != null && ch != null) {
      location = CVUTokenLocation(ln!, ch!);
    }
  }

  get props => [value, ln, ch];

  List toParts() {
    List parts = [];
    var token = this;

    if (token is CVUTokenOperator) {
      parts += ["Operator", token.value.value, ln, ch];
    } else if (token is CVUTokenBool) {
      parts += ["Bool", token.value, ln, ch];
    } else if (token is CVUTokenNumber) {
      parts += ["Number", token.value, ln, ch];
    } else if (token is CVUTokenString) {
      parts += ["String", token.value, ln, ch];
    } else if (token is CVUTokenIdentifier) {
      parts += ["Identifier", token.value, ln, ch];
    } else if (token is CVUTokenNamedIdentifier) {
      parts += ["NamedIdentifier", token.value, ln, ch];
    } else if (token is CVUTokenStringExpression) {
      parts += ["StringExpression", token.value, ln, ch];
    } else if (token is CVUTokenExpression) {
      parts += ["Expression", token.value, ln, ch];
    } else if (token is CVUTokenNegation) {
      parts += ["Negation", "", ln, ch];
    } else if (token is CVUTokenComma) {
      parts += ["Comma", "", ln, ch];
    } else if (token is CVUTokenColor) {
      parts += ["Color", token.value, ln, ch];
    } else if (token is CVUTokenSemiColon) {
      parts += ["SemiColon", "", ln, ch];
    } else if (token is CVUTokenColon) {
      parts += ["Colon", "", ln, ch];
    } else if (token is CVUTokenNewline) {
      parts += ["Newline", "", ln, ch];
    } else if (token is CVUTokenCaret) {
      parts += ["Caret", "", ln, ch];
    } else if (token is CVUTokenCurlyBracketOpen) {
      parts += ["CurlyBracketOpen", "", ln, ch];
    } else if (token is CVUTokenCurlyBracketClose) {
      parts += ["CurlyBracketClose", "", ln, ch];
    } else if (token is CVUTokenBracketOpen) {
      parts += ["BracketOpen", "", ln, ch];
    } else if (token is CVUTokenBracketClose) {
      parts += ["BracketClose", "", ln, ch];
    } else if (token is CVUTokenNil) {
      parts += ["Nil", "", ln, ch];
    } else if (token is CVUTokenEOF) {
      parts += ["EOF", "", ln, ch];
    } else {
      throw Exception("We should never get here");
    }

    return parts;
  }
}

enum CVUOperator { ConditionAND, ConditionOR, ConditionEquals }

extension CVUOperatorExtension on CVUOperator {
  static const Map<CVUOperator, String> operators = {
    CVUOperator.ConditionAND: "AND",
    CVUOperator.ConditionOR: "OR",
    CVUOperator.ConditionEquals: "=",
  };

  String get value => operators[this]!;

  int get precedence {
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
      case Mode.idle:
        return 0;
      case Mode.color:
        return 5;
      case Mode.comment:
        return 8;
      case Mode.keyword:
        return 10;
      case Mode.namedIdentifier:
        return 11;
      case Mode.number:
        return 20;
      case Mode.expression:
        return 25;
      case Mode.string:
        return 30;
      case Mode.escapedString:
        return 35;
    }
  }
}

class CVULexer {
  final String input;

  CVULexer(this.input);

  final Map<String, CVUToken Function(int, int)> keywords = {
    "true": (ln, ch) => CVUTokenBool(true, ln, ch),
    "True": (ln, ch) => CVUTokenBool(true, ln, ch),
    "false": (ln, ch) => CVUTokenBool(false, ln, ch),
    "False": (ln, ch) => CVUTokenBool(false, ln, ch),
    "and": (ln, ch) => CVUTokenOperator(CVUOperator.ConditionAND, ln, ch),
    "AND": (ln, ch) => CVUTokenOperator(CVUOperator.ConditionAND, ln, ch),
    "or": (ln, ch) => CVUTokenOperator(CVUOperator.ConditionOR, ln, ch),
    "OR": (ln, ch) => CVUTokenOperator(CVUOperator.ConditionOR, ln, ch),
    "equals": (ln, ch) => CVUTokenOperator(CVUOperator.ConditionEquals, ln, ch),
    "EQUALS": (ln, ch) => CVUTokenOperator(CVUOperator.ConditionEquals, ln, ch),
    "not": (ln, ch) => CVUTokenNegation(ln, ch),
    "NOT": (ln, ch) => CVUTokenNegation(ln, ch),
    "nil": (ln, ch) => CVUTokenNil(ln, ch),
    "null": (ln, ch) => CVUTokenNil(ln, ch),
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
        tokens.add(CVUTokenNumber(
            double.parse(keyword.join()), ln, ch - keyword.length));
        keyword = [];
        isMode = Mode.idle;
      } else if (isMode == Mode.color) {
        tokens.add(CVUTokenColor(keyword.join(), ln, ch));
        keyword = [];
        isMode = Mode.idle;
      } else if (isMode == Mode.keyword || isMode == Mode.namedIdentifier) {
        String kw = keyword.join();

        if (keywords[kw] != null) {
          tokens.add(keywords[kw]!(ln, ch));
        } else if (isMode == Mode.namedIdentifier) {
          tokens.add(CVUTokenNamedIdentifier(kw, ln, ch - kw.length - 1));
        } else {
          tokens.add(CVUTokenIdentifier(kw, ln, ch - kw.length));
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
          keyword.add(c);
          isMode = Mode.string;
        } else if (c == "\\") {
          isMode = Mode.escapedString;
        } else if (isMode == Mode.string && c == startChar) {
          if (isStringExpression) {
            tokens.add(CVUTokenStringExpression(
                keyword.join(), ln, ch - keyword.length));
          } else {
            tokens.add(CVUTokenString(keyword.join(), ln, ch - keyword.length));
          }

          keyword = [];
          isMode = Mode.idle;
          isStringExpression = false;
          return;
        } else {
          keyword.add(c);
        }

        if (c == "{") {
          isStringExpression = true;
        }

        return;
      }

      if (isMode == Mode.expression) {
        if (c == "}" && lastChar == "}") {
          CVUToken lastToken = tokens.removeLast();
          if (lastToken is CVUTokenCurlyBracketOpen) {
            keyword.removeLast();

            tokens.add(CVUTokenExpression(keyword.join(), ln, ch));
            keyword = [];
            isMode = Mode.idle;
          }
        } else {
          keyword.add(c);
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
          addToken(CVUTokenNewline(ln, ch));
          ln += 1;
          ch = 0;
          break;
        case "!":
          addToken(CVUTokenNegation(ln, ch));
          break;
        case "[":
          addToken(CVUTokenBracketOpen(ln, ch));
          break;
        case "]":
          addToken(CVUTokenBracketClose(ln, ch));
          break;
        case "=":
          addToken(CVUTokenOperator(CVUOperator.ConditionEquals, ln, ch));
          break;
        case ",":
          addToken(CVUTokenComma(ln, ch));
          break;
        case ":":
          addToken(CVUTokenColon(ln, ch));
          break;
        case ">":
          addToken(CVUTokenCaret(ln, ch));
          break;
        case ";":
          addToken(CVUTokenSemiColon(ln, ch));
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
          keyword.add(c);
          break;
        case "#":
          isMode = Mode.color;
          break;
        case "{":
          if (lastChar == "{") {
            isMode = Mode.expression;
          } else {
            addToken(CVUTokenCurlyBracketOpen(ln, ch));
          }
          break;
        case "}":
          addToken(CVUTokenCurlyBracketClose(ln, ch));
          break;
        case ".":
          if (isMode == Mode.idle) {
            isMode = Mode.namedIdentifier;
          } else if (isMode == Mode.number) {
            keyword.add(c);
          } else {
            continue defaultCase;
          }
          break;
        defaultCase:
        default:
          if (isMode == Mode.idle) {
            isMode = Mode.keyword;
          }
          keyword.add(c);
      }

      lastChar = c;
    });

    if (keyword.length > 0) {
      addToken();
    }

    if (isMode == Mode.string) {
      throw CVUParseErrorsMissingQuoteClose(CVUTokenEOF());
    } else if (isMode == Mode.expression) {
      throw CVUParseErrorsMissingExpressionClose(CVUTokenEOF());
    } else if (isMode != Mode.idle) {
      // TODO:
      throw Exception("Unhandled error mode: $isMode");
    }

    return tokens;
  }
}
