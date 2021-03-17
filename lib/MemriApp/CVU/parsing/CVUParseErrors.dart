//
// CVUParseErrors.swift
// Copyright © 2020 memri. All rights reserved.

import 'dart:math';

import 'CVULexer.dart';

enum CVUParseErrorsTypes {
  UnexpectedToken,
  UnknownDefinition,
  ExpectedCharacter,
  ExpectedDefinition,
  ExpectedIdentifier,
  ExpectedKey,
  ExpectedString,
  MissingQuoteClose,
  MissingExpressionClose
}

class CVUParseErrors implements Exception {
  CVUParseErrorsTypes type;
  CVUToken? token;
  String? character;

  CVUParseErrors.UnexpectedToken(CVUToken this.token) : type = CVUParseErrorsTypes.UnexpectedToken;
  CVUParseErrors.UnknownDefinition(String this.character, CVUToken this.token)
      : type = CVUParseErrorsTypes.UnknownDefinition;
  CVUParseErrors.ExpectedCharacter(String this.character, CVUToken this.token)
      : type = CVUParseErrorsTypes.ExpectedCharacter;
  CVUParseErrors.ExpectedDefinition(CVUToken this.token) : type = CVUParseErrorsTypes.ExpectedDefinition;
  CVUParseErrors.ExpectedIdentifier(CVUToken this.token) : type = CVUParseErrorsTypes.ExpectedIdentifier;
  CVUParseErrors.ExpectedKey(CVUToken this.token) : type = CVUParseErrorsTypes.ExpectedKey;
  CVUParseErrors.ExpectedString(CVUToken this.token) : type = CVUParseErrorsTypes.ExpectedString;
  CVUParseErrors.MissingQuoteClose(CVUToken this.token) : type = CVUParseErrorsTypes.MissingQuoteClose;
  CVUParseErrors.MissingExpressionClose(CVUToken this.token) : type = CVUParseErrorsTypes.MissingExpressionClose;

  String toErrorString(String code) {//TODO toString can't be override with param code
    String message = "";
    List parts;


    String loc(List parts) {
      if (parts[2] == "") { return "at the end of the file"; }
      else {
        int line = (int.parse(parts[2] ?? -2)) + 1;
        int char = (int.parse(parts[3] ?? -2)) + 1;
        return 'at line:$line and character:$char';
      }
    }
    String displayToken(List parts) {
      return '${parts[0]}' + ((parts[1] ?? "x") != "" ? "('${parts[1]}')" : "");
    }

    switch (type) {
      case CVUParseErrorsTypes.UnexpectedToken:
        parts = token!.toParts();
        message = 'Unexpected ${displayToken(parts)} found ${loc(parts)}';
        break;
      case CVUParseErrorsTypes.UnknownDefinition:
        parts = token!.toParts();
        message = 'Unknown Definition for `$character` type \'${displayToken(parts)}\' found ${loc(parts)}';
        break;
      case CVUParseErrorsTypes.ExpectedCharacter:
        parts = token!.toParts();
        message = 'Expected Character ${character} and found ${displayToken(parts)} instead ${loc(parts)}';
        break;
      case CVUParseErrorsTypes.ExpectedDefinition:
        parts = token!.toParts();
        message = 'Expected Definition and found ${displayToken(parts)} instead ${loc(parts)}';
        break;
      case CVUParseErrorsTypes.ExpectedIdentifier:
        parts = token!.toParts();
        message = 'Expected Identifier and found ${displayToken(parts)} instead ${loc(parts)}';
        break;
      case CVUParseErrorsTypes.ExpectedKey:
        parts = token!.toParts();
        message = 'Expected Key and found ${displayToken(parts)} instead ${loc(parts)}';
        break;
      case CVUParseErrorsTypes.ExpectedString:
        parts = token!.toParts();
        message = 'Expected String and found ${displayToken(parts)} instead ${loc(parts)}';
        break;
      case CVUParseErrorsTypes.MissingQuoteClose:
        parts = token!.toParts();
        message = 'Missing quote ${loc(parts)}';
        break;
      case CVUParseErrorsTypes.MissingExpressionClose:
        parts = token!.toParts();
        message = "Missing expression close token '}}' ${loc(parts)}";
        break;
    }

    List<String> lines = code.split("\n");
    int line = int.parse(parts[2]);
    if (line > 0) {
      int ch = parts[3] ?? 0;
      List beforeLinesList = lines;
      beforeLinesList.removeRange(max(0, line - 10), max(0, line));
      String beforeLines = beforeLinesList.join("\n");
      String afterLines = "";
      if (line + 1 < lines.length - 1) {
        List afterLinesList = lines;
        afterLinesList.removeRange(line + 1, min(line + 10, lines.length - 1));
        afterLines = afterLinesList.join("\n");
      }

      return message + "\n\n"
        + beforeLines + "\n"
        + "-" * ch + "^\n"
        + afterLines;
    }
    else {
      return message;
    }
  }
}
