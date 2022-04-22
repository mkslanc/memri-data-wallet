// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cvu_value_expression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CVUExpressionNodeLookup _$CVUExpressionNodeLookupFromJson(Map<String, dynamic> json) =>
    CVUExpressionNodeLookup(
      (json['nodes'] as List<dynamic>)
          .map((e) => CVULookupNode.fromJson(e as Map<String, dynamic>))
          .toList(),
    )..inParens = json['inParens'] as bool;

Map<String, dynamic> _$CVUExpressionNodeLookupToJson(CVUExpressionNodeLookup instance) =>
    <String, dynamic>{
      'inParens': instance.inParens,
      'nodes': instance.nodes,
    };

CVUExpressionNodeStringMode _$CVUExpressionNodeStringModeFromJson(Map<String, dynamic> json) =>
    CVUExpressionNodeStringMode(
      (json['nodes'] as List<dynamic>).map((e) => CVUExpressionNode.fromJson(e)).toList(),
    )..inParens = json['inParens'] as bool;

Map<String, dynamic> _$CVUExpressionNodeStringModeToJson(CVUExpressionNodeStringMode instance) =>
    <String, dynamic>{
      'inParens': instance.inParens,
      'nodes': instance.nodes,
    };

CVUExpressionNodeConditional _$CVUExpressionNodeConditionalFromJson(Map<String, dynamic> json) =>
    CVUExpressionNodeConditional(
      CVUExpressionNode.fromJson(json['condition']),
      CVUExpressionNode.fromJson(json['trueExp']),
      CVUExpressionNode.fromJson(json['falseExp']),
    )..inParens = json['inParens'] as bool;

Map<String, dynamic> _$CVUExpressionNodeConditionalToJson(CVUExpressionNodeConditional instance) =>
    <String, dynamic>{
      'inParens': instance.inParens,
      'condition': instance.condition,
      'trueExp': instance.trueExp,
      'falseExp': instance.falseExp,
    };

CVUExpressionNodeOr _$CVUExpressionNodeOrFromJson(Map<String, dynamic> json) => CVUExpressionNodeOr(
      CVUExpressionNode.fromJson(json['lhs']),
      CVUExpressionNode.fromJson(json['rhs']),
      json['inParens'] as bool? ?? false,
    );

Map<String, dynamic> _$CVUExpressionNodeOrToJson(CVUExpressionNodeOr instance) => <String, dynamic>{
      'inParens': instance.inParens,
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeNegation _$CVUExpressionNodeNegationFromJson(Map<String, dynamic> json) =>
    CVUExpressionNodeNegation(
      CVUExpressionNode.fromJson(json['expression']),
      json['inParens'] as bool? ?? false,
    );

Map<String, dynamic> _$CVUExpressionNodeNegationToJson(CVUExpressionNodeNegation instance) =>
    <String, dynamic>{
      'inParens': instance.inParens,
      'expression': instance.expression,
    };

CVUExpressionNodeAddition _$CVUExpressionNodeAdditionFromJson(Map<String, dynamic> json) =>
    CVUExpressionNodeAddition(
      CVUExpressionNode.fromJson(json['lhs']),
      CVUExpressionNode.fromJson(json['rhs']),
      json['inParens'] as bool? ?? false,
    );

Map<String, dynamic> _$CVUExpressionNodeAdditionToJson(CVUExpressionNodeAddition instance) =>
    <String, dynamic>{
      'inParens': instance.inParens,
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeSubtraction _$CVUExpressionNodeSubtractionFromJson(Map<String, dynamic> json) =>
    CVUExpressionNodeSubtraction(
      CVUExpressionNode.fromJson(json['lhs']),
      CVUExpressionNode.fromJson(json['rhs']),
      json['inParens'] as bool? ?? false,
    );

Map<String, dynamic> _$CVUExpressionNodeSubtractionToJson(CVUExpressionNodeSubtraction instance) =>
    <String, dynamic>{
      'inParens': instance.inParens,
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeMultiplication _$CVUExpressionNodeMultiplicationFromJson(
        Map<String, dynamic> json) =>
    CVUExpressionNodeMultiplication(
      CVUExpressionNode.fromJson(json['lhs']),
      CVUExpressionNode.fromJson(json['rhs']),
      json['inParens'] as bool? ?? false,
    );

Map<String, dynamic> _$CVUExpressionNodeMultiplicationToJson(
        CVUExpressionNodeMultiplication instance) =>
    <String, dynamic>{
      'inParens': instance.inParens,
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeDivision _$CVUExpressionNodeDivisionFromJson(Map<String, dynamic> json) =>
    CVUExpressionNodeDivision(
      CVUExpressionNode.fromJson(json['lhs']),
      CVUExpressionNode.fromJson(json['rhs']),
      json['inParens'] as bool? ?? false,
    );

Map<String, dynamic> _$CVUExpressionNodeDivisionToJson(CVUExpressionNodeDivision instance) =>
    <String, dynamic>{
      'inParens': instance.inParens,
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeConstant _$CVUExpressionNodeConstantFromJson(Map<String, dynamic> json) =>
    CVUExpressionNodeConstant(
      CVUConstant.fromJson(json['value']),
    )..inParens = json['inParens'] as bool;

Map<String, dynamic> _$CVUExpressionNodeConstantToJson(CVUExpressionNodeConstant instance) =>
    <String, dynamic>{
      'inParens': instance.inParens,
      'value': instance.value,
    };

CVUExpressionNodeLessThan _$CVUExpressionNodeLessThanFromJson(Map<String, dynamic> json) =>
    CVUExpressionNodeLessThan(
      CVUExpressionNode.fromJson(json['lhs']),
      CVUExpressionNode.fromJson(json['rhs']),
    )..inParens = json['inParens'] as bool;

Map<String, dynamic> _$CVUExpressionNodeLessThanToJson(CVUExpressionNodeLessThan instance) =>
    <String, dynamic>{
      'inParens': instance.inParens,
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeGreaterThan _$CVUExpressionNodeGreaterThanFromJson(Map<String, dynamic> json) =>
    CVUExpressionNodeGreaterThan(
      CVUExpressionNode.fromJson(json['lhs']),
      CVUExpressionNode.fromJson(json['rhs']),
    )..inParens = json['inParens'] as bool;

Map<String, dynamic> _$CVUExpressionNodeGreaterThanToJson(CVUExpressionNodeGreaterThan instance) =>
    <String, dynamic>{
      'inParens': instance.inParens,
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeLessThanOrEqual _$CVUExpressionNodeLessThanOrEqualFromJson(
        Map<String, dynamic> json) =>
    CVUExpressionNodeLessThanOrEqual(
      CVUExpressionNode.fromJson(json['lhs']),
      CVUExpressionNode.fromJson(json['rhs']),
    )..inParens = json['inParens'] as bool;

Map<String, dynamic> _$CVUExpressionNodeLessThanOrEqualToJson(
        CVUExpressionNodeLessThanOrEqual instance) =>
    <String, dynamic>{
      'inParens': instance.inParens,
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeGreaterThanOrEqual _$CVUExpressionNodeGreaterThanOrEqualFromJson(
        Map<String, dynamic> json) =>
    CVUExpressionNodeGreaterThanOrEqual(
      CVUExpressionNode.fromJson(json['lhs']),
      CVUExpressionNode.fromJson(json['rhs']),
    )..inParens = json['inParens'] as bool;

Map<String, dynamic> _$CVUExpressionNodeGreaterThanOrEqualToJson(
        CVUExpressionNodeGreaterThanOrEqual instance) =>
    <String, dynamic>{
      'inParens': instance.inParens,
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeAreEqual _$CVUExpressionNodeAreEqualFromJson(Map<String, dynamic> json) =>
    CVUExpressionNodeAreEqual(
      CVUExpressionNode.fromJson(json['lhs']),
      CVUExpressionNode.fromJson(json['rhs']),
    )..inParens = json['inParens'] as bool;

Map<String, dynamic> _$CVUExpressionNodeAreEqualToJson(CVUExpressionNodeAreEqual instance) =>
    <String, dynamic>{
      'inParens': instance.inParens,
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeAreNotEqual _$CVUExpressionNodeAreNotEqualFromJson(Map<String, dynamic> json) =>
    CVUExpressionNodeAreNotEqual(
      CVUExpressionNode.fromJson(json['lhs']),
      CVUExpressionNode.fromJson(json['rhs']),
    )..inParens = json['inParens'] as bool;

Map<String, dynamic> _$CVUExpressionNodeAreNotEqualToJson(CVUExpressionNodeAreNotEqual instance) =>
    <String, dynamic>{
      'inParens': instance.inParens,
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeAnd _$CVUExpressionNodeAndFromJson(Map<String, dynamic> json) =>
    CVUExpressionNodeAnd(
      CVUExpressionNode.fromJson(json['lhs']),
      CVUExpressionNode.fromJson(json['rhs']),
      json['inParens'] as bool? ?? false,
    );

Map<String, dynamic> _$CVUExpressionNodeAndToJson(CVUExpressionNodeAnd instance) =>
    <String, dynamic>{
      'inParens': instance.inParens,
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeNamed _$CVUExpressionNodeNamedFromJson(Map<String, dynamic> json) =>
    CVUExpressionNodeNamed(
      json['key'] as String,
      CVUExpressionNode.fromJson(json['value']),
    )..inParens = json['inParens'] as bool;

Map<String, dynamic> _$CVUExpressionNodeNamedToJson(CVUExpressionNodeNamed instance) =>
    <String, dynamic>{
      'inParens': instance.inParens,
      'key': instance.key,
      'value': instance.value,
    };
