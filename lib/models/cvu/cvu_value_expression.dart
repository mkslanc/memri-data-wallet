//  Created by T Brennan on 28/1/21.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:memri/core/cvu/parsing/cvu_expression_lexer.dart';
import 'package:memri/core/cvu/parsing/cvu_expression_parser.dart';
import 'package:memri/models/cvu/cvu_value_constant.dart';
import 'package:memri/models/cvu/cvu_value_lookup_node.dart';

part 'cvu_value_expression.g.dart';

/// A CVU Expression node. Nodes are nestable and the chain ends in either a CVU constant or a lookup node.
abstract class CVUExpressionNode extends Equatable {
  String get description {
    return "$this";
  }

  CVUExpressionNode();

  static CVUExpressionNode create(String code, bool stringMode) {
    CVUExpressionLexer lexer = CVUExpressionLexer(code, stringMode);
    List<ExprToken> tokens = lexer.tokenize();
    return CVUExpressionParser(tokens).parse();
  }

  String toCVUString() {
    var expressionNode = this;
    if (expressionNode is CVUExpressionNodeLookup) {
      return expressionNode.nodes.length == 1 &&
              expressionNode.nodes.first.type is CVULookupTypeDefault
          ? "."
          : expressionNode.nodes.map((element) => element.toCVUString()).join(".");
    } else if (expressionNode is CVUExpressionNodeStringMode) {
      return expressionNode.nodes.map((element) {
        if (element is CVUExpressionNodeConstant) {
          return element.value.toCVUString(true);
        } else {
          return '{${element.toCVUString()}}';
        }
      }).join();
    } else if (expressionNode is CVUExpressionNodeConditional) {
      return '${expressionNode.condition.toCVUString()} ? ${expressionNode.trueExp.toCVUString()} : ${expressionNode.falseExp.toCVUString()}';
    } else if (expressionNode is CVUExpressionNodeOr) {
      return '${expressionNode.lhs.toCVUString()} OR ${expressionNode.rhs.toCVUString()}';
    } else if (expressionNode is CVUExpressionNodeNegation) {
      return '!${expressionNode.expression.toCVUString()}';
    } else if (expressionNode is CVUExpressionNodeAddition) {
      return '${expressionNode.lhs.toCVUString()} + ${expressionNode.rhs.toCVUString()}';
    } else if (expressionNode is CVUExpressionNodeSubtraction) {
      return '${expressionNode.lhs.toCVUString()} - ${expressionNode.rhs.toCVUString()}';
    } else if (expressionNode is CVUExpressionNodeMultiplication) {
      return '${expressionNode.lhs.toCVUString()} * ${expressionNode.rhs.toCVUString()}';
    } else if (expressionNode is CVUExpressionNodeDivision) {
      return '${expressionNode.lhs.toCVUString()} / ${expressionNode.rhs.toCVUString()}';
    } else if (expressionNode is CVUExpressionNodeConstant) {
      return expressionNode.value.toCVUString();
    } else if (expressionNode is CVUExpressionNodeLessThan) {
      return '${expressionNode.lhs.toCVUString()} < ${expressionNode.rhs.toCVUString()}';
    } else if (expressionNode is CVUExpressionNodeGreaterThan) {
      return '${expressionNode.lhs.toCVUString()} > ${expressionNode.rhs.toCVUString()}';
    } else if (expressionNode is CVUExpressionNodeLessThanOrEqual) {
      return '${expressionNode.lhs.toCVUString()} <= ${expressionNode.rhs.toCVUString()}';
    } else if (expressionNode is CVUExpressionNodeGreaterThanOrEqual) {
      return '${expressionNode.lhs.toCVUString()} >= ${expressionNode.rhs.toCVUString()}';
    } else if (expressionNode is CVUExpressionNodeAreEqual) {
      return '${expressionNode.lhs.toCVUString()} = ${expressionNode.rhs.toCVUString()}';
    } else if (expressionNode is CVUExpressionNodeAreNotEqual) {
      return '${expressionNode.lhs.toCVUString()} != ${expressionNode.rhs.toCVUString()}';
    } else if (expressionNode is CVUExpressionNodeAnd) {
      return '${expressionNode.lhs.toCVUString()} AND ${expressionNode.rhs.toCVUString()}';
    } else if (expressionNode is CVUExpressionNodeNamed) {
      return '${expressionNode.key}: ${expressionNode.value.toCVUString()}';
    } else {
      throw Exception("Unknown CVUExpressionNode: ${this.toString()}");
    }
  }

  factory CVUExpressionNode.fromJson(json) {
    switch (json["type"]) {
      case "CVUExpressionNodeLookup":
        return CVUExpressionNodeLookup.fromJson(json);
      case "CVUExpressionNodeStringMode":
        return CVUExpressionNodeStringMode.fromJson(json);
      case "CVUExpressionNodeConditional":
        return CVUExpressionNodeConditional.fromJson(json);
      case "CVUExpressionNodeOr":
        return CVUExpressionNodeOr.fromJson(json);
      case "CVUExpressionNodeNegation":
        return CVUExpressionNodeNegation.fromJson(json);
      case "CVUExpressionNodeAddition":
        return CVUExpressionNodeAddition.fromJson(json);
      case "CVUExpressionNodeSubtraction":
        return CVUExpressionNodeSubtraction.fromJson(json);
      case "CVUExpressionNodeMultiplication":
        return CVUExpressionNodeMultiplication.fromJson(json);
      case "CVUExpressionNodeDivision":
        return CVUExpressionNodeDivision.fromJson(json);
      case "CVUExpressionNodeConstant":
        return CVUExpressionNodeConstant.fromJson(json);
      case "CVUExpressionNodeLessThan":
        return CVUExpressionNodeLessThan.fromJson(json);
      case "CVUExpressionNodeGreaterThan":
        return CVUExpressionNodeGreaterThan.fromJson(json);
      case "CVUExpressionNodeLessThanOrEqual":
        return CVUExpressionNodeLessThanOrEqual.fromJson(json);
      case "CVUExpressionNodeGreaterThanOrEqual":
        return CVUExpressionNodeGreaterThanOrEqual.fromJson(json);
      case "CVUExpressionNodeAreEqual":
        return CVUExpressionNodeAreEqual.fromJson(json);
      case "CVUExpressionNodeAreNotEqual":
        return CVUExpressionNodeAreNotEqual.fromJson(json);
      case "CVUExpressionNodeAnd":
        return CVUExpressionNodeAnd.fromJson(json);
      case "CVUExpressionNodeNamed":
        return CVUExpressionNodeNamed.fromJson(json);
      default:
        throw Exception("Unknown CVUExpressionNode: ${json["type"]}");
    }
  }

  Map<String, dynamic> toJson();

  @override
  List<Object?> get props => [];
}

@JsonSerializable()
class CVUExpressionNodeLookup extends CVUExpressionNode {
  final List<CVULookupNode> nodes;

  CVUExpressionNodeLookup(this.nodes);

  factory CVUExpressionNodeLookup.fromJson(Map<String, dynamic> json) =>
      _$CVUExpressionNodeLookupFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUExpressionNodeLookupToJson(this)..addAll({"type": runtimeType.toString()});

  @override
  List<Object?> get props => [nodes];
}

@JsonSerializable()
class CVUExpressionNodeStringMode extends CVUExpressionNode {
  final List<CVUExpressionNode> nodes;

  CVUExpressionNodeStringMode(this.nodes);

  factory CVUExpressionNodeStringMode.fromJson(Map<String, dynamic> json) =>
      _$CVUExpressionNodeStringModeFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUExpressionNodeStringModeToJson(this)..addAll({"type": runtimeType.toString()});

  @override
  List<Object?> get props => [nodes];
}

@JsonSerializable()
class CVUExpressionNodeConditional extends CVUExpressionNode {
  final CVUExpressionNode condition;
  final CVUExpressionNode trueExp;
  final CVUExpressionNode falseExp;

  CVUExpressionNodeConditional(this.condition, this.trueExp, this.falseExp);

  factory CVUExpressionNodeConditional.fromJson(Map<String, dynamic> json) =>
      _$CVUExpressionNodeConditionalFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUExpressionNodeConditionalToJson(this)..addAll({"type": runtimeType.toString()});

  @override
  List<Object?> get props => [condition, trueExp, falseExp];
}

@JsonSerializable()
class CVUExpressionNodeOr extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeOr(this.lhs, this.rhs);

  factory CVUExpressionNodeOr.fromJson(Map<String, dynamic> json) =>
      _$CVUExpressionNodeOrFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUExpressionNodeOrToJson(this)..addAll({"type": runtimeType.toString()});

  @override
  List<Object?> get props => [lhs, rhs];
}

@JsonSerializable()
class CVUExpressionNodeNegation extends CVUExpressionNode {
  final CVUExpressionNode expression;

  CVUExpressionNodeNegation(this.expression);

  factory CVUExpressionNodeNegation.fromJson(Map<String, dynamic> json) =>
      _$CVUExpressionNodeNegationFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUExpressionNodeNegationToJson(this)..addAll({"type": runtimeType.toString()});

  @override
  List<Object?> get props => [expression];
}

@JsonSerializable()
class CVUExpressionNodeAddition extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeAddition(this.lhs, this.rhs);

  factory CVUExpressionNodeAddition.fromJson(Map<String, dynamic> json) =>
      _$CVUExpressionNodeAdditionFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUExpressionNodeAdditionToJson(this)..addAll({"type": runtimeType.toString()});

  @override
  List<Object?> get props => [lhs, rhs];
}

@JsonSerializable()
class CVUExpressionNodeSubtraction extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeSubtraction(this.lhs, this.rhs);

  factory CVUExpressionNodeSubtraction.fromJson(Map<String, dynamic> json) =>
      _$CVUExpressionNodeSubtractionFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUExpressionNodeSubtractionToJson(this)..addAll({"type": runtimeType.toString()});

  @override
  List<Object?> get props => [lhs, rhs];
}

@JsonSerializable()
class CVUExpressionNodeMultiplication extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeMultiplication(this.lhs, this.rhs);

  factory CVUExpressionNodeMultiplication.fromJson(Map<String, dynamic> json) =>
      _$CVUExpressionNodeMultiplicationFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUExpressionNodeMultiplicationToJson(this)..addAll({"type": runtimeType.toString()});

  @override
  List<Object?> get props => [lhs, rhs];
}

@JsonSerializable()
class CVUExpressionNodeDivision extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeDivision(this.lhs, this.rhs);

  factory CVUExpressionNodeDivision.fromJson(Map<String, dynamic> json) =>
      _$CVUExpressionNodeDivisionFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUExpressionNodeDivisionToJson(this)..addAll({"type": runtimeType.toString()});

  @override
  List<Object?> get props => [lhs, rhs];
}

@JsonSerializable()
class CVUExpressionNodeConstant extends CVUExpressionNode {
  final CVUConstant value;

  CVUExpressionNodeConstant(this.value);

  factory CVUExpressionNodeConstant.fromJson(Map<String, dynamic> json) =>
      _$CVUExpressionNodeConstantFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUExpressionNodeConstantToJson(this)..addAll({"type": runtimeType.toString()});

  @override
  List<Object?> get props => [value];
}

@JsonSerializable()
class CVUExpressionNodeLessThan extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeLessThan(this.lhs, this.rhs);

  factory CVUExpressionNodeLessThan.fromJson(Map<String, dynamic> json) =>
      _$CVUExpressionNodeLessThanFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUExpressionNodeLessThanToJson(this)..addAll({"type": runtimeType.toString()});

  @override
  List<Object?> get props => [lhs, rhs];
}

@JsonSerializable()
class CVUExpressionNodeGreaterThan extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeGreaterThan(this.lhs, this.rhs);

  factory CVUExpressionNodeGreaterThan.fromJson(Map<String, dynamic> json) =>
      _$CVUExpressionNodeGreaterThanFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUExpressionNodeGreaterThanToJson(this)..addAll({"type": runtimeType.toString()});

  @override
  List<Object?> get props => [lhs, rhs];
}

@JsonSerializable()
class CVUExpressionNodeLessThanOrEqual extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeLessThanOrEqual(this.lhs, this.rhs);

  factory CVUExpressionNodeLessThanOrEqual.fromJson(Map<String, dynamic> json) =>
      _$CVUExpressionNodeLessThanOrEqualFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUExpressionNodeLessThanOrEqualToJson(this)..addAll({"type": runtimeType.toString()});

  @override
  List<Object?> get props => [lhs, rhs];
}

@JsonSerializable()
class CVUExpressionNodeGreaterThanOrEqual extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeGreaterThanOrEqual(this.lhs, this.rhs);

  factory CVUExpressionNodeGreaterThanOrEqual.fromJson(Map<String, dynamic> json) =>
      _$CVUExpressionNodeGreaterThanOrEqualFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUExpressionNodeGreaterThanOrEqualToJson(this)..addAll({"type": runtimeType.toString()});

  @override
  List<Object?> get props => [lhs, rhs];
}

@JsonSerializable()
class CVUExpressionNodeAreEqual extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeAreEqual(this.lhs, this.rhs);

  factory CVUExpressionNodeAreEqual.fromJson(Map<String, dynamic> json) =>
      _$CVUExpressionNodeAreEqualFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUExpressionNodeAreEqualToJson(this)..addAll({"type": runtimeType.toString()});

  @override
  List<Object?> get props => [lhs, rhs];
}

@JsonSerializable()
class CVUExpressionNodeAreNotEqual extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeAreNotEqual(this.lhs, this.rhs);

  factory CVUExpressionNodeAreNotEqual.fromJson(Map<String, dynamic> json) =>
      _$CVUExpressionNodeAreNotEqualFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUExpressionNodeAreNotEqualToJson(this)..addAll({"type": runtimeType.toString()});

  @override
  List<Object?> get props => [lhs, rhs];
}

@JsonSerializable()
class CVUExpressionNodeAnd extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeAnd(this.lhs, this.rhs);

  factory CVUExpressionNodeAnd.fromJson(Map<String, dynamic> json) =>
      _$CVUExpressionNodeAndFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUExpressionNodeAndToJson(this)..addAll({"type": runtimeType.toString()});

  @override
  List<Object?> get props => [lhs, rhs];
}

@JsonSerializable()
class CVUExpressionNodeNamed extends CVUExpressionNode {
  final String key;
  final CVUExpressionNode value;

  CVUExpressionNodeNamed(this.key, this.value);

  factory CVUExpressionNodeNamed.fromJson(Map<String, dynamic> json) =>
      _$CVUExpressionNodeNamedFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUExpressionNodeNamedToJson(this)..addAll({"type": runtimeType.toString()});

  @override
  List<Object?> get props => [key, value];
}
