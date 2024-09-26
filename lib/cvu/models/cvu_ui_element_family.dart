//  Created by T Brennan on 28/1/21.

import 'package:memri/utilities/extensions/collection.dart';

/// This enum contains the supported CVU UI elements. The rawValue is a lowercase representation so that all comparisons can be -insensitive
enum CVUUIElementFamily {
  ForEach,
  VStack,
  HStack,
  ZStack,
  FlowStack,
  Text,
  SmartText,
  Image,
  Picker,
  MemriButton,
  MessageComposer,
  Button,
  ActionButton,
  Empty,
  Spacer,
  Divider,
  Circle,
  Rectangle,
  EditorSection,
  SubView,
  HTMLView,
  TimelineItem,
  FileThumbnail,
  Null,
  Grid,
  DropZone,
  Wrap,
  Dropdown,
  RichText,
  LoadingIndicator,
  Map,
  Toggle,
}

extension CVUUIElementFamilyExtension on CVUUIElementFamily {
  String get inString => this.toString().split(".").last;

  String get value => this.inString.toLowerCase();

  static CVUUIElementFamily? rawValue(value) =>
      CVUUIElementFamily.values.firstWhereOrNull((val) => val.value == value);
}
