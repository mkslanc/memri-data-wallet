//
//  CVUUIElementFamily.swift
//  Memri
//
//  Created by T Brennan on 28/1/21.
//

/// This enum contains the supported CVU UI elements. The rawValue is a lowercase representation so that all comparisons can be -insensitive
enum CVUUIElementFamily {
  ForEach,
  VStack,
  HStack,
  ZStack,
  FlowStack,
  Text,
  SmartText,
  Textfield,
  Image,
  Toggle,
  Picker,
  MemriButton,
  Button,
  ActionButton,
  Map,
  Empty,
  Spacer,
  Divider,
  HorizontalLine,
  Circle,
  Rectangle,
  EditorSection,
  EditorRow,
  SubView,
  HTMLView,
  TimelineItem,
  FileThumbnail,
  Null
}

extension CVUUIElementFamilyExtension on CVUUIElementFamily {
  String get inString => this.toString().split(".").last;

  String get value => this.inString.toLowerCase();

  static CVUUIElementFamily rawValue(value) =>
      CVUUIElementFamily.values.firstWhere((val) => val.value == value,
          orElse: () => CVUUIElementFamily.Null //TODO @anijanyan see why this isn't nullable
          );
}
