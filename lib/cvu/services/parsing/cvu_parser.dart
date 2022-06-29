// Copyright © 2020 memri. All rights reserved.

import 'package:memri/cvu/models/cvu_lexer.dart';
import 'package:memri/cvu/models/cvu_parsed_definition.dart';
import 'package:memri/cvu/models/cvu_ui_element_family.dart';
import 'package:memri/cvu/models/cvu_ui_node.dart';
import 'package:memri/cvu/models/cvu_value.dart';
import 'package:memri/cvu/models/cvu_value_constant.dart';
import 'package:memri/cvu/models/cvu_value_expression.dart';

import 'cvu_parse_errors.dart';

class CVUParser {
  final List<CVUToken> tokens;
  int index = 0;
  CVUToken? lastToken;

  CVUParser(this.tokens);

  CVUToken peekCurrentToken() {
    return index >= tokens.length ? CVUTokenEOF() : tokens[index];
  }

  CVUToken popCurrentToken() {
    if (index >= tokens.length) {
      lastToken = CVUTokenEOF();
      return lastToken!;
    }

    lastToken = tokens[index];
    index += 1;
    return lastToken!; // Check for out of bound?
  }

  List<CVUParsedDefinition> parse() {
    index = 0;
    List<CVUParsedDefinition> result = [];

    while (true) {
      if (peekCurrentToken() is CVUTokenEOF) {
        return result;
      }
      if (peekCurrentToken() is CVUTokenNewline) {
        popCurrentToken();
        continue;
      }

      var dsl = parseViewDSL();
      if (dsl.get("sessions") != null) {
        dsl.type = CVUDefinitionType.sessions;
      } else if (dsl.get("views") != null) {
        dsl.type = CVUDefinitionType.views;
      }

      result.add(dsl);
    }
  }

  CVUParsedDefinition parseViewDSL() {
    CVUParsedDefinition node = parsePrimary();

    if (peekCurrentToken() is CVUTokenColon) {
      popCurrentToken();
    }

    return parseDefinition(node);
  }

  CVUParsedDefinition parsePrimary([bool skipOperator = false]) {
    var currentToken = peekCurrentToken();
    if (currentToken is CVUTokenIdentifier) {
      return parseIdentifierSelector();
    } else if (currentToken is CVUTokenNamedIdentifier) {
      return parseNamedIdentifierSelector();
    } else if (currentToken is CVUTokenBracketOpen) {
      return parseBracketsSelector();
    } else if (currentToken is CVUTokenString) {
      return parseStringSelector();
    } else {
      throw CVUParseErrorsExpectedDefinition(popCurrentToken());
    }
  }

  CVUParsedDefinition parseIdentifierSelector() {
    // Example: Person {
    CVUToken token = popCurrentToken();
    if (token is! CVUTokenIdentifier) {
      throw CVUParseErrorsExpectedIdentifier(lastToken!);
    }
    String typeIdentifier = token.value;

    // Example: Person[name = 'john']
    if (peekCurrentToken() is CVUTokenBracketOpen) {
      popCurrentToken();
      if (peekCurrentToken() is CVUTokenBracketClose) {
        popCurrentToken();
        typeIdentifier += "[]";
      } else {
        // TODO:
      }
    }

    if (peekCurrentToken() is CVUTokenCaret) {
      popCurrentToken();
      CVUToken token = popCurrentToken();
      if (token is! CVUTokenIdentifier) {
        throw CVUParseErrorsExpectedIdentifier(lastToken!);
      }
      return CVUParsedDefinition(
          type: CVUDefinitionType.uiNode,
          selector: typeIdentifier,
          renderer: token.value);
    }

    return CVUParsedDefinition(
        type: CVUDefinitionType.view, selector: typeIdentifier);
  }

  CVUParsedDefinition parseNamedIdentifierSelector() {
    // Example: "Some Name" {
    CVUToken token = popCurrentToken();
    if (token is! CVUTokenNamedIdentifier) {
      throw CVUParseErrorsUnexpectedToken(lastToken!);
    }
    String name = token.value;

    return CVUParsedDefinition(
        type: CVUDefinitionType.view, selector: ".$name", name: name);
  }

  // For JSON support
  CVUParsedDefinition parseStringSelector() {
    CVUToken token = popCurrentToken();
    if (token is! CVUTokenString) {
      throw CVUParseErrorsUnexpectedToken(lastToken!);
    }
    String value = token.value;

    if (value.startsWith(".")) {
      return CVUParsedDefinition(
          type: CVUDefinitionType.view,
          selector: value,
          name: value.substring(0, 1));
    } else if (value.startsWith("[")) {
      throw Exception("Not supported yet"); // TODO:
    } else {
      return CVUParsedDefinition(type: CVUDefinitionType.view, selector: value);
    }
  }

  CVUParsedDefinition parseBracketsSelector([CVUToken? token]) {
    CVUToken tokenT = token ?? popCurrentToken();
    if (tokenT is! CVUTokenBracketOpen) {
      throw CVUParseErrorsExpectedCharacter("[", lastToken!);
    }
    CVUToken typeToken = token ?? lastToken!;

    tokenT = popCurrentToken();
    if (tokenT is! CVUTokenIdentifier) {
      throw CVUParseErrorsExpectedIdentifier(lastToken!);
    }
    String type = tokenT.value;

    // TODO: Only allow inside other definition
    if (["session", "view"].contains(type) &&
        peekCurrentToken() is CVUTokenBracketClose) {
      popCurrentToken();
      switch (type) {
        case "session":
          return CVUParsedDefinition(selector: "[session]");
        case "view":
          return CVUParsedDefinition(selector: "[view]");
      }
    }

    tokenT = popCurrentToken();
    if (tokenT is! CVUTokenOperator) {
      throw CVUParseErrorsExpectedCharacter("=", lastToken!);
    }
    CVUOperator op = tokenT.value;

    if (CVUOperator.ConditionEquals == op) {
      String name;
      tokenT = popCurrentToken();
      if (tokenT is CVUTokenString) {
        name = tokenT.value;
      } else if (lastToken is CVUTokenIdentifier) {
        name = (lastToken as CVUTokenIdentifier).value;
      } else {
        throw CVUParseErrorsExpectedString(lastToken!);
      }

      tokenT = popCurrentToken();
      if (tokenT is! CVUTokenBracketClose) {
        throw CVUParseErrorsExpectedCharacter("]", lastToken!);
      }

      switch (type) {
        case "sessions":
          return CVUParsedDefinition(
              type: CVUDefinitionType.sessions,
              selector: "[sessions = $name]",
              name: name);
        case "session":
          return CVUParsedDefinition(
              type: CVUDefinitionType.views,
              selector: "[session = $name]",
              name: name);
        case "view":
          return CVUParsedDefinition(
              type: CVUDefinitionType.view,
              selector: "[view = $name]",
              name: name);
        case "datasource":
          return CVUParsedDefinition(
              type: CVUDefinitionType.datasource,
              selector: "[datasource = $name]",
              name: name);
        case "renderer":
          return CVUParsedDefinition(
              type: CVUDefinitionType.renderer,
              selector: "[renderer = $name]",
              name: name);
        case "language":
          return CVUParsedDefinition(
              type: CVUDefinitionType.language,
              selector: "[language = $name]",
              name: name);
        default:
          throw CVUParseErrorsUnknownDefinition(type, typeToken);
      }
    } else {
      throw CVUParseErrorsExpectedCharacter("=", lastToken!);
    }
  }

  CVUExpressionNode createExpression(String code,
      [bool startInStringMode = false]) {
    return CVUExpressionNode.create(code, startInStringMode);
  }

  CVUDefinitionContent parseDict([String? uiElementName]) {
    CVUDefinitionContent parsedContent = CVUDefinitionContent();

    List<CVUValue> stack = [];

    String? lastKey;
    bool isArrayMode = false;

    setPropertyValue() {
      if (lastKey != null && lastKey.isNotEmpty) {
        if (isArrayMode || stack.length > 1) {
          parsedContent.properties[lastKey] = CVUValueArray(stack);
        } else if (stack.length > 0) {
          parsedContent.properties[lastKey] = stack.first;
        }
        stack = [];
      }
    }

    addUIElement(CVUUIElementFamily type, CVUDefinitionContent properties,
        CVUToken token) {
      parsedContent.children.add(CVUUINode(
          type: type,
          children: properties.children,
          properties: properties.properties,
          tokenLocation: token.location));
    }

    while (true) {
      CVUToken token = popCurrentToken();
      if (token is CVUTokenBool) {
        stack.add(CVUValueConstant(CVUConstantBool(token.value),
            tokenLocation: token.location));
      } else if (token is CVUTokenBracketOpen) {
        if (stack.length == 0 && lastKey != null) {
          isArrayMode = true;
        } else {
          setPropertyValue();

          var definition = parseBracketsSelector(lastToken!);
          definition = parseDefinition(definition);
          parsedContent.definitions.add(definition);
        }
      } else if (token is CVUTokenBracketClose) {
        if (isArrayMode) {
          setPropertyValue();
          isArrayMode = false;
          lastKey = null;
        } else {
          throw CVUParseErrorsUnexpectedToken(
              lastToken!); // We should never get here
        }
      } else if (token is CVUTokenCurlyBracketOpen) {
        if (lastKey == null) {
          throw CVUParseErrorsExpectedIdentifier(lastToken!);
        }

        stack.add(CVUValueSubdefinition(parseDict(lastKey),
            tokenLocation: token.location));
      } else if (token is CVUTokenCurlyBracketClose) {
        setPropertyValue();
        return parsedContent; // DONE
      } else if (token is CVUTokenColon) {
        throw CVUParseErrorsExpectedKey(lastToken!);
      } else if (token is CVUTokenExpression) {
        stack.add(CVUValueExpression(createExpression(token.value),
            tokenLocation: token.location));
      } else if (token is CVUTokenIdentifier) {
        var v = token.value;
        if (lastKey == null) {
          CVUToken nextToken = peekCurrentToken();
          if (nextToken is CVUTokenColon) {
            popCurrentToken();
            lastKey = v;
            nextToken = peekCurrentToken();
          }

          var type = CVUUIElementFamilyExtension.rawValue(v.toLowerCase());
          if (lastKey == null && type != null) {
            var properties = CVUDefinitionContent();
            if (nextToken is CVUTokenCurlyBracketOpen) {
              popCurrentToken();
              properties = parseDict(v);
            }

            addUIElement(type, properties, token);
          } else if (v == "userstate" ||
              v == "viewarguments" ||
              v == "contextpane") {
            if (nextToken is CVUTokenCurlyBracketOpen) {
              popCurrentToken();
              CVUDefinitionContent properties = parseDict();
              stack.add(CVUValueSubdefinition(properties,
                  tokenLocation: token.location));
            }
          } else if (nextToken is CVUTokenCurlyBracketOpen) {
            lastKey = v;
          } else if (nextToken is CVUTokenCaret) {
            index -= 1; // TODO better way of
            CVUParsedDefinition identifierNode = parseIdentifierSelector();
            parsedContent.definitions.add(parseDefinition(identifierNode));
          }
        } else {
          stack.add(CVUValueConstant(CVUConstantArgument(v),
              tokenLocation: token.location));
        }
      } else if (token is CVUTokenNewline ||
          token is CVUTokenComma ||
          token is CVUTokenSemiColon) {
        if (token is CVUTokenNewline || token is CVUTokenComma) {
          if (token is CVUTokenNewline && stack.length == 0) {
            continue;
          }
          if (isArrayMode) {
            continue;
          }
        }
        setPropertyValue();
        lastKey = null;
      } else if (token is CVUTokenNil) {
        stack.add(
            CVUValueConstant(CVUConstantNil(), tokenLocation: token.location));
      } else if (token is CVUTokenNumber) {
        stack.add(CVUValueConstant(CVUConstantNumber(token.value),
            tokenLocation: token.location));
      } else if (token is CVUTokenString) {
        var v = token.value;
        if (!isArrayMode && (peekCurrentToken() is CVUTokenColon)) {
          setPropertyValue(); // TODO: Is this every necessary?
          popCurrentToken();
          lastKey = v;
        } else if (lastKey == null) {
          lastKey = v;
        } else {
          stack.add(CVUValueConstant(CVUConstantString(v),
              tokenLocation: token.location));
        }
      } else if (token is CVUTokenStringExpression) {
        stack.add(CVUValueExpression(createExpression(token.value, true),
            tokenLocation: token.location));
      } else if (token is CVUTokenColor) {
        stack.add(CVUValueConstant(CVUConstantColorHex(token.value),
            tokenLocation: token.location));
      } else {
        throw CVUParseErrorsUnexpectedToken(lastToken!);
      }
    }
  }

  CVUParsedDefinition parseDefinition(CVUParsedDefinition selector) {
    while (true) {
      if (peekCurrentToken() is CVUTokenNewline) {
        popCurrentToken();
      } else {
        if (this.popCurrentToken() is! CVUTokenCurlyBracketOpen) {
          throw CVUParseErrorsExpectedCharacter("{", this.lastToken!);
        }
        break;
      }
    }
    var parsedVersion = selector;
    parsedVersion.parsed = parseDict();
    return parsedVersion;
  }
}
