import 'package:memri/cvu/models/cvu_value_constant.dart';
import 'package:memri/cvu/models/cvu_value_expression.dart';
import 'package:memri/cvu/models/cvu_value_lookup_node.dart';

import 'cvu_expression_lexer.dart';

class CVUExpressionParseErrors extends Error {}

class CVUExpressionParseErrorsUnexpectedToken extends CVUExpressionParseErrors {
  ExprToken value;

  CVUExpressionParseErrorsUnexpectedToken(this.value);
}

class CVUExpressionParseErrorsUndefinedOperator
    extends CVUExpressionParseErrors {
  String value;

  CVUExpressionParseErrorsUndefinedOperator(this.value);
}

class CVUExpressionParseErrorsExpectedCharacter
    extends CVUExpressionParseErrors {
  String value;

  CVUExpressionParseErrorsExpectedCharacter(this.value);
}

class CVUExpressionParseErrorsExpectedExpression
    extends CVUExpressionParseErrors {
  ExprToken value;

  CVUExpressionParseErrorsExpectedExpression(this.value);
}

class CVUExpressionParseErrorsExpectedArgumentList
    extends CVUExpressionParseErrors {}

class CVUExpressionParseErrorsExpectedIdentifier
    extends CVUExpressionParseErrors {}

class CVUExpressionParseErrorsExpectedConditionElse
    extends CVUExpressionParseErrors {}

class CVUExpressionParseErrorsMissingQuoteClose
    extends CVUExpressionParseErrors {}

class CVUExpressionParser {
  List<ExprToken> tokens;
  var index = 0;
  ExprToken? lastToken;
  var countStringModeNodes = 0;

  CVUExpressionParser(this.tokens);

  ExprToken peekCurrentToken() {
    return index >= tokens.length ? ExprTokenEOF() : tokens[index];
  }

  ExprToken popCurrentToken() {
    if (index >= tokens.length) {
      lastToken = ExprTokenEOF();
      return ExprTokenEOF();
    }

    lastToken = tokens[index];
    index++;
    return lastToken ?? ExprTokenEOF(); // Check for out of bound?
  }

  CVUExpressionNode parse() {
    index = 0;
    var result = parseExpression();
    var token = popCurrentToken();
    if (token is ExprTokenEOF) {
      return result;
    }
    throw CVUExpressionParseErrorsUnexpectedToken(lastToken!);
  }

  CVUExpressionNode parseExpression() {
    var node = parsePrimary();
    return parseBinaryOp(node: node);
  }

  CVUExpressionNode parsePrimary([bool skipOperator = false]) {
    var token = peekCurrentToken();
    if (token is ExprTokenNegation) {
      return parseNegation();
    } else if (token is ExprTokenIdentifier) {
      return parseIdentifier();
    } else if (token is ExprTokenNumber) {
      return parseNumber();
    } else if (token is ExprTokenString) {
      return parseString();
    } else if (token is ExprTokenBool) {
      return parseBool();
    } else if (token is ExprTokenCurlyBracketOpen) {
      return parseCurlyBrackets();
    } else if (token is ExprTokenParensOpen) {
      return parseParens();
    } else if (token is ExprTokenPeriod) {
      return parsePeriod();
    } else if (token is ExprTokenOperator) {
      if (!skipOperator) return parseOperator();
    }
    throw CVUExpressionParseErrorsExpectedExpression(popCurrentToken());
  }

  CVUExpressionNode parseLookupExpression() {
    return parseExpression(); // TODO: maybe: This could be limited to int and string
  }

  CVUExpressionNode parseIntExpressionComponent() {
    return parsePrimary(true);
  }

  CVUExpressionNode parseNumber() {
    var token = popCurrentToken();
    if (token is! ExprTokenNumber) {
      throw CVUExpressionParseErrorsUnexpectedToken(lastToken!);
    }
    var value = token.value;
    return CVUExpressionNodeConstant(CVUConstantNumber(value));
  }

  CVUExpressionNode parseString() {
    var token = popCurrentToken();
    if (token is! ExprTokenString) {
      throw CVUExpressionParseErrorsUnexpectedToken(lastToken!);
    }
    var value = token.value;
    return CVUExpressionNodeConstant(CVUConstantString(value,
        isSingleQuote: token.isSingleQuote, isMultiline: token.isMultiline));
  }

  CVUExpressionNode parseBool() {
    var token = popCurrentToken();
    if (token is! ExprTokenBool) {
      throw CVUExpressionParseErrorsUnexpectedToken(lastToken!);
    }
    var value = token.value;
    return CVUExpressionNodeConstant(CVUConstantBool(value));
  }

  CVUExpressionNode parsePeriod() {
    var token = peekCurrentToken();
    if (token is! ExprTokenPeriod) {
      throw CVUExpressionParseErrorsUnexpectedToken(lastToken!);
    }

    return parseIdentifier(initialNode: CVULookupNode.defaultLookup);
  }

  CVUExpressionNode parseOperator() {
    var token = popCurrentToken();
    if (token is! ExprTokenOperator) {
      throw CVUExpressionParseErrorsUnexpectedToken(lastToken!);
    }
    var op = token.value;
    if (op == ExprOperator.Minus) {
      var exp = parseIntExpressionComponent();
      return CVUExpressionNodeSubtraction(
          CVUExpressionNodeConstant(CVUConstantNumber(0)), exp);
    } else if (op == ExprOperator.Plus) {
      var exp = parseIntExpressionComponent();
      return exp;
    } else {
      throw CVUExpressionParseErrorsUnexpectedToken(lastToken!);
    }
  }

  CVUExpressionNode parseNegation() {
    var token = popCurrentToken();
    if (token is! ExprTokenNegation) {
      throw CVUExpressionParseErrorsUnexpectedToken(lastToken!);
    }
    var exp = parsePrimary();

    return CVUExpressionNodeNegation(exp);
  }

  CVUExpressionNode parseCurlyBrackets() {
    var token = popCurrentToken();
    if (token is! ExprTokenCurlyBracketOpen) {
      throw CVUExpressionParseErrorsExpectedCharacter("{");
    }

    return parseStringMode();
  }

  CVUExpressionNode parseParens() {
    var token = popCurrentToken();
    if (token is! ExprTokenParensOpen) {
      throw CVUExpressionParseErrorsExpectedCharacter("(");
    }

    var exp = parseExpression();
    token = popCurrentToken();
    if (token is! ExprTokenParensClose) {
      throw CVUExpressionParseErrorsExpectedCharacter(")");
    }
    exp.inParens = true;
    return exp;
  }

  CVUExpressionNode parseIdentifier({CVULookupNode? initialNode}) {
    List<CVULookupNode> sequence = [];

    if (initialNode != null) {
      sequence.add(initialNode);
    }

    while (true) {
      var token = peekCurrentToken();
      if (token is ExprTokenIdentifier) {
        String name = token.value;
        popCurrentToken();
        token = peekCurrentToken();
        if (token is ExprTokenColon) {
          popCurrentToken();
          var exp = parseExpression();
          return CVUExpressionNodeNamed(name, exp);
        } else {
          sequence.add(CVULookupNode(name: name, type: CVULookupTypeLookup()));
        }
      }

      token = peekCurrentToken();
      if (token is ExprTokenBracketOpen) {
        popCurrentToken();
        if (sequence.isEmpty) {
          throw CVUExpressionParseErrorsExpectedIdentifier();
        }

        List<CVUExpressionNode> expressions = [];

        token = peekCurrentToken();
        if (token is ExprTokenBracketClose) {
          popCurrentToken();
        } else {
          ExpressionLoop:
          while (true) {
            var exp = parseLookupExpression();
            expressions.add(exp);

            token = peekCurrentToken();
            if (token is ExprTokenBracketClose) {
              popCurrentToken();
              break ExpressionLoop;
            }

            token = popCurrentToken();
            if (token is! ExprTokenComma) {
              throw CVUExpressionParseErrorsExpectedCharacter("]");
            }
          }
        }
        sequence.last.isArray = true;
        if (expressions.isNotEmpty) {
          sequence.last.type = CVULookupTypeLookup(expressions);
        }
      }

      token = peekCurrentToken();
      if (token is ExprTokenParensOpen) {
        popCurrentToken();
        List<CVUExpressionNode> arguments = [];

        token = peekCurrentToken();
        if (token is ExprTokenParensClose) {
          popCurrentToken();
        } else {
          ArgumentsLoop:
          while (true) {
            var argument = parseExpression();
            arguments.add(argument);

            token = peekCurrentToken();
            if (token is ExprTokenParensClose) {
              popCurrentToken();
              break ArgumentsLoop;
            }

            token = popCurrentToken();
            if (token is! ExprTokenComma) {
              throw CVUExpressionParseErrorsExpectedArgumentList();
            }
          }
        }

        if (sequence.isEmpty) {
          throw CVUExpressionParseErrorsExpectedIdentifier();
        }

        sequence.last.type = CVULookupTypeFunction(arguments);
      }

      var nextToken = peekCurrentToken();
      if (nextToken is ExprTokenPeriod) {
        popCurrentToken();
        continue;
      } else {
        break;
      }
    }

    return CVUExpressionNodeLookup(sequence);
  }

  int getCurrentTokenPrecedence() {
    if (index >= tokens.length) {
      return -1;
    }

    var nextToken = peekCurrentToken();
    if (nextToken is! ExprTokenOperator) {
      if (nextToken is ExprTokenCurlyBracketOpen) {
        return 1;
      }
      if (nextToken is ExprTokenCurlyBracketClose) {
        return 2;
      }

      return -1;
    }
    var op = nextToken.value;

    return op.precedence;
  }

  CVUExpressionNode parseBinaryOp(
      {CVUExpressionNode? node, int exprPrecedence = 0}) {
    var lhs = node!;
    while (true) {
      var tokenPrecedence = getCurrentTokenPrecedence();
      if (tokenPrecedence < exprPrecedence) {
        return lhs;
      }

      var nextToken = peekCurrentToken();
      if (nextToken is ExprTokenOperator) {
        var op = nextToken.value;
        if (op == ExprOperator.ConditionElse) return lhs;
      }
      if (nextToken is ExprTokenCurlyBracketClose) {
        return lhs;
      }

      var token = popCurrentToken();
      if (token is! ExprTokenOperator) {
        if (lastToken is ExprTokenCurlyBracketOpen) {
          return parseStringMode(lhs);
        }

        throw CVUExpressionParseErrorsUnexpectedToken(lastToken!);
      }

      var op = token.value;
      if (op == ExprOperator.ConditionStart) {
        return parseConditionOp(lhs);
      }

      var rhs = parsePrimary();
      var nextPrecedence = getCurrentTokenPrecedence();

      if (tokenPrecedence < nextPrecedence) {
        rhs = parseBinaryOp(node: rhs, exprPrecedence: tokenPrecedence + 1);
      }

      switch (op) {
        case ExprOperator.ConditionEquals:
          lhs = CVUExpressionNodeAreEqual(lhs, rhs);
          break;
        case ExprOperator.ConditionNotEquals:
          lhs = CVUExpressionNodeAreNotEqual(lhs, rhs);
          break;
        case ExprOperator.Plus:
          lhs = CVUExpressionNodeAddition(lhs, rhs);
          break;
        case ExprOperator.Minus:
          lhs = CVUExpressionNodeSubtraction(lhs, rhs);
          break;
        case ExprOperator.Multiplication:
          lhs = CVUExpressionNodeMultiplication(lhs, rhs);
          break;
        case ExprOperator.Division:
          lhs = CVUExpressionNodeDivision(lhs, rhs);
          break;
        case ExprOperator.ConditionOR:
          lhs = CVUExpressionNodeOr(lhs, rhs);
          break;
        case ExprOperator.ConditionGreaterThan:
          lhs = CVUExpressionNodeGreaterThan(lhs, rhs);
          break;
        case ExprOperator.ConditionGreaterThanOrEqual:
          lhs = CVUExpressionNodeGreaterThanOrEqual(lhs, rhs);
          break;
        case ExprOperator.ConditionLessThan:
          lhs = CVUExpressionNodeLessThan(lhs, rhs);
          break;
        case ExprOperator.ConditionLessThanOrEqual:
          lhs = CVUExpressionNodeLessThanOrEqual(lhs, rhs);
          break;
        case ExprOperator.ConditionAND:
          lhs = CVUExpressionNodeAnd(lhs, rhs);
          break;
        default:
          throw CVUExpressionParseErrorsUndefinedOperator(op.rawValue);
      }
    }
  }

  parseConditionOp(CVUExpressionNode conditionNode) {
    var trueExp = parseExpression();

    var token = popCurrentToken();
    if (token is! ExprTokenOperator) {
      throw CVUExpressionParseErrorsExpectedConditionElse();
    }
    var op = token.value;
    if (op != ExprOperator.ConditionElse) {
      throw CVUExpressionParseErrorsExpectedConditionElse();
    }

    var falseExp = parseExpression();

    return CVUExpressionNodeConditional(conditionNode, trueExp, falseExp);
  }

  CVUExpressionNode parseStringMode([CVUExpressionNode? firstNode]) {
    countStringModeNodes++;
    if (countStringModeNodes > 1) {
      throw CVUExpressionParseErrorsUnexpectedToken(lastToken!);
    }

    List<CVUExpressionNode> expressions = [];
    if (firstNode != null) {
      expressions.add(firstNode);
    }

    while (true) {
      var nextToken = peekCurrentToken();
      if (nextToken is ExprTokenEOF) {
        break;
      }
      if (nextToken is ExprTokenString) {
        expressions.add(parseString());
        continue;
      }
      if (nextToken is ExprTokenCurlyBracketOpen) {
        popCurrentToken();
      }

      expressions.add(parseExpression());
      var token = popCurrentToken();
      if (token is! ExprTokenCurlyBracketClose) {
        if (lastToken is ExprTokenEOF) {
          break;
        }
        throw CVUExpressionParseErrorsExpectedCharacter("}");
      }
    }

    return CVUExpressionNodeStringMode(expressions);
  }
}
