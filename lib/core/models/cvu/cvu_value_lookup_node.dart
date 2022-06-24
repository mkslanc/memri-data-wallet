//  Created by T Brennan on 28/1/21.

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:memri/core/models/cvu/cvu_value_expression.dart';

part 'cvu_value_lookup_node.g.dart';

/// A single node in a CVU Expression lookup. The `default` node (`.` in CVU) represents the current item in the CVU context
@JsonSerializable()
class CVULookupNode with EquatableMixin {
  String name;
  bool isArray;
  CVULookupType type;

  CVULookupNode({required this.name, required this.type, this.isArray = false});

  static get defaultLookup {
    return CVULookupNode(name: "@@DEFAULT@@", type: CVULookupTypeDefault());
  }

  String toCVUString() {
    var lookupType = type;
    if (lookupType is CVULookupTypeDefault) {
      return "";
    } else if (lookupType is CVULookupTypeFunction) {
      return '$name(${lookupType.args.map((element) => element.toCVUString()).join(", ")})';
    } else {
      return '$name${isArray ? "[${lookupType is CVULookupTypeLookup ? (lookupType.subexpressions?.map((element) => element.toCVUString()).join(", ") ?? "") : ""}]" : ""}';
    }
  }

  factory CVULookupNode.fromJson(Map<String, dynamic> json) =>
      _$CVULookupNodeFromJson(json);

  Map<String, dynamic> toJson() => _$CVULookupNodeToJson(this);

  @override
  List<Object?> get props => [name, isArray, type];
}

class CVULookupTypeDefault extends CVULookupType {
  Map<String, dynamic> toJson() => {"type": "CVULookupTypeDefault"};

  @override
  List<Object?> get props => [];
}

@JsonSerializable()
class CVULookupTypeLookup extends CVULookupType {
  final List<CVUExpressionNode>? subexpressions;

  CVULookupTypeLookup([this.subexpressions]);

  factory CVULookupTypeLookup.fromJson(Map<String, dynamic> json) =>
      _$CVULookupTypeLookupFromJson(json);

  Map<String, dynamic> toJson() => _$CVULookupTypeLookupToJson(this)
    ..addAll({"type": "CVULookupTypeLookup"});

  @override
  List<Object?> get props => [subexpressions];
}

@JsonSerializable()
class CVULookupTypeFunction extends CVULookupType {
  final List<CVUExpressionNode> args;

  CVULookupTypeFunction(this.args);

  factory CVULookupTypeFunction.fromJson(Map<String, dynamic> json) =>
      _$CVULookupTypeFunctionFromJson(json);

  Map<String, dynamic> toJson() => _$CVULookupTypeFunctionToJson(this)
    ..addAll({"type": "CVULookupTypeFunction"});

  @override
  List<Object?> get props => [args];
}

abstract class CVULookupType with EquatableMixin {
  CVULookupType();

  factory CVULookupType.fromJson(json) {
    switch (json["type"]) {
      case "CVULookupTypeDefault":
        return CVULookupTypeDefault();
      case "CVULookupTypeLookup":
        return CVULookupTypeLookup.fromJson(json);
      case "CVULookupTypeFunction":
        return CVULookupTypeFunction.fromJson(json);
      default:
        throw Exception("Unknown CVULookupType: ${json["type"]}");
    }
  }

  Map<String, dynamic> toJson();
}
