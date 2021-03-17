import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUExpressionLexer.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUExpressionParser.dart';
import 'package:test/test.dart';

parse({snippet, stringMode = false}) {
  var lexer = CVUExpressionLexer(snippet, stringMode);
  var tokens = lexer.tokenize();
  var parser = CVUExpressionParser(tokens);
  return parser.parse();
}

void main() {
  test('testArithmeticOperators', () {
    var snippet = "(5 + 10 * 4 - 3 / 10) / 10";
    var result = parse(snippet: snippet);
    expect(
        result,
        equals(ExpressionNode.division(
            ExpressionNode.subtraction(
                ExpressionNode.addition(
                    ExpressionNode.constant(CVUValue_Constant.number(5)),
                    ExpressionNode.multiplication(
                        ExpressionNode.constant(CVUValue_Constant.number(10)),
                        ExpressionNode.constant(CVUValue_Constant.number(4)))),
                ExpressionNode.division(ExpressionNode.constant(CVUValue_Constant.number(3)),
                    ExpressionNode.constant(CVUValue_Constant.number(10)))),
            ExpressionNode.constant(CVUValue_Constant.number(10)))));
  });
}
