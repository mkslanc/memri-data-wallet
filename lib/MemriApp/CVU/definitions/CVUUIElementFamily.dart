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
  static const values = {
    CVUUIElementFamily.ForEach: "foreach",
    CVUUIElementFamily.VStack: "vstack",
    CVUUIElementFamily.HStack: "hstack",
    CVUUIElementFamily.ZStack: "zstack",
    CVUUIElementFamily.FlowStack: "flowstack",
    CVUUIElementFamily.Text: "text",
    CVUUIElementFamily.SmartText: "smarttext",
    CVUUIElementFamily.Textfield: "textfield",
    CVUUIElementFamily.Image: "image",
    CVUUIElementFamily.Toggle: "toggle",
    CVUUIElementFamily.Picker: "picker",
    CVUUIElementFamily.MemriButton: "memributton",
    CVUUIElementFamily.Button: "button",
    CVUUIElementFamily.ActionButton: "actionbutton",
    CVUUIElementFamily.Map: "map",
    CVUUIElementFamily.Empty: "empty",
    CVUUIElementFamily.Spacer: "spacer",
    CVUUIElementFamily.Divider: "divider",
    CVUUIElementFamily.HorizontalLine: "horizontalline",
    CVUUIElementFamily.Circle: "circle",
    CVUUIElementFamily.Rectangle: "rectangle",
    CVUUIElementFamily.EditorSection: "editorsection",
    CVUUIElementFamily.EditorRow: "editorrow",
    CVUUIElementFamily.SubView: "subview",
    CVUUIElementFamily.HTMLView: "htmlview",
    CVUUIElementFamily.TimelineItem: "timelineitem",
    CVUUIElementFamily.FileThumbnail: "filethumbnail",
  };

  String get value => values[this]!;
  static CVUUIElementFamily rawValue(value) => values.keys.firstWhere(
    (k) => values[k] == value, orElse: () => CVUUIElementFamily.Null//TODO @anijanyan see why this isn't nullable
  );
}
