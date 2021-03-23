//
//  CVUValue_LookupNode.swift
//  Memri
//
//  Created by T Brennan on 28/1/21.
//

import 'CVUValue_Expression.dart';

/// A single node in a CVU Expression lookup. The `default` node (`.` in CVU) represents the current item in the CVU context
class CVULookupNode {
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
      return '$name${isArray ? "[]" : ""}';
    }
  }
}

class CVULookupTypeDefault extends CVULookupType {}

class CVULookupTypeLookup extends CVULookupType {
  final CVUExpressionNode? subExpression;

  CVULookupTypeLookup([this.subExpression]);
}

class CVULookupTypeFunction extends CVULookupType {
  final List<CVUExpressionNode> args;

  CVULookupTypeFunction(this.args);
}

abstract class CVULookupType {}
