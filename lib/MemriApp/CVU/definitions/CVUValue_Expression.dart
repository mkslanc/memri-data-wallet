//
//  CVUValue_Expression.swift
//  Memri
//
//  Created by T Brennan on 28/1/21.
//

import 'package:equatable/equatable.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUExpressionLexer.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUExpressionParser.dart';

import 'CVUValue_LookupNode.dart';

/// A CVU Expression node. Nodes are nestable and the chain ends in either a CVU constant or a lookup node.
abstract class CVUExpressionNode extends Equatable {
  String get description {
    return "$this";
  }

  static CVUExpressionNode create(String code, bool stringMode) {
    CVUExpressionLexer lexer = CVUExpressionLexer(code, stringMode);
    List<ExprToken> tokens = lexer.tokenize();
    return CVUExpressionParser(tokens).parse();
  }

  String toCVUString() {
    var expressionNode = this;
    if (expressionNode is CVUExpressionNodeLookup) {
      return expressionNode.nodes.map((element) => element.toCVUString()).join(".");
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
    } else {
      throw Exception("Unknown CVUExpressionNode: ${this.toString()}");
    }
  }

  @override
  List<Object?> get props => [];
}

class CVUExpressionNodeLookup extends CVUExpressionNode {
  final List<CVULookupNode> nodes;

  CVUExpressionNodeLookup(this.nodes);
}

class CVUExpressionNodeStringMode extends CVUExpressionNode {
  final List<CVUExpressionNode> nodes;

  CVUExpressionNodeStringMode(this.nodes);
}

class CVUExpressionNodeConditional extends CVUExpressionNode {
  final CVUExpressionNode condition;
  final CVUExpressionNode trueExp;
  final CVUExpressionNode falseExp;

  CVUExpressionNodeConditional(this.condition, this.trueExp, this.falseExp);
}

class CVUExpressionNodeOr extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeOr(this.lhs, this.rhs);
}

class CVUExpressionNodeNegation extends CVUExpressionNode {
  final CVUExpressionNode expression;

  CVUExpressionNodeNegation(this.expression);
}

class CVUExpressionNodeAddition extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeAddition(this.lhs, this.rhs);
}

class CVUExpressionNodeSubtraction extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeSubtraction(this.lhs, this.rhs);
}

class CVUExpressionNodeMultiplication extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeMultiplication(this.lhs, this.rhs);
}

class CVUExpressionNodeDivision extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeDivision(this.lhs, this.rhs);
}

class CVUExpressionNodeConstant extends CVUExpressionNode {
  final CVUConstant value;

  CVUExpressionNodeConstant(this.value);
}

class CVUExpressionNodeLessThan extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeLessThan(this.lhs, this.rhs);
}

class CVUExpressionNodeGreaterThan extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeGreaterThan(this.lhs, this.rhs);
}

class CVUExpressionNodeLessThanOrEqual extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeLessThanOrEqual(this.lhs, this.rhs);
}

class CVUExpressionNodeGreaterThanOrEqual extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeGreaterThanOrEqual(this.lhs, this.rhs);
}

class CVUExpressionNodeAreEqual extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeAreEqual(this.lhs, this.rhs);
}

class CVUExpressionNodeAreNotEqual extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeAreNotEqual(this.lhs, this.rhs);
}

class CVUExpressionNodeAnd extends CVUExpressionNode {
  final CVUExpressionNode lhs;
  final CVUExpressionNode rhs;

  CVUExpressionNodeAnd(this.lhs, this.rhs);
}
