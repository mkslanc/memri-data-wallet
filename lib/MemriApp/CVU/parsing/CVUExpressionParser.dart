import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';

import 'CVUExpressionLexer.dart';

class CVUExpressionParseErrors extends Error {}

class CVUExpressionParseErrors_UnexpectedToken extends CVUExpressionParseErrors {
  ExprToken value;

  CVUExpressionParseErrors_UnexpectedToken(this.value);
}

class CVUExpressionParseErrors_UndefinedOperator extends CVUExpressionParseErrors {
  String value;

  CVUExpressionParseErrors_UndefinedOperator(this.value);
}

class CVUExpressionParseErrors_ExpectedCharacter extends CVUExpressionParseErrors {
  String value;

  CVUExpressionParseErrors_ExpectedCharacter(this.value);
}

class CVUExpressionParseErrors_ExpectedExpression extends CVUExpressionParseErrors {
  ExprToken value;

  CVUExpressionParseErrors_ExpectedExpression(this.value);
}

class CVUExpressionParseErrors_ExpectedArgumentList extends CVUExpressionParseErrors {}

class CVUExpressionParseErrors_ExpectedIdentifier extends CVUExpressionParseErrors {}

class CVUExpressionParseErrors_ExpectedConditionElse extends CVUExpressionParseErrors {}

class CVUExpressionParseErrors_MissingQuoteClose extends CVUExpressionParseErrors {}

class CVUExpressionParser {
  List<ExprToken> tokens;
  var index = 0;
  ExprToken? lastToken;
  var countStringModeNodes = 0;

  CVUExpressionParser(this.tokens);

  ExprToken peekCurrentToken() {
    return index >= tokens.length ? ExprToken_EOF() : tokens[index];
  }

  ExprToken popCurrentToken() {
    if (index >= tokens.length) {
      lastToken = ExprToken_EOF();
      return ExprToken_EOF();
    }

    lastToken = tokens[index];
    index++;
    return lastToken ?? ExprToken_EOF(); // Check for out of bound?
  }

  ExpressionNode parse() {
    index = 0;
    var result = parseExpression();
    var token = popCurrentToken();
    if (token is ExprToken_EOF) {
      return result;
    }
    throw CVUExpressionParseErrors_UnexpectedToken(lastToken!);
  }

  ExpressionNode parseExpression() {
    var node = parsePrimary();
    return parseBinaryOp(node: node);
  }

  ExpressionNode parsePrimary([bool skipOperator = false]) {
    var token = peekCurrentToken();
    if (token is ExprToken_Negation) {
      return parseNegation();
    } else if (token is ExprToken_Identifier) {
      return parseIdentifier();
    } else if (token is ExprToken_Number) {
      return parseNumber();
    } else if (token is ExprToken_String) {
      return parseString();
    } else if (token is ExprToken_Bool) {
      return parseBool();
    } else if (token is ExprToken_CurlyBracketOpen) {
      return parseCurlyBrackets();
    } else if (token is ExprToken_ParensOpen) {
      return parseParens();
    } else if (token is ExprToken_Period) {
      return parsePeriod();
    } else if (token is ExprToken_Operator) {
      if (!skipOperator) return parseOperator();
    }
    throw CVUExpressionParseErrors_ExpectedExpression(popCurrentToken());
  }

  ExpressionNode parseLookupExpression() {
    return parseExpression(); // TODO: maybe: This could be limited to int and string
  }

  ExpressionNode parseIntExpressionComponent() {
    return parsePrimary(true);
  }

  ExpressionNode parseNumber() {
    var token = popCurrentToken();
    if (token is! ExprToken_Number) {
      throw CVUExpressionParseErrors_UnexpectedToken(lastToken!);
    }
    var value = token.value;
    return ExpressionNode.constant(CVUValue_Constant.number(value!));
  }

  ExpressionNode parseString() {
    var token = popCurrentToken();
    if (token is! ExprToken_String) {
      throw CVUExpressionParseErrors_UnexpectedToken(lastToken!);
    }
    var value = token.value;
    return ExpressionNode.constant(CVUValue_Constant.string(value!));
  }

  ExpressionNode parseBool() {
    var token = popCurrentToken();
    if (token is! ExprToken_Bool) {
      throw CVUExpressionParseErrors_UnexpectedToken(lastToken!);
    }
    var value = token.value;
    return ExpressionNode.constant(CVUValue_Constant.bool(value!));
  }

  ExpressionNode parsePeriod() {
    var token = peekCurrentToken();
    if (token is! ExprToken_Period) {
      throw CVUExpressionParseErrors_UnexpectedToken(lastToken!);
    }

    return parseIdentifier(initialNode: LookupNode.defaultLookup);
  }

  ExpressionNode parseOperator() {
    var token = popCurrentToken();
    if (token is! ExprToken_Operator) {
      throw CVUExpressionParseErrors_UnexpectedToken(lastToken!);
    }
    var op = token.value;
    if (op == ExprOperator.Minus) {
      var exp = parseIntExpressionComponent();
      return ExpressionNode.subtraction(ExpressionNode.constant(CVUValue_Constant.number(0)), exp);
    } else if (op == ExprOperator.Plus) {
      var exp = parseIntExpressionComponent();
      return exp;
    } else {
      throw CVUExpressionParseErrors_UnexpectedToken(lastToken!);
    }
  }

  ExpressionNode parseNegation() {
    var token = popCurrentToken();
    if (token is! ExprToken_Negation) {
      throw CVUExpressionParseErrors_UnexpectedToken(lastToken!);
    }
    var exp = parsePrimary();

    return ExpressionNode.negation(exp);
  }

  ExpressionNode parseCurlyBrackets() {
    var token = popCurrentToken();
    if (token is! ExprToken_CurlyBracketOpen) {
      throw CVUExpressionParseErrors_ExpectedCharacter("{");
    }

    return parseStringMode();
  }

  ExpressionNode parseParens() {
    var token = popCurrentToken();
    if (token is! ExprToken_ParensOpen) {
      throw CVUExpressionParseErrors_ExpectedCharacter("(");
    }

    var exp = parseExpression();
    token = popCurrentToken();
    if (token is! ExprToken_ParensClose) {
      throw CVUExpressionParseErrors_ExpectedCharacter(")");
    }

    return exp;
  }

  ExpressionNode parseIdentifier({LookupNode? initialNode}) {
    List<LookupNode> sequence = [];

    if (initialNode != null) {
      sequence.add(initialNode);
    }

    while (true) {
      var token = peekCurrentToken();
      if (token is ExprToken_Identifier) {
        String name = token.value;
        popCurrentToken();
        sequence.add(LookupNode(name: name, type: LookupType.lookup()));
      }

      token = peekCurrentToken();
      if (token is ExprToken_BracketOpen) {
        popCurrentToken();
        if (sequence.isEmpty) {
          throw CVUExpressionParseErrors_ExpectedIdentifier();
        }

        token = peekCurrentToken();
        if (token is ExprToken_BracketClose) {
          popCurrentToken();
          sequence[sequence.length - 1].isArray = true; //TODO:
        } else {
          var exp = parseLookupExpression();
          sequence[sequence.length - 1].type = LookupType.lookup(exp);

          token = popCurrentToken();
          if (token is! ExprToken_BracketClose) {
            throw CVUExpressionParseErrors_ExpectedCharacter("]");
          }
        }
      }

      token = peekCurrentToken();
      if (token is ExprToken_ParensOpen) {
        popCurrentToken();
        List<ExpressionNode> arguments = [];

        token = peekCurrentToken();
        if (token is ExprToken_ParensClose) {
          popCurrentToken();
        } else {
          ArgumentsLoop:
          while (true) {
            var argument = parseExpression();
            arguments.add(argument);

            token = peekCurrentToken();
            if (token is ExprToken_ParensClose) {
              popCurrentToken();
              break ArgumentsLoop;
            }

            token = popCurrentToken();
            if (token is! ExprToken_Comma) {
              throw CVUExpressionParseErrors_ExpectedArgumentList();
            }
          }
        }

        if (sequence.isEmpty) {
          throw CVUExpressionParseErrors_ExpectedIdentifier();
        }

        sequence[sequence.length - 1].type = LookupType.function(arguments);
      }

      var nextToken = peekCurrentToken();
      if (nextToken is ExprToken_Period) {
        popCurrentToken();
        continue;
      } else {
        break;
      }
    }

    return ExpressionNode.lookup(sequence);
  }

  int? getCurrentTokenPrecedence() {
    if (index >= tokens.length) {
      return -1;
    }

    var nextToken = peekCurrentToken();
    if (nextToken is! ExprToken_Operator) {
      if (nextToken is ExprToken_CurlyBracketOpen) {
        return 1;
      }
      if (nextToken is ExprToken_CurlyBracketClose) {
        return 2;
      }

      return -1;
    }
    var op = nextToken.value;

    return ExprOperator.precedence(op); //TODO:
  }

  ExpressionNode parseBinaryOp({ExpressionNode? node, int exprPrecedence = 0}) {
    var lhs = node!;
    while (true) {
      var tokenPrecedence = getCurrentTokenPrecedence();
      if (tokenPrecedence! < exprPrecedence) {
        return lhs;
      }

      var nextToken = peekCurrentToken();
      if (nextToken is ExprToken_Operator) {
        var op = nextToken.value;
        if (op == ExprOperator.ConditionElse) return lhs;
      }
      if (nextToken is ExprToken_CurlyBracketClose) {
        return lhs;
      }

      var token = popCurrentToken();
      if (token is! ExprToken_Operator) {
        if (lastToken is ExprToken_CurlyBracketOpen) {
          return parseStringMode(lhs);
        }

        throw CVUExpressionParseErrors_UnexpectedToken(lastToken!);
      }

      var op = token.value;
      if (op == ExprOperator.ConditionStart) {
        return parseConditionOp(lhs);
      }

      var rhs = parsePrimary();
      var nextPrecedence = getCurrentTokenPrecedence();

      if (tokenPrecedence < nextPrecedence!) {
        rhs = parseBinaryOp(node: rhs, exprPrecedence: tokenPrecedence + 1);
      }

      switch (op) {
        case ExprOperator.ConditionEquals:
          lhs = ExpressionNode.areEqual(lhs, rhs);
          break;
        case ExprOperator.ConditionNotEquals:
          lhs = ExpressionNode.areNotEqual(lhs, rhs);
          break;
        case ExprOperator.Plus:
          lhs = ExpressionNode.addition(lhs, rhs);
          break;
        case ExprOperator.Minus:
          lhs = ExpressionNode.subtraction(lhs, rhs);
          break;
        case ExprOperator.Multiplication:
          lhs = ExpressionNode.multiplication(lhs, rhs);
          break;
        case ExprOperator.Division:
          lhs = ExpressionNode.division(lhs, rhs);
          break;
        case ExprOperator.ConditionOR:
          lhs = ExpressionNode.or(lhs, rhs);
          break;
        case ExprOperator.ConditionGreaterThan:
          lhs = ExpressionNode.greaterThan(lhs, rhs);
          break;
        case ExprOperator.ConditionGreaterThanOrEqual:
          lhs = ExpressionNode.greaterThanOrEqual(lhs, rhs);
          break;
        case ExprOperator.ConditionLessThan:
          lhs = ExpressionNode.lessThan(lhs, rhs);
          break;
        case ExprOperator.ConditionLessThanOrEqual:
          lhs = ExpressionNode.lessThanOrEqual(lhs, rhs);
          break;
        case ExprOperator.ConditionAND:
          lhs = ExpressionNode.and(lhs, rhs);
          break;
        default:
          throw CVUExpressionParseErrors_UndefinedOperator(op!);
      }
    }
  }

  parseConditionOp(ExpressionNode conditionNode) {
    var trueExp = parseExpression();

    var token = popCurrentToken();
    if (token is! ExprToken_Operator) {
      throw CVUExpressionParseErrors_ExpectedConditionElse();
    }
    var op = token.value;
    if (op != ExprOperator.ConditionElse) {
      throw CVUExpressionParseErrors_ExpectedConditionElse();
    }

    var falseExp = parseExpression();

    return ExpressionNode.conditional(conditionNode, trueExp, falseExp);
  }

  ExpressionNode parseStringMode([ExpressionNode? firstNode]) {
    countStringModeNodes++;
    if (countStringModeNodes > 1) {
      throw CVUExpressionParseErrors_UnexpectedToken(lastToken!);
    }

    List<ExpressionNode> expressions = [];
    if (firstNode != null) {
      expressions.add(firstNode);
    }

    while (true) {
      var nextToken = peekCurrentToken();
      if (nextToken is ExprToken_EOF) {
        break;
      }
      if (nextToken is ExprToken_String) {
        expressions.add(parseString());
        continue;
      }
      if (nextToken is ExprToken_CurlyBracketOpen) {
        popCurrentToken();
      }

      expressions.add(parseExpression());
      var token = popCurrentToken();
      if (token is! ExprToken_CurlyBracketClose) {
        if (lastToken is ExprToken_EOF) {
          break;
        }
        throw CVUExpressionParseErrors_ExpectedCharacter("}");
      }
    }

    return ExpressionNode.stringMode(expressions);
  }
}
