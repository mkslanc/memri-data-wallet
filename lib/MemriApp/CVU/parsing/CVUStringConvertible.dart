//
// CVUToString.swift
// Copyright © 2020 memri. All rights reserved.

abstract class CVUStringConvertible {
  String? toCVUString(int depth, String tab, bool includeInitialTab);
}

extension ListCVUStringConvertible on List {
  String toCVUString(int depth, String tab, bool includeInitialTab) {
    List strings = map((value) {
      return (value is CVUStringConvertible)
          ? value.toCVUString(depth + 1, tab, false)
          : null;
    }).where((element) => element != null).toList();

    if (strings.isEmpty) {
      return "[]";
    }
    bool isMultiline = false;
    for (String string in strings) {
      if (string.contains("\n")) {
        isMultiline = true;
        break;
      }
    }
    String tabs = tab * depth;
    String tabsPlus = tab * (depth + 1);
    return '${(isMultiline && includeInitialTab) ? tabs : ""}${isMultiline ? '[\n$tabsPlus' : ""}${strings.join(isMultiline ? '\n$tabsPlus' : " ")}${isMultiline ? '\n$tabs]' : ""}';
  }
}

extension MapCVUStringConvertible on Map {
  String toCVUString(int depth, String tab, bool includeInitialTab) {
    List strings = map((key, value) {
      return MapEntry(
          key,
          (value is CVUStringConvertible)
              ? '$key: ${(value.toCVUString(depth, tab, false))}'
              : null);
    }).values.where((element) => element != null).toList();
    strings.sort();
    String tabs = tab * depth;
    return '${includeInitialTab ? tabs : ""}${strings.join('\n$tabs')}';
  }
}