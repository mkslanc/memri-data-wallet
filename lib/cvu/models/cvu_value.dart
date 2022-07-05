//  Created by T Brennan on 7/12/20.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:memri/cvu/models/cvu_lexer.dart';
import 'package:memri/cvu/models/cvu_parsed_definition.dart';
import 'package:memri/cvu/models/cvu_value_constant.dart';
import 'package:memri/cvu/models/cvu_value_expression.dart';

import '../services/parsing/cvu_string_convertible.dart';

part 'cvu_value.g.dart';

@JsonSerializable()
class CVUValueExpression extends CVUValue {
  final CVUExpressionNode value;

  CVUValueExpression(this.value, {CVUTokenLocation? tokenLocation})
      : super(tokenLocation);

  factory CVUValueExpression.fromJson(Map<String, dynamic> json) =>
      _$CVUValueExpressionFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUValueExpressionToJson(this)..addAll({"type": "CVUValueExpression"});
}

@JsonSerializable()
class CVUValueConstant extends CVUValue {
  final CVUConstant value;

  CVUValueConstant(this.value, {CVUTokenLocation? tokenLocation})
      : super(tokenLocation);

  factory CVUValueConstant.fromJson(Map<String, dynamic> json) =>
      _$CVUValueConstantFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUValueConstantToJson(this)..addAll({"type": "CVUValueConstant"});
}

@JsonSerializable()
class CVUValueItem extends CVUValue {
  final String value;

  CVUValueItem(this.value, {CVUTokenLocation? tokenLocation})
      : super(tokenLocation);

  factory CVUValueItem.fromJson(Map<String, dynamic> json) =>
      _$CVUValueItemFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUValueItemToJson(this)..addAll({"type": "CVUValueItem"});
}

@JsonSerializable()
class CVUValueArray extends CVUValue {
  final List<CVUValue> value;

  CVUValueArray(this.value, {CVUTokenLocation? tokenLocation})
      : super(tokenLocation);

  factory CVUValueArray.fromJson(Map<String, dynamic> json) =>
      _$CVUValueArrayFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUValueArrayToJson(this)..addAll({"type": "CVUValueArray"});
}

@JsonSerializable()
class CVUValueDictionary extends CVUValue {
  final Map<String, CVUValue> value;

  CVUValueDictionary(this.value, {CVUTokenLocation? tokenLocation})
      : super(tokenLocation);

  factory CVUValueDictionary.fromJson(Map<String, dynamic> json) =>
      _$CVUValueDictionaryFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CVUValueDictionaryToJson(this)..addAll({"type": "CVUValueDictionary"});
}

@JsonSerializable()
class CVUValueSubdefinition extends CVUValue {
  final CVUDefinitionContent value;

  CVUValueSubdefinition(this.value, {CVUTokenLocation? tokenLocation})
      : super(tokenLocation);

  factory CVUValueSubdefinition.fromJson(Map<String, dynamic> json) =>
      _$CVUValueSubdefinitionFromJson(json);

  Map<String, dynamic> toJson() => _$CVUValueSubdefinitionToJson(this)
    ..addAll({"type": "CVUValueSubdefinition"});
}

/// A value of a CVU property that can be serialised both to CVU format and to JSON
abstract class CVUValue with EquatableMixin implements CVUStringConvertible {
  get value;

  CVUTokenLocation? tokenLocation;

  CVUValue([this.tokenLocation]);

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
      String uid = cvuValue.value;
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
