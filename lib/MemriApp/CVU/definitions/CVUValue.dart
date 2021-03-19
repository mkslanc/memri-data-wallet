//
//  CVUValue.swift
//  MemriDatabase
//
//  Created by T Brennan on 7/12/20.
//

import 'package:equatable/equatable.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUExpressionLexer.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUExpressionParser.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUStringConvertible.dart';

import 'CVUParsedDefinition.dart';

/// A value of a CVU property that can be serialised both to CVU format and to JSON
enum CVUValueType {
  expression,
  constant,
  item,
  array,
  dictionary,
  subdefinition
}

class CVUValue implements CVUStringConvertible {
  final CVUValueType type;
  var value;

  @override
  List<Object?> get props => [type, value];

  CVUValue.expression(ExpressionNode this.value) : type = CVUValueType.expression;
  CVUValue.constant(CVUValue_Constant this.value) : type = CVUValueType.constant;
  CVUValue.item(String this.value) : type = CVUValueType.item;
  CVUValue.array(List<CVUValue> this.value) : type = CVUValueType.array;
  CVUValue.dictionary(Map<String, CVUValue> this.value) : type = CVUValueType.dictionary;
  CVUValue.subdefinition(CVUDefinitionContent this.value) : type = CVUValueType.subdefinition;

  @override
  String toCVUString(int depth, String tab, bool includeInitialTab) {
    // TODO: implement toCVUString
    switch (type) {
      case (CVUValueType.expression):
        ExpressionNode expression = value;
        String innerString = expression.toCVUString();
        switch (expression.type) {
          case ExpressionNodeType.stringMode:
            return '"$innerString"';
          default:
            return '{{$innerString}}';
        }
      case CVUValueType.constant:
        return value.toCVUString();
      case CVUValueType.item:
        String uid = value;
        return '{{item($uid)}}';
      case CVUValueType.array:
        List<CVUValue> values = value;
        return values.toCVUString(depth, tab, false);
      case CVUValueType.dictionary:
        Map<String, CVUValue> dict = value;
        return '{\n${dict.toCVUString(depth, tab, true)}\n}';
      case CVUValueType.subdefinition:
        CVUDefinitionContent x = value;
        return x.toCVUString(depth, tab, includeInitialTab);
      default:
        return "";
    }
  }

  CVUDefinitionContent? getSubdefinition() {
    switch (type) {
      case CVUValueType.subdefinition:
        return value;
      default:
        return null;
    }
  }
}

//Start From CVUValue_Constant
enum CVUValue_ConstantType {
  argument,
  number,
  string,
  bool,
  colorHex,
  nil
}

/// Get a string representation of the value
class CVUValue_Constant extends Equatable {
  final CVUValue_ConstantType type;
  var value;

  @override
  List<Object?> get props => [type, value];

  CVUValue_Constant.argument(String this.value) : type = CVUValue_ConstantType.argument;
  CVUValue_Constant.number(double this.value) : type = CVUValue_ConstantType.number;
  CVUValue_Constant.string(String this.value) : type = CVUValue_ConstantType.string;
  CVUValue_Constant.bool(bool this.value) : type = CVUValue_ConstantType.bool;
  CVUValue_Constant.colorHex(String this.value) : type = CVUValue_ConstantType.colorHex;
  CVUValue_Constant.nil() : type = CVUValue_ConstantType.nil;


  String asString() {
    switch (type) {
      case CVUValue_ConstantType.argument:
        return value;
      case CVUValue_ConstantType.number:
        return "$value";
      case CVUValue_ConstantType.string:
        return value;
      case CVUValue_ConstantType.bool:
        return "$value";
      case CVUValue_ConstantType.colorHex:
        return value;
      case CVUValue_ConstantType.nil:
        return "";
      default:
        return "";
    }
  }

  /// Get a number representation of the value (may return nil)
  double? asNumber() {
    switch (type) {
      case CVUValue_ConstantType.argument:
        return null;
      case CVUValue_ConstantType.number:
        return value;
      case CVUValue_ConstantType.string:
        return double.parse(value);
      case CVUValue_ConstantType.bool:
        return value ? 1 : 0;
      case CVUValue_ConstantType.colorHex:
        return null;
      case CVUValue_ConstantType.nil:
        return null;
      default:
        return null;
    }
  }

  /// Get a boolean representation of the value (may return nil for types not easily converted to bool)
  bool? asBool() {
    switch (type) {
      case CVUValue_ConstantType.argument:
        return null;
      case CVUValue_ConstantType.number:
      // Number greater than zero = true
        return value > 0;
      case CVUValue_ConstantType.string:

      /// Non-empty string = true (unless string is 'false')
        return value != "" && value != "false";
      case CVUValue_ConstantType.bool:
        return value;
      case CVUValue_ConstantType.colorHex:
        return null;
      case CVUValue_ConstantType.nil:
        return null;
      default:
        return null;
    }
  }

  String toCVUString([bool insideStringMode = false]) {
    switch (type) {
      case CVUValue_ConstantType.argument:
        return value;
      case CVUValue_ConstantType.number:
        double n = value;
        return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
      case CVUValue_ConstantType.string:
        String escaped = (value as String).replaceAll("\"", "\\\"");
        return insideStringMode ? escaped : '"$escaped"';
      case CVUValue_ConstantType.bool:
        return value ? "true" : "false";
      case CVUValue_ConstantType.colorHex:
        return '#$value';
      case CVUValue_ConstantType.nil:
        return "nil";
      default:
        return "null";
    }
  }
}
//End From CVUValue_Constant


//Start From CVUValue_Expression
enum ExpressionNodeType {
  lookup,
  stringMode,
  conditional,
  or,
  negation,
  addition,
  subtraction,
  multiplication,
  division,
  constant,
  lessThan,
  greaterThan,
  lessThanOrEqual,
  greaterThanOrEqual,
  areEqual,
  areNotEqual,
  and
}

extension ExpressionNodeTypeExtension on ExpressionNodeType {
  String get description {
    return '$this';
  }
}

class ExpressionNode extends Equatable {
  final ExpressionNodeType type;
  final value;

  var secondArg;
  var thirdArg;

  ExpressionNode.lookup(List<LookupNode> this.value) : type = ExpressionNodeType.lookup;
  ExpressionNode.stringMode(List<ExpressionNode> this.value) : type = ExpressionNodeType.stringMode;
  ExpressionNode.conditional(ExpressionNode this.value, ExpressionNode this.secondArg,
      ExpressionNode this.thirdArg)
      : type = ExpressionNodeType.conditional;

  ExpressionNode.or(ExpressionNode this.value, ExpressionNode this.secondArg)
      : type = ExpressionNodeType.or;

  ExpressionNode.negation(ExpressionNode this.value) : type = ExpressionNodeType.negation;

  ExpressionNode.addition(ExpressionNode this.value, ExpressionNode this.secondArg)
      : type = ExpressionNodeType.addition;

  ExpressionNode.subtraction(ExpressionNode this.value, ExpressionNode this.secondArg)
      : type = ExpressionNodeType.subtraction;

  ExpressionNode.multiplication(ExpressionNode this.value, ExpressionNode this.secondArg)
      : type = ExpressionNodeType.multiplication;

  ExpressionNode.division(ExpressionNode this.value, ExpressionNode this.secondArg)
      : type = ExpressionNodeType.division;

  ExpressionNode.constant(CVUValue_Constant this.value) : type = ExpressionNodeType.constant;

  ExpressionNode.lessThan(ExpressionNode this.value, ExpressionNode this.secondArg)
      : type = ExpressionNodeType.lessThan;

  ExpressionNode.greaterThan(ExpressionNode this.value, ExpressionNode this.secondArg)
      : type = ExpressionNodeType.greaterThan;

  ExpressionNode.lessThanOrEqual(ExpressionNode this.value, ExpressionNode this.secondArg)
      : type = ExpressionNodeType.lessThanOrEqual;

  ExpressionNode.greaterThanOrEqual(ExpressionNode this.value, ExpressionNode this.secondArg)
      : type = ExpressionNodeType.greaterThanOrEqual;

  ExpressionNode.areEqual(ExpressionNode this.value, ExpressionNode this.secondArg)
      : type = ExpressionNodeType.areEqual;

  ExpressionNode.areNotEqual(ExpressionNode this.value, ExpressionNode this.secondArg)
      : type = ExpressionNodeType.areNotEqual;

  ExpressionNode.and(ExpressionNode this.value, ExpressionNode this.secondArg)
      : type = ExpressionNodeType.and;

  static ExpressionNode create(String code, bool stringMode) {//TODO @anijanyan
    CVUExpressionLexer lexer = CVUExpressionLexer(code, stringMode);
    List<ExprToken> tokens = lexer.tokenize();
    return CVUExpressionParser(tokens).parse();
  }

  String toCVUString() {
    ExpressionNode lhs, rhs, x;
    switch (type) {
      case ExpressionNodeType.lookup:
        List<LookupNode> nodes = value;
        return nodes.map(($0) => $0.toCVUString()).join(".");
      case ExpressionNodeType.stringMode:
        List<ExpressionNode> nodes = value;
        return nodes.map((ExpressionNode $0) {
          switch ($0.type) {
            case ExpressionNodeType.constant:
              CVUValue_Constant constant = $0.value;
              return constant.toCVUString(true);
            default:
              return '{${$0.toCVUString()}}';
          }
        }).join("");
      case ExpressionNodeType.conditional:
        ExpressionNode condition = value;
        ExpressionNode trueExp = secondArg;
        ExpressionNode falseExp = thirdArg;
        return '${condition.toCVUString()} ? ${trueExp.toCVUString()} : ${falseExp.toCVUString()}';
      case ExpressionNodeType.or:
        lhs = value;
        rhs = secondArg;
        return '${lhs.toCVUString()} OR ${rhs.toCVUString()}';
      case ExpressionNodeType.negation:
        x = value;
        return '!${x.toCVUString()}';
      case ExpressionNodeType.addition:
        lhs = value;
        rhs = secondArg;
        return '${lhs.toCVUString()} + ${rhs.toCVUString()}';
      case ExpressionNodeType.subtraction:
        lhs = value;
        rhs = secondArg;
        return '${lhs.toCVUString()} - ${rhs.toCVUString()}';
      case ExpressionNodeType.multiplication:
        lhs = value;
        rhs = secondArg;
        return '${lhs.toCVUString()} * ${rhs.toCVUString()}';
      case ExpressionNodeType.division:
        lhs = value;
        rhs = secondArg;
        return '${lhs.toCVUString()} / ${rhs.toCVUString()}';
      case ExpressionNodeType.constant:
        x = value;
        return x.toCVUString();
      case ExpressionNodeType.lessThan:
        lhs = value;
        rhs = secondArg;
        return '${lhs.toCVUString()} < ${rhs.toCVUString()}';
      case ExpressionNodeType.greaterThan:
        lhs = value;
        rhs = secondArg;
        return '${lhs.toCVUString()} > ${rhs.toCVUString()}';
      case ExpressionNodeType.lessThanOrEqual:
        lhs = value;
        rhs = secondArg;
        return '${lhs.toCVUString()} <= ${rhs.toCVUString()}';
      case ExpressionNodeType.greaterThanOrEqual:
        lhs = value;
        rhs = secondArg;
        return '${lhs.toCVUString()} >= ${rhs.toCVUString()}';
      case ExpressionNodeType.areEqual:
        lhs = value;
        rhs = secondArg;
        return '${lhs.toCVUString()} = ${rhs.toCVUString()}';
      case ExpressionNodeType.areNotEqual:
        lhs = value;
        rhs = secondArg;
        return '${lhs.toCVUString()} != ${rhs.toCVUString()}';
      case ExpressionNodeType.and:
        lhs = value;
        rhs = secondArg;
        return '${lhs.toCVUString()} AND ${rhs.toCVUString()}';
    }
  }

  @override
  List<Object?> get props => [type, value, secondArg, thirdArg];
}
//End From CVUValue_Expression

//Start From CVUValue_LookupNode
enum LookupTypeType {
  defaultLookup,
  lookup,
  function
}

class LookupType extends Equatable {
  LookupTypeType type;
  var value;

  @override
  List<Object?> get props => [type, value];

  LookupType.defaultLookup() : this.type = LookupTypeType.defaultLookup;
  LookupType.lookup([ExpressionNode? this.value]) : this.type = LookupTypeType.lookup;
  LookupType.function(List<ExpressionNode> this.value) : this.type = LookupTypeType.function;
}

class LookupNode extends Equatable {
  String name;
  bool isArray = false;
  LookupType type;

  @override
  List<Object?> get props => [type, name, isArray];

  LookupNode({required this.name, required this.type, this.isArray = false});

  static get defaultLookup {
    return LookupNode(name: "@@DEFAULT@@", type: LookupType.defaultLookup());
  }

  String toCVUString() {
    switch (type.type) {
      case LookupTypeType.defaultLookup:
        return "";
      case LookupTypeType.function:
        List<ExpressionNode> args = type.value;
        return '$name(${args.map(($0) => $0.toCVUString()).join(", ")})';
      default:
        return '$name${isArray ? "[]" : ""}';
    }
  }
}
//End From CVUValue_LookupNode