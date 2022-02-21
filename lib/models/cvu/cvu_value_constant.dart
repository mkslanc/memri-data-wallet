//  Created by T Brennan on 28/1/21.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cvu_value_constant.g.dart';

/// A constant value that can be serialised to/from CVU and JSON
/// This can be an argument (single word string with no quotes), string, number, bool, colorHex (eg. #FFFFFF), or nil
abstract class CVUConstant with EquatableMixin {
  get value => null;

  CVUConstant();

  /// Get a string representation of the value
  String asString() {
    var cvuConstant = this;
    if (cvuConstant is CVUConstantArgument) {
      return cvuConstant.value;
    } else if (cvuConstant is CVUConstantNumber) {
      return "${cvuConstant.value}";
    } else if (cvuConstant is CVUConstantInt) {
      return "${cvuConstant.value}";
    } else if (cvuConstant is CVUConstantString) {
      return cvuConstant.value;
    } else if (cvuConstant is CVUConstantBool) {
      return "${cvuConstant.value}";
    } else if (cvuConstant is CVUConstantColorHex) {
      return cvuConstant.value;
    } else if (cvuConstant is CVUConstantNil) {
      return "";
    } else {
      throw Exception("Unknown CVUConstant ${cvuConstant.toString()}");
    }
  }

  /// Get a number representation of the value (may return nil)
  double? asNumber() {
    var cvuConstant = this;
    if (cvuConstant is CVUConstantArgument) {
      return null;
    } else if (cvuConstant is CVUConstantNumber) {
      return cvuConstant.value;
    } else if (cvuConstant is CVUConstantInt) {
      return cvuConstant.value.toDouble();
    } else if (cvuConstant is CVUConstantString) {
      return double.tryParse(cvuConstant.value);
    } else if (cvuConstant is CVUConstantBool) {
      return cvuConstant.value ? 1 : 0;
    } else if (cvuConstant is CVUConstantColorHex) {
      return null;
    } else if (cvuConstant is CVUConstantNil) {
      return null;
    } else {
      throw Exception("Unknown CVUConstant ${cvuConstant.toString()}");
    }
  }

  /// Get a number representation of the value (may return nil)
  int? asInt() {
    var cvuConstant = this;
    if (cvuConstant is CVUConstantArgument) {
      return null;
    } else if (cvuConstant is CVUConstantNumber) {
      return cvuConstant.value.toInt();
    } else if (cvuConstant is CVUConstantInt) {
      return cvuConstant.value;
    } else if (cvuConstant is CVUConstantString) {
      return int.tryParse(cvuConstant.value);
    } else if (cvuConstant is CVUConstantBool) {
      return cvuConstant.value ? 1 : 0;
    } else if (cvuConstant is CVUConstantColorHex) {
      return null;
    } else if (cvuConstant is CVUConstantNil) {
      return null;
    } else {
      throw Exception("Unknown CVUConstant ${cvuConstant.toString()}");
    }
  }

  /// Get a boolean representation of the value (may return nil for types not easily converted to bool)
  bool? asBool() {
    var cvuConstant = this;
    if (cvuConstant is CVUConstantArgument) {
      return null;
    } else if (cvuConstant is CVUConstantNumber) {
      return cvuConstant.value > 0;
    } else if (cvuConstant is CVUConstantInt) {
      return cvuConstant.value > 0;
    } else if (cvuConstant is CVUConstantString) {
      return cvuConstant.value != "" && cvuConstant.value != "false";
    } else if (cvuConstant is CVUConstantBool) {
      return cvuConstant.value;
    } else if (cvuConstant is CVUConstantColorHex) {
      return null;
    } else if (cvuConstant is CVUConstantNil) {
      return null;
    } else {
      throw Exception("Unknown CVUConstant ${cvuConstant.toString()}");
    }
  }

  String toCVUString([bool insideStringMode = false]) {
    var cvuConstant = this;
    if (cvuConstant is CVUConstantArgument) {
      return cvuConstant.value;
    } else if (cvuConstant is CVUConstantInt) {
      return cvuConstant.value.toString();
    } else if (cvuConstant is CVUConstantNumber) {
      double n = cvuConstant.value;
      return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
    } else if (cvuConstant is CVUConstantString) {
      String escaped = cvuConstant.value.replaceAll("\"", "\\\"");
      var quote = cvuConstant.isSingleQuote ? "'" : '"';
      return insideStringMode ? escaped : "$quote$escaped$quote";
    } else if (cvuConstant is CVUConstantBool) {
      return cvuConstant.value ? "true" : "false";
    } else if (cvuConstant is CVUConstantColorHex) {
      return '#${cvuConstant.value}';
    } else if (cvuConstant is CVUConstantNil) {
      return "nil";
    } else {
      throw Exception("Unknown CVUConstant ${cvuConstant.toString()}");
    }
  }

  factory CVUConstant.fromJson(json) {
    switch (json["type"]) {
      case "CVUConstantArgument":
        return CVUConstantArgument.fromJson(json);
      case "CVUConstantNumber":
        return CVUConstantNumber.fromJson(json);
      case "CVUConstantInt":
        return CVUConstantInt.fromJson(json);
      case "CVUConstantString":
        return CVUConstantString.fromJson(json);
      case "CVUConstantBool":
        return CVUConstantBool.fromJson(json);
      case "CVUConstantColorHex":
        return CVUConstantColorHex.fromJson(json);
      case "CVUConstantNil":
        return CVUConstantNil();
      default:
        throw Exception("Unknown CVUConstant: ${json["type"]}");
    }
  }

  Map<String, dynamic> toJson() => {'value': value, 'type': runtimeType.toString()};

  @override
  List<Object?> get props => [value];
}

@JsonSerializable(createToJson: false)
class CVUConstantArgument extends CVUConstant {
  final String value;

  CVUConstantArgument(this.value);

  factory CVUConstantArgument.fromJson(Map<String, dynamic> json) =>
      _$CVUConstantArgumentFromJson(json);
}

@JsonSerializable(createToJson: false)
class CVUConstantNumber extends CVUConstant {
  final double value;

  CVUConstantNumber(this.value);

  factory CVUConstantNumber.fromJson(Map<String, dynamic> json) =>
      _$CVUConstantNumberFromJson(json);
}

@JsonSerializable(createToJson: false)
class CVUConstantInt extends CVUConstant {
  final int value;

  CVUConstantInt(this.value);

  factory CVUConstantInt.fromJson(Map<String, dynamic> json) => _$CVUConstantIntFromJson(json);
}

@JsonSerializable(createToJson: false)
class CVUConstantString extends CVUConstant {
  final String value;
  final bool isSingleQuote;

  CVUConstantString(this.value, [this.isSingleQuote = false]);

  factory CVUConstantString.fromJson(Map<String, dynamic> json) =>
      _$CVUConstantStringFromJson(json);
}

@JsonSerializable(createToJson: false)
class CVUConstantBool extends CVUConstant {
  final bool value;

  CVUConstantBool(this.value);

  factory CVUConstantBool.fromJson(Map<String, dynamic> json) => _$CVUConstantBoolFromJson(json);
}

@JsonSerializable(createToJson: false)
class CVUConstantColorHex extends CVUConstant {
  final String value;

  CVUConstantColorHex(this.value);

  factory CVUConstantColorHex.fromJson(Map<String, dynamic> json) =>
      _$CVUConstantColorHexFromJson(json);
}

class CVUConstantNil extends CVUConstant {}
