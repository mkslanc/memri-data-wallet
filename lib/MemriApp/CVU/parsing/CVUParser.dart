//
// CVUParser.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUUIElementFamily.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUUINode.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';

import 'CVULexer.dart';
import 'CVUParseErrors.dart';

class CVUParser {
  final List<CVUToken> tokens;
  int index = 0;
  CVUToken? lastToken;

  CVUParser(this.tokens);

  CVUToken peekCurrentToken() {
    return index >= tokens.length ? CVUToken.EOF() : tokens[index];
  }

  CVUToken popCurrentToken() {
    if (index >= tokens.length) {
      lastToken = CVUToken.EOF();
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
      if (CVUTokenType.EOF == peekCurrentToken().type) { return result; }
      if (CVUTokenType.Newline == peekCurrentToken().type) {
        popCurrentToken();
        continue;
      }

      var dsl = parseViewDSL();
      if (dsl.get("sessions") != null) {
        dsl.type = CVUDefinitionType.sessions;
      }
      else if (dsl.get("views") != null) {
        dsl.type = CVUDefinitionType.views;
      }

      result.add(dsl);
    }
  }

  CVUParsedDefinition parseViewDSL() {
    CVUParsedDefinition node = parsePrimary();

    if (CVUTokenType.Colon == peekCurrentToken().type) {
      popCurrentToken();
    }

    return parseDefinition(node);
  }

  CVUParsedDefinition parsePrimary([bool skipOperator = false]) {
    switch (peekCurrentToken().type) {
      case CVUTokenType.Identifier:
        return parseIdentifierSelector();
      case CVUTokenType.NamedIdentifier:
        return parseNamedIdentifierSelector();
      case CVUTokenType.BracketOpen:
        return parseBracketsSelector();
      case CVUTokenType.String:
        return parseStringSelector();
      default:
        throw CVUParseErrors.ExpectedDefinition(popCurrentToken());
    }
  }

  CVUParsedDefinition parseIdentifierSelector() {
    // Example: Person {
    CVUToken token = popCurrentToken();
    if (token.type != CVUTokenType.Identifier) {
      throw CVUParseErrors.ExpectedIdentifier(lastToken!);
    }
    String typeIdentifier = token.value;

    // Example: Person[name = 'john']
    if (CVUTokenType.BracketOpen == peekCurrentToken().type) {
      popCurrentToken();
      if (CVUTokenType.BracketClose == peekCurrentToken().type) {
        popCurrentToken();
        typeIdentifier += "[]";
      }
      else {
      // TODO:
      }
    }

    if (CVUTokenType.Caret == peekCurrentToken().type) {
      popCurrentToken();
      CVUToken token = popCurrentToken();
      if (token.type != CVUTokenType.Identifier) {
        throw CVUParseErrors.ExpectedIdentifier(lastToken!);
      }
      return CVUParsedDefinition(type: CVUDefinitionType.uiNode, selector: typeIdentifier, renderer: token.value);
    }

    return CVUParsedDefinition(type: CVUDefinitionType.view, selector: typeIdentifier/*TODO @mkslanc .replace(/\./)*/);
  }

  CVUParsedDefinition parseNamedIdentifierSelector() {
    // Example: "Some Name" {
    CVUToken token = popCurrentToken();
    if (token.type != CVUTokenType.NamedIdentifier) {
      throw CVUParseErrors.UnexpectedToken(lastToken!);
    }
    String name = token.value;

    return CVUParsedDefinition(type: CVUDefinitionType.view, selector: ".$name", name: name);
  }

  // For JSON support
  CVUParsedDefinition parseStringSelector() {
    CVUToken token = popCurrentToken();
    if (token.type != CVUTokenType.String) {
      throw CVUParseErrors.UnexpectedToken(lastToken!);
    }
    String value = token.value;

    if (value.startsWith(".")) {
      return CVUParsedDefinition(
          type: CVUDefinitionType.view,
          selector: value,
          name: value.substring(0, 1)
      );
    }
    else if (value.startsWith("[")) {
      throw Exception("Not supported yet"); // TODO:
    }
    else {
      return CVUParsedDefinition(type: CVUDefinitionType.view, selector: value);
    }
  }

  CVUParsedDefinition parseBracketsSelector([CVUToken? token]) {
    CVUToken tokenT = token ?? popCurrentToken();
    if (tokenT.type != CVUTokenType.BracketOpen) {
      throw CVUParseErrors.ExpectedCharacter("[", lastToken!);
    }
    CVUToken typeToken = token ?? lastToken!;

    tokenT = popCurrentToken();
    if (tokenT.type != CVUTokenType.Identifier) {
      throw CVUParseErrors.ExpectedIdentifier(lastToken!);
    }
    String type = tokenT.value;

    // TODO: Only allow inside other definition
    if (["session", "view"].contains(type) && CVUTokenType.BracketClose == peekCurrentToken().type) {
      popCurrentToken();
      switch (type) {
        case "session": return CVUParsedDefinition(selector: "[session]");
        case "view": return CVUParsedDefinition(selector: "[view]");
        // default: return; // Can never get here
      }
    }

    tokenT = popCurrentToken();
    if (tokenT.type != CVUTokenType.Operator) {
      throw CVUParseErrors.ExpectedCharacter("=", lastToken!);
    }
    CVUOperator op = tokenT.value;

    if (CVUOperator.ConditionEquals == op) {
      String name;
      tokenT = popCurrentToken();
      if (CVUTokenType.String == tokenT.type) {
        name = tokenT.value;
      } else if (CVUTokenType.Identifier == lastToken?.type) {
        name = lastToken?.value;
      } else {
        throw CVUParseErrors.ExpectedString(lastToken!);
      }

      tokenT = popCurrentToken();
      if (tokenT.type != CVUTokenType.BracketClose) {
        throw CVUParseErrors.ExpectedCharacter("]", lastToken!);
      }

        switch (type) {
          case "sessions": return CVUParsedDefinition(type: CVUDefinitionType.sessions, selector: "[sessions = $name]", name: name);
          case "session": return CVUParsedDefinition(type: CVUDefinitionType.views, selector: "[session = $name]", name: name);
          case "view": return CVUParsedDefinition(type: CVUDefinitionType.view, selector: "[view = $name]", name: name);
          case "datasource": return CVUParsedDefinition(type: CVUDefinitionType.datasource, selector: "[datasource = $name]", name: name);
          case "renderer": return CVUParsedDefinition(type: CVUDefinitionType.renderer, selector: "[renderer = $name]", name: name);
          case "language": return CVUParsedDefinition(type: CVUDefinitionType.language, selector: "[language = $name]", name: name);
          default:
            throw CVUParseErrors.UnknownDefinition(type, typeToken);
        }
    }
    else {
      throw CVUParseErrors.ExpectedCharacter("=", lastToken!);
    }
  }

  ExpressionNode createExpression(String code, [bool startInStringMode = false]) {
    return ExpressionNode.create(code, startInStringMode);
  }

  CVUDefinitionContent parseDict([String? uiElementName]) {
    CVUDefinitionContent parsedContent = CVUDefinitionContent();

    List<CVUValue> stack = [];

    String? lastKey;
    bool isArrayMode = false;

    setPropertyValue() {
      if (lastKey != null && lastKey.isNotEmpty) {
        if (isArrayMode || stack.length > 1) {
          parsedContent.properties[lastKey] = CVUValue.array(stack);
        } else if (stack.length > 0) {
          parsedContent.properties[lastKey] = stack.first;
        }
        stack = [];
      }
    }

    addUIElement(CVUUIElementFamily type, CVUDefinitionContent properties) {
      parsedContent.children.add(CVUUINode(
          type: type,
          children: properties.children,
          properties: properties.properties
      ));
    }

    while (true) {
//            print(peekCurrentToken())


      CVUToken token = popCurrentToken();
      var v = token.value;
      switch (token.type) {
        case CVUTokenType.Bool:
          stack.add(CVUValue.constant(CVUValue_Constant.bool(v)));
          break;
        case CVUTokenType.BracketOpen:
          if (stack.length == 0 && lastKey != null) {
            isArrayMode = true;
          } else {
            setPropertyValue();

            var definition = parseBracketsSelector(lastToken!);
            definition = parseDefinition(definition);
            parsedContent.definitions.add(definition);
          }
          break;
        case CVUTokenType.BracketClose:
          if (isArrayMode) {
            setPropertyValue();
            isArrayMode = false;
            lastKey = null;
          } else {
            throw CVUParseErrors.UnexpectedToken(
                lastToken!); // We should never get here
          }
          break;
        case CVUTokenType.CurlyBracketOpen:
          if (!(lastKey!.isNotEmpty)) {
            throw CVUParseErrors.ExpectedIdentifier(lastToken!);
          }

          stack.add(CVUValue.subdefinition(parseDict(lastKey)));
          break;
        case CVUTokenType.CurlyBracketClose:
          setPropertyValue();
          return parsedContent; // DONE
        case CVUTokenType.Colon:
          throw CVUParseErrors.ExpectedKey(lastToken!);
        case CVUTokenType.Expression:
          stack.add(CVUValue.expression(createExpression(v)));
          break;
        case CVUTokenType.Identifier:
          if (lastKey == null) {
            CVUToken nextToken = peekCurrentToken();
            if (CVUTokenType.Colon == nextToken.type) {
              popCurrentToken();
              lastKey = v;
              nextToken = peekCurrentToken();
            }

            CVUUIElementFamily? type = CVUUIElementFamilyExtension.rawValue(v.toLowerCase());
            if (lastKey == null && (type != CVUUIElementFamily.Null)) {
              var properties = CVUDefinitionContent();
              if (CVUTokenType.CurlyBracketOpen == nextToken.type) {
                popCurrentToken();
                properties = parseDict(v);
              }

              addUIElement(type, properties);
            }
            else if (v == "userstate" || v == "viewarguments" || v == "contextpane") {
              if (CVUTokenType.CurlyBracketOpen == nextToken.type) {
                popCurrentToken();
                CVUDefinitionContent properties = parseDict();
                stack.add(CVUValue.subdefinition(properties));
              }
            }
            else if (CVUTokenType.CurlyBracketOpen == nextToken.type) {
              lastKey = v;
            } else if (CVUTokenType.Caret == nextToken.type) {
              index -= 1; // TODO better way of
              CVUParsedDefinition identifierNode = parseIdentifierSelector();
              parsedContent.definitions.add(parseDefinition(identifierNode));
            }
          }
          // else if (knownActions[v.toLowerCase()]) {
          //     let name = knownActions[v.toLowerCase()];
          //     if (name) {
          //         var options = MemriDictionary();
          //         outerLoop: while (true) {
          //             switch (peekCurrentToken().type) {
          //                 case CVUTokenType.Comma:
          //                     if (isArrayMode) {
          //                         popCurrentToken()
          //                     }
          //                     break;
          //                 case CVUTokenType.CurlyBracketOpen:
          //                     popCurrentToken();
          //                     options = parseDict();
          //                     break;
          //                 default:
          //                     break outerLoop;
          //             }
          //         }
          //
          //         //let argumentsJs = options["arguments"] ? Object.assign({}, options["arguments"]) : {} //TODO:
          //         //delete options["arguments"];
          //         let actionFamily = ActionFamily[name];
          //         if (actionFamily) {
          //             //TODO:
          //             let ActionType = getActionType(actionFamily);//TODO:
          //             stack.add(ActionType(context, options));//[context, arguments, options]
          //             //stack.add(actionFamily)
          //         } else {
          //             // TODO ERROR REPORTING
          //         }
          //     }
          // }
          else {
            stack.add(CVUValue.constant(CVUValue_Constant.argument(v)));
          }
          break;
        case CVUTokenType.Newline:
          if (stack.length == 0) {
            continue;
          }
          else {
            continue comma;
          }
        comma:
        case CVUTokenType.Comma:
          if (isArrayMode) {
            continue;
          } // IGNORE
          else {
            continue semiColon;
          }
        semiColon:
        case CVUTokenType.SemiColon:
          setPropertyValue();
          lastKey = null;
          break;
        case CVUTokenType.Nil:
          stack.add(CVUValue.constant(CVUValue_Constant.nil()));
          break;
        case CVUTokenType.Number:
          stack.add(CVUValue.constant(CVUValue_Constant.number(v)));
          break;
        case CVUTokenType.String:
          if (!isArrayMode && CVUTokenType.Colon == peekCurrentToken().type) {
            setPropertyValue(); // TODO: Is this every necessary?
            popCurrentToken();
            lastKey = v;
          } else if (lastKey == null) {
            lastKey = v;
          } else {
            stack.add(CVUValue.constant(CVUValue_Constant.string(v)));
          }
          break;
        case CVUTokenType.StringExpression:
          stack.add(CVUValue.expression(createExpression(v, true)));
          break;
        case CVUTokenType.Color:
          stack.add(CVUValue.constant(CVUValue_Constant.colorHex(v)));
          break;
        default:
          throw CVUParseErrors.UnexpectedToken(lastToken!);
      }
    }
  }
  CVUParsedDefinition parseDefinition(CVUParsedDefinition selector){
    while (true) {
      if (CVUTokenType.Newline == peekCurrentToken().type) {
        popCurrentToken();
      }
      else {
        if (CVUTokenType.CurlyBracketOpen != this.popCurrentToken().type) {
          throw CVUParseErrors.ExpectedCharacter("{", this.lastToken!);
        }
        break;
      }
    }
    var parsedVersion = selector;
    parsedVersion.parsed = parseDict();
    return parsedVersion;
  }
}