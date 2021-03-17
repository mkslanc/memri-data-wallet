import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/parsing/CVULexer.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUParser.dart';


List<CVUParsedDefinition> parse(String snippet) {
  CVULexer lexer = CVULexer(snippet);
  List<CVUToken> tokens = lexer.tokenize();
  CVUParser parser = CVUParser(tokens);
  List<CVUParsedDefinition> x = parser.parse();
  return x;
}

String toCVUString(List<CVUParsedDefinition> list) {
  return list.map(($0) => $0.toCVUString(0, "    ", true) ).join("\n\n");//.replaceAll(/\n\s+\n"/, "\n\n");TODO @mkslanc
}

String parseToCVUString(String snippet) {
  var parsed = parse(snippet);
  return toCVUString(parsed);
}

void main() {
  test('testRendererDefinition', () {
    var snippet = """[renderer = generalEditor] {
    sequence: labels starred other dates
}""";
    expect(parseToCVUString(snippet), """[renderer = generalEditor] {
    sequence: labels starred other dates
}""");
  });
}
