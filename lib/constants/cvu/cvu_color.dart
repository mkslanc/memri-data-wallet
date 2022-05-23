import 'package:flutter/painting.dart';

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
        return Color(0x993c3c43);
      case "primary":
      case "label":
      case "black":
        return Color(0xFF000000);
      case "tertiary":
      case "tertiaryLabel":
        return Color(0x4c3c3c43);
      case "secondaryBackground":
      case "tertiarySystemBackground":
      case "secondarySystemGroupedBackground":
      case "background":
      case "systemBackground":
        return Color(0x00ffffff);
      case "tertiaryBackground":
      case "white":
        return Color(0xffffffff);
      case "systemFill":
        return Color(0x5b787880);
      case "secondarySystemBackground":
        return Color(0xfff2f2f7);
      case "gray":
        return Color(0xff636161);
      case "purple":
        return Color(0xff800080);
      case "MemriUI-purpleBack":
        return Color(0xff543184);
      case "MemriUI-purpleBackSecondary":
        return Color(0xff532a84);
      case "memriBlue":
        return blue;
      case "blue":
      case "systemBlue":
        return Color(0xff007aff);
      case "red":
      case "systemRed":
        return Color(0xffff3b30);
      case "orange":
      case "systemOrange":
        return Color(0xffff9500);
      case "yellow":
      case "systemYellow":
        return Color(0xffffcc00);
      case "green":
      case "systemGreen":
        return Color(0xff34c759);
      case "greenBackground":
        return Color(0xffdbf7c5);
      case "purpleBackground":
        return Color(0xffefe4fd);
      default:
        return Color.fromRGBO(255, 255, 255, 0.0);
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
    "memriBlue": blue,
    "blueTxt": blueTxt,
    "memriBlack": brandBlack,
    "brandTextGrey": brandTextGrey,
    "memriWhite": brandWhite,
    "greyInactive": greyInactive,
    "textLight": textLight,
    "brandBlack": brandBlack,
    "brandOrange": brandOrange,
  };

  static const blue = const Color(0xff4abff1);
  static const blueTxt = const Color(0xff17a4e0);
  static const brandBlack = const Color(0xff333333);
  static const brandTextGrey = const Color(0xff999999);
  static const brandWhite = const Color(0xfff5f5f5);
  static const fff = const Color(0xffffffff);
  static const greyInactive = const Color(0xffd0d0d0);
  static const textLight = const Color(0xffc0c0c0);
  static const brandOrange = const Color(0xffE9500F);
}
