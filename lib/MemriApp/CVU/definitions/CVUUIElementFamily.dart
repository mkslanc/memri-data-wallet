//
//  CVUUIElementFamily.swift
//  Memri
//
//  Created by T Brennan on 28/1/21.
//

import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';

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
  MessageComposer,
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
  Null,
  Grid,
  DropZone,
  Observer,
  Wrap
}

extension CVUUIElementFamilyExtension on CVUUIElementFamily {
  String get inString => this.toString().split(".").last;

  String get value => this.inString.toLowerCase();

  static CVUUIElementFamily? rawValue(value) =>
      CVUUIElementFamily.values.firstWhereOrNull((val) => val.value == value);
}
