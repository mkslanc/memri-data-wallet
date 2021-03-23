//
//  CVUValue.swift
//  MemriDatabase
//
//  Created by T Brennan on 7/12/20.
//

import 'package:memri/MemriApp/CVU/parsing/CVUStringConvertible.dart';

import 'CVUParsedDefinition.dart';
import 'CVUValue_Constant.dart';
import 'CVUValue_Expression.dart';

class CVUValueExpression extends CVUValue {
  final CVUExpressionNode value;

  CVUValueExpression(this.value);
}

class CVUValueConstant extends CVUValue {
  final CVUConstant value;

  CVUValueConstant(this.value);
}

class CVUValueItem extends CVUValue {
  final String value;

  CVUValueItem(this.value);
}

class CVUValueArray extends CVUValue {
  final List<CVUValue> value;

  CVUValueArray(this.value);
}

class CVUValueDictionary extends CVUValue {
  final Map<String, CVUValue> value;

  CVUValueDictionary(this.value);
}

class CVUValueSubdefinition extends CVUValue {
  final CVUDefinitionContent value;

  CVUValueSubdefinition(this.value);
}

/// A value of a CVU property that can be serialised both to CVU format and to JSON
abstract class CVUValue implements CVUStringConvertible {
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
}

