// Copyright © 2020 memri. All rights reserved.

import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:memri/models/cvu/cvu_lexer.dart';

class CVUParseErrorsUnexpectedToken extends CVUParseErrors {
  CVUParseErrorsUnexpectedToken(CVUToken token) : super(token);
}

class CVUParseErrorsUnknownDefinition extends CVUParseErrors {
  final String name;

  CVUParseErrorsUnknownDefinition(this.name, CVUToken token) : super(token);

  List<Object?> get props => [token, name];
}

class CVUParseErrorsExpectedCharacter extends CVUParseErrors {
  final String character;

  CVUParseErrorsExpectedCharacter(this.character, CVUToken token) : super(token);

  List<Object?> get props => [token, character];
}

class CVUParseErrorsExpectedDefinition extends CVUParseErrors {
  CVUParseErrorsExpectedDefinition(CVUToken token) : super(token);
}

class CVUParseErrorsExpectedIdentifier extends CVUParseErrors {
  CVUParseErrorsExpectedIdentifier(CVUToken token) : super(token);
}

class CVUParseErrorsExpectedKey extends CVUParseErrors {
  CVUParseErrorsExpectedKey(CVUToken token) : super(token);
}

class CVUParseErrorsExpectedString extends CVUParseErrors {
  CVUParseErrorsExpectedString(CVUToken token) : super(token);
}

class CVUParseErrorsMissingQuoteClose extends CVUParseErrors {
  CVUParseErrorsMissingQuoteClose(CVUToken token) : super(token);
}

class CVUParseErrorsMissingExpressionClose extends CVUParseErrors {
  CVUParseErrorsMissingExpressionClose(CVUToken token) : super(token);
}

class CVUParseErrors with EquatableMixin implements Exception {
  final CVUToken token;

  CVUParseErrors(this.token);

  String toErrorString(String code) {
    //TODO toString can't be override with param code
    String message = "";
    List parts;

    String loc(List parts) {
      if (parts[2] == "") {
        return "at the end of the file";
      } else {
        int line = (parts[2] ?? -2) + 1;
        int char = (parts[3] ?? -2) + 1;
        return 'at line:$line and character:$char';
      }
    }

    String displayToken(List parts) {
      return '${parts[0]}' + ((parts[1] ?? "x") != "" ? "('${parts[1]}')" : "");
    }

    var error = this;

    if (error is CVUParseErrorsUnexpectedToken) {
      parts = token.toParts();
      message = 'Unexpected ${displayToken(parts)} found ${loc(parts)}';
    } else if (error is CVUParseErrorsUnknownDefinition) {
      parts = token.toParts();
      message =
          'Unknown Definition for `${error.name}` type \'${displayToken(parts)}\' found ${loc(parts)}';
    } else if (error is CVUParseErrorsExpectedCharacter) {
      parts = token.toParts();
      message =
          'Expected Character ${error.character} and found ${displayToken(parts)} instead ${loc(parts)}';
    } else if (error is CVUParseErrorsExpectedDefinition) {
      parts = token.toParts();
      message = 'Expected Definition and found ${displayToken(parts)} instead ${loc(parts)}';
    } else if (error is CVUParseErrorsExpectedIdentifier) {
      parts = token.toParts();
      message = 'Expected Identifier and found ${displayToken(parts)} instead ${loc(parts)}';
    } else if (error is CVUParseErrorsExpectedKey) {
      parts = token.toParts();
      message = 'Expected Key and found ${displayToken(parts)} instead ${loc(parts)}';
    } else if (error is CVUParseErrorsExpectedString) {
      parts = token.toParts();
      message = 'Expected String and found ${displayToken(parts)} instead ${loc(parts)}';
    } else if (error is CVUParseErrorsMissingQuoteClose) {
      parts = token.toParts();
      message = 'Missing quote ${loc(parts)}';
    } else if (error is CVUParseErrorsMissingExpressionClose) {
      parts = token.toParts();
      message = "Missing expression close token '}}' ${loc(parts)}";
    } else {
      throw Exception("Unknown error type: ${error.toString()}");
    }

    List<String> lines = code.split("\n");
    int line = parts[2];
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

      return message + "\n\n" + beforeLines + "\n" + "-" * ch + "^\n" + afterLines;
    } else {
      return message;
    }
  }

  @override
  List<Object?> get props => [token];
}
