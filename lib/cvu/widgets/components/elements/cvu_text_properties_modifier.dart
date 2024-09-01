import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../services/resolving/cvu_property_resolver.dart';

/// Modifier used to apply text CVU properties (such as font, color, textAlignment, lineLimit)
class CVUTextPropertiesModifier {
  CVUPropertyResolver propertyResolver;

  CVUTextPropertiesModifier({required this.propertyResolver});

  TextProperties init() {
    var font = propertyResolver.font();
    var color = propertyResolver.color();
    var textAlign = propertyResolver.textAlignment();
    var lineLimit = propertyResolver.lineLimit;
    return TextProperties(
        textStyle: TextStyle(
          fontFamily: font.name,
          fontSize: font.size,
          fontWeight: font.weight,
          fontStyle: font.italic ? FontStyle.italic : FontStyle.normal,
          color: color,
        ),
        textAlign: textAlign,
        lineLimit: lineLimit);
  }
}

class TextProperties {
  TextStyle textStyle;
  TextAlign textAlign;
  int? lineLimit;

  TextProperties(
      {required this.textStyle,
      required this.textAlign,
      required this.lineLimit});
}
