import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

import '../CVUUINodeResolver.dart';

/// Modifier used to apply text CVU properties (such as font, color, textAlignment, lineLimit)
class CVUTextPropertiesModifier {
  CVUUINodeResolver nodeResolver;

  CVUTextPropertiesModifier({required this.nodeResolver});

  Future<TextProperties> init() async {
    var font = await nodeResolver.propertyResolver.font();
    var color = await nodeResolver.propertyResolver.color();
    var textAlign = await nodeResolver.propertyResolver.textAlignment();
    var lineLimit = await nodeResolver.propertyResolver.lineLimit;
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

  TextProperties({required this.textStyle, required this.textAlign, required this.lineLimit});
}
