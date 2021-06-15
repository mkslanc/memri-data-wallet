// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CVUValue_Expression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CVUExpressionNodeLookup _$CVUExpressionNodeLookupFromJson(Map<String, dynamic> json) {
  return CVUExpressionNodeLookup(
    (json['nodes'] as List<dynamic>)
        .map((e) => CVULookupNode.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$CVUExpressionNodeLookupToJson(CVUExpressionNodeLookup instance) =>
    <String, dynamic>{
      'nodes': instance.nodes,
    };

CVUExpressionNodeStringMode _$CVUExpressionNodeStringModeFromJson(Map<String, dynamic> json) {
  return CVUExpressionNodeStringMode(
    (json['nodes'] as List<dynamic>).map((e) => CVUExpressionNode.fromJson(e)).toList(),
  );
}

Map<String, dynamic> _$CVUExpressionNodeStringModeToJson(CVUExpressionNodeStringMode instance) =>
    <String, dynamic>{
      'nodes': instance.nodes,
    };

CVUExpressionNodeConditional _$CVUExpressionNodeConditionalFromJson(Map<String, dynamic> json) {
  return CVUExpressionNodeConditional(
    CVUExpressionNode.fromJson(json['condition']),
    CVUExpressionNode.fromJson(json['trueExp']),
    CVUExpressionNode.fromJson(json['falseExp']),
  );
}

Map<String, dynamic> _$CVUExpressionNodeConditionalToJson(CVUExpressionNodeConditional instance) =>
    <String, dynamic>{
      'condition': instance.condition,
      'trueExp': instance.trueExp,
      'falseExp': instance.falseExp,
    };

CVUExpressionNodeOr _$CVUExpressionNodeOrFromJson(Map<String, dynamic> json) {
  return CVUExpressionNodeOr(
    CVUExpressionNode.fromJson(json['lhs']),
    CVUExpressionNode.fromJson(json['rhs']),
  );
}

Map<String, dynamic> _$CVUExpressionNodeOrToJson(CVUExpressionNodeOr instance) => <String, dynamic>{
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeNegation _$CVUExpressionNodeNegationFromJson(Map<String, dynamic> json) {
  return CVUExpressionNodeNegation(
    CVUExpressionNode.fromJson(json['expression']),
  );
}

Map<String, dynamic> _$CVUExpressionNodeNegationToJson(CVUExpressionNodeNegation instance) =>
    <String, dynamic>{
      'expression': instance.expression,
    };

CVUExpressionNodeAddition _$CVUExpressionNodeAdditionFromJson(Map<String, dynamic> json) {
  return CVUExpressionNodeAddition(
    CVUExpressionNode.fromJson(json['lhs']),
    CVUExpressionNode.fromJson(json['rhs']),
  );
}

Map<String, dynamic> _$CVUExpressionNodeAdditionToJson(CVUExpressionNodeAddition instance) =>
    <String, dynamic>{
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeSubtraction _$CVUExpressionNodeSubtractionFromJson(Map<String, dynamic> json) {
  return CVUExpressionNodeSubtraction(
    CVUExpressionNode.fromJson(json['lhs']),
    CVUExpressionNode.fromJson(json['rhs']),
  );
}

Map<String, dynamic> _$CVUExpressionNodeSubtractionToJson(CVUExpressionNodeSubtraction instance) =>
    <String, dynamic>{
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeMultiplication _$CVUExpressionNodeMultiplicationFromJson(
    Map<String, dynamic> json) {
  return CVUExpressionNodeMultiplication(
    CVUExpressionNode.fromJson(json['lhs']),
    CVUExpressionNode.fromJson(json['rhs']),
  );
}

Map<String, dynamic> _$CVUExpressionNodeMultiplicationToJson(
        CVUExpressionNodeMultiplication instance) =>
    <String, dynamic>{
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeDivision _$CVUExpressionNodeDivisionFromJson(Map<String, dynamic> json) {
  return CVUExpressionNodeDivision(
    CVUExpressionNode.fromJson(json['lhs']),
    CVUExpressionNode.fromJson(json['rhs']),
  );
}

Map<String, dynamic> _$CVUExpressionNodeDivisionToJson(CVUExpressionNodeDivision instance) =>
    <String, dynamic>{
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeConstant _$CVUExpressionNodeConstantFromJson(Map<String, dynamic> json) {
  return CVUExpressionNodeConstant(
    CVUConstant.fromJson(json['value']),
  );
}

Map<String, dynamic> _$CVUExpressionNodeConstantToJson(CVUExpressionNodeConstant instance) =>
    <String, dynamic>{
      'value': instance.value,
    };

CVUExpressionNodeLessThan _$CVUExpressionNodeLessThanFromJson(Map<String, dynamic> json) {
  return CVUExpressionNodeLessThan(
    CVUExpressionNode.fromJson(json['lhs']),
    CVUExpressionNode.fromJson(json['rhs']),
  );
}

Map<String, dynamic> _$CVUExpressionNodeLessThanToJson(CVUExpressionNodeLessThan instance) =>
    <String, dynamic>{
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeGreaterThan _$CVUExpressionNodeGreaterThanFromJson(Map<String, dynamic> json) {
  return CVUExpressionNodeGreaterThan(
    CVUExpressionNode.fromJson(json['lhs']),
    CVUExpressionNode.fromJson(json['rhs']),
  );
}

Map<String, dynamic> _$CVUExpressionNodeGreaterThanToJson(CVUExpressionNodeGreaterThan instance) =>
    <String, dynamic>{
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeLessThanOrEqual _$CVUExpressionNodeLessThanOrEqualFromJson(
    Map<String, dynamic> json) {
  return CVUExpressionNodeLessThanOrEqual(
    CVUExpressionNode.fromJson(json['lhs']),
    CVUExpressionNode.fromJson(json['rhs']),
  );
}

Map<String, dynamic> _$CVUExpressionNodeLessThanOrEqualToJson(
        CVUExpressionNodeLessThanOrEqual instance) =>
    <String, dynamic>{
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeGreaterThanOrEqual _$CVUExpressionNodeGreaterThanOrEqualFromJson(
    Map<String, dynamic> json) {
  return CVUExpressionNodeGreaterThanOrEqual(
    CVUExpressionNode.fromJson(json['lhs']),
    CVUExpressionNode.fromJson(json['rhs']),
  );
}

Map<String, dynamic> _$CVUExpressionNodeGreaterThanOrEqualToJson(
        CVUExpressionNodeGreaterThanOrEqual instance) =>
    <String, dynamic>{
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeAreEqual _$CVUExpressionNodeAreEqualFromJson(Map<String, dynamic> json) {
  return CVUExpressionNodeAreEqual(
    CVUExpressionNode.fromJson(json['lhs']),
    CVUExpressionNode.fromJson(json['rhs']),
  );
}

Map<String, dynamic> _$CVUExpressionNodeAreEqualToJson(CVUExpressionNodeAreEqual instance) =>
    <String, dynamic>{
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeAreNotEqual _$CVUExpressionNodeAreNotEqualFromJson(Map<String, dynamic> json) {
  return CVUExpressionNodeAreNotEqual(
    CVUExpressionNode.fromJson(json['lhs']),
    CVUExpressionNode.fromJson(json['rhs']),
  );
}

Map<String, dynamic> _$CVUExpressionNodeAreNotEqualToJson(CVUExpressionNodeAreNotEqual instance) =>
    <String, dynamic>{
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };

CVUExpressionNodeAnd _$CVUExpressionNodeAndFromJson(Map<String, dynamic> json) {
  return CVUExpressionNodeAnd(
    CVUExpressionNode.fromJson(json['lhs']),
    CVUExpressionNode.fromJson(json['rhs']),
  );
}

Map<String, dynamic> _$CVUExpressionNodeAndToJson(CVUExpressionNodeAnd instance) =>
    <String, dynamic>{
      'lhs': instance.lhs,
      'rhs': instance.rhs,
    };
