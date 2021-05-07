//
//  CVUValue_Constant.swift
//  Memri
//
//  Created by T Brennan on 28/1/21.
//

/// A constant value that can be serialised to/from CVU and JSON
/// This can be an argument (single word string with no quotes), string, number, bool, colorHex (eg. #FFFFFF), or nil
abstract class CVUConstant {
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
      // Number greater than zero = true
      return cvuConstant.value > 0;
    } else if (cvuConstant is CVUConstantNumber) {
      // Int greater than zero = true
      return cvuConstant.value > 0;
    } else if (cvuConstant is CVUConstantString) {
      /// Non-empty string = true (unless string is 'false')
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
      return "${cvuConstant.value.toString()}";
    } else if (cvuConstant is CVUConstantNumber) {
      double n = cvuConstant.value;
      return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
    } else if (cvuConstant is CVUConstantString) {
      String escaped = cvuConstant.value.replaceAll("\"", "\\\"");
      return insideStringMode ? escaped : '"$escaped"';
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
}

class CVUConstantArgument extends CVUConstant {
  final String value;

  CVUConstantArgument(this.value);
}

class CVUConstantNumber extends CVUConstant {
  final double value;

  CVUConstantNumber(this.value);
}

class CVUConstantInt extends CVUConstant {
  final int value;

  CVUConstantInt(this.value);
}

class CVUConstantString extends CVUConstant {
  final String value;

  CVUConstantString(this.value);
}

class CVUConstantBool extends CVUConstant {
  final bool value;

  CVUConstantBool(this.value);
}

class CVUConstantColorHex extends CVUConstant {
  final String value;

  CVUConstantColorHex(this.value);
}

class CVUConstantNil extends CVUConstant {}
