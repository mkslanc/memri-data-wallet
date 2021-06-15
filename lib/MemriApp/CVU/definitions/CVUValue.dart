//
//  CVUValue.swift
//  MemriDatabase
//
//  Created by T Brennan on 7/12/20.
//

import 'package:equatable/equatable.dart';
import 'package:memri/MemriApp/CVU/parsing/CVUStringConvertible.dart';

import 'CVUParsedDefinition.dart';
import 'CVUValue_Constant.dart';
import 'CVUValue_Expression.dart';

import 'package:json_annotation/json_annotation.dart';

part 'CVUValue.g.dart';

@JsonSerializable()
class CVUValueExpression extends CVUValue {
  final CVUExpressionNode value;

  CVUValueExpression(this.value);

  factory CVUValueExpression.fromJson(Map<String, dynamic> json) =>
      _$CVUValueExpressionFromJson(json);
  Map<String, dynamic> toJson() =>
      _$CVUValueExpressionToJson(this)..addAll({"type": runtimeType.toString()});
}

@JsonSerializable()
class CVUValueConstant extends CVUValue {
  final CVUConstant value;

  CVUValueConstant(this.value);

  factory CVUValueConstant.fromJson(Map<String, dynamic> json) => _$CVUValueConstantFromJson(json);
  Map<String, dynamic> toJson() =>
      _$CVUValueConstantToJson(this)..addAll({"type": runtimeType.toString()});
}

@JsonSerializable()
class CVUValueItem extends CVUValue {
  final int value;

  CVUValueItem(this.value);

  factory CVUValueItem.fromJson(Map<String, dynamic> json) => _$CVUValueItemFromJson(json);
  Map<String, dynamic> toJson() =>
      _$CVUValueItemToJson(this)..addAll({"type": runtimeType.toString()});
}

@JsonSerializable()
class CVUValueArray extends CVUValue {
  final List<CVUValue> value;

  CVUValueArray(this.value);

  factory CVUValueArray.fromJson(Map<String, dynamic> json) => _$CVUValueArrayFromJson(json);
  Map<String, dynamic> toJson() =>
      _$CVUValueArrayToJson(this)..addAll({"type": runtimeType.toString()});
}

@JsonSerializable()
class CVUValueDictionary extends CVUValue {
  final Map<String, CVUValue> value;

  CVUValueDictionary(this.value);

  factory CVUValueDictionary.fromJson(Map<String, dynamic> json) =>
      _$CVUValueDictionaryFromJson(json);
  Map<String, dynamic> toJson() =>
      _$CVUValueDictionaryToJson(this)..addAll({"type": runtimeType.toString()});
}

@JsonSerializable()
class CVUValueSubdefinition extends CVUValue {
  final CVUDefinitionContent value;

  CVUValueSubdefinition(this.value);

  factory CVUValueSubdefinition.fromJson(Map<String, dynamic> json) =>
      _$CVUValueSubdefinitionFromJson(json);
  Map<String, dynamic> toJson() =>
      _$CVUValueSubdefinitionToJson(this)..addAll({"type": runtimeType.toString()});
}

/// A value of a CVU property that can be serialised both to CVU format and to JSON
abstract class CVUValue with EquatableMixin implements CVUStringConvertible {
  get value;

  CVUValue();

  @override
  String toCVUString(int depth, String tab, bool includeInitialTab) {
    var cvuValue = this;

    if (cvuValue is CVUValueExpression) {
      CVUExpressionNode expression = cvuValue.value;
      String innerString = expression.toCVUString();
      if (expression is CVUExpressionNodeStringMode) {
        return '"$innerString"';
      } else {
        return '{{$innerString}}';
      }
    } else if (cvuValue is CVUValueConstant) {
      return cvuValue.value.toCVUString();
    } else if (cvuValue is CVUValueItem) {
      int uid = cvuValue.value;
      return '{{item($uid)}}';
    } else if (cvuValue is CVUValueArray) {
      List<CVUValue> values = cvuValue.value;
      return values.toCVUString(depth, tab, false);
    } else if (cvuValue is CVUValueDictionary) {
      Map<String, CVUValue> dict = cvuValue.value;
      return '{\n${dict.toCVUString(depth, tab, true)}\n}';
    } else if (cvuValue is CVUValueSubdefinition) {
      CVUDefinitionContent x = cvuValue.value;
      return x.toCVUString(depth, tab, includeInitialTab);
    } else {
      throw Exception("Unknown CVUValue: ${this.toString()}");
    }
  }

  CVUDefinitionContent? getSubdefinition() {
    var cvuValue = this;
    if (cvuValue is CVUValueSubdefinition) {
      return cvuValue.value;
    } else {
      return null;
    }
  }

  factory CVUValue.fromJson(json) {
    switch (json["type"]) {
      case "CVUValueExpression":
        return CVUValueExpression.fromJson(json);
      case "CVUValueConstant":
        return CVUValueConstant.fromJson(json);
      case "CVUValueItem":
        return CVUValueItem.fromJson(json);
      case "CVUValueArray":
        return CVUValueArray.fromJson(json);
      case "CVUValueDictionary":
        return CVUValueDictionary.fromJson(json);
      case "CVUValueSubdefinition":
        return CVUValueSubdefinition.fromJson(json);
      default:
        throw Exception("Unknown CVUValue: ${json["type"]}");
    }
  }

  Map<String, dynamic> toJson();

  @override
  List<Object?> get props => [value];
}
