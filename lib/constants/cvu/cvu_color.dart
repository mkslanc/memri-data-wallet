import 'package:flutter/painting.dart';
import 'package:memri/utilities/helpers/app_helper.dart';

class CVUColor {
  late Color value;

  CVUColor({required String color}) {
    if (color[0] == "#" || int.tryParse(color, radix: 16) != null) {
      value = CVUColor.hex(color);
    } else {
      value = CVUColor.system(color);
    }
  }

  static Color system(value) {
    switch (value) {
      case "secondary":
      case "secondaryLabel":
        return app.colors.greyDarkest;
      case "primary":
      case "label":
      case "black":
        return app.colors.black;
      case "tertiary":
      case "tertiaryLabel":
        return app.colors.tertiary;
      case "secondaryBackground":
      case "tertiarySystemBackground":
      case "secondarySystemGroupedBackground":
      case "background":
      case "systemBackground":
        return app.colors.white.withOpacity(0);
      case "tertiaryBackground":
      case "white":
        return app.colors.white;
      case "systemFill":
        return app.colors.greyDark;
      case "secondarySystemBackground":
        return app.colors.greyLight;
      case "gray":
        return app.colors.grey;
      case "purple":
        return app.colors.purple;
      case "MemriUI-purpleBack":
        return app.colors.purpleBackground;
      case "MemriUI-purpleBackSecondary":
        return app.colors.brandPurple;
      case "memriBlue":
        return app.colors.brandBlue;
      case "blue":
      case "systemBlue":
        return app.colors.blue;
      case "red":
      case "systemRed":
        return app.colors.red;
      case "orange":
      case "systemOrange":
        return app.colors.orange;
      case "yellow":
      case "systemYellow":
        return app.colors.yellow;
      case "green":
      case "systemGreen":
        return app.colors.green;
      case "greenBackground":
        return app.colors.greenBackground;
      case "purpleBackground":
        return app.colors.purpleBackground;
      default:
        return app.colors.black;
    }
  }

  static Color hex(String value) {
    final buffer = StringBuffer();
    if (value.length == 3) {
      var newValue = "";
      for (var i = 0; i < value.length; i++) {
        newValue += value[i] * 2;
      }
      value = newValue;
    }
    if (value.length == 6 || value.length == 7) buffer.write('ff');
    buffer.write(value.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static Map<String, Color> predefined = {
    "memriBlue": app.colors.brandBlue,
    "blueTxt": app.colors.brandBlueText,
    "memriBlack": app.colors.brandBlack,
    "brandTextGrey": app.colors.brandGreyText,
    "memriWhite": app.colors.brandWhite,
    "greyInactive": app.colors.greyInactive,
    "textLight": app.colors.textLight,
    "brandBlack": app.colors.brandBlack,
    "brandOrange": app.colors.brandOrange,
  };
}
