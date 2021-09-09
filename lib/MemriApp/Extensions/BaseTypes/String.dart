import 'dart:convert';

import 'dart:io';

import 'package:flutter/foundation.dart';

extension StringExtension on String {
  String? get nullIfBlank {
    return RegExp(r"^\s*$").hasMatch(this) ? null : this;
  }

  String capitalizingFirst() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }

  String titleCase() {
    return this.split(r"^\s*$").map((el) => el.capitalizingFirst()).join(" ");
  }

  String camelCaseToWords() {
    return this
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) {
          return ' ${match.group(1)}';
        })
        .toLowerCase()
        .capitalizingFirst();
  }

  String escapeForJavascript() {
    var str = jsonEncode([this]);
    return str.substring(2, str.length - 2);
  }

  String? get fileName {
    var separator = '/';
    if (!kIsWeb) {
      separator = Platform.pathSeparator;
    }
    var name = this.split(separator).last.split(".").asMap()[0] ?? "";
    return name.isEmpty ? null : name;
  }

  String? get fileExtension {
    var separator = '/';
    if (!kIsWeb) {
      separator = Platform.pathSeparator;
    }
    var ext = this.split(separator).last.split(".").asMap()[1] ?? "";
    return ext.isEmpty ? null : ext;
  }
}
