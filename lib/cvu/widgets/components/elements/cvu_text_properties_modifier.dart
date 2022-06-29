import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

import '../../../services/resolving/cvu_property_resolver.dart';

/// Modifier used to apply text CVU properties (such as font, color, textAlignment, lineLimit)
class CVUTextPropertiesModifier {
  CVUPropertyResolver propertyResolver;

  CVUTextPropertiesModifier({required this.propertyResolver});

  Future<TextProperties> init() async {
    var font = await propertyResolver.font();
    var color = await propertyResolver.color();
    var textAlign = await propertyResolver.textAlignment();
    var lineLimit = await propertyResolver.lineLimit;
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
