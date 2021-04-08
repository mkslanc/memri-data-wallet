import 'package:flutter/painting.dart';

class CVUColor {
  late Color value;

  CVUColor({required String color}) {
    if (color[0] == "#") {
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
      case "tertiaryBackground":
      case "tertiarySystemBackground":
      case "secondarySystemGroupedBackground":
      case "background":
      case "systemBackground":
        return Color(0x00ffffff);
      case "white":
        return Color(0xffffffff);
      case "systemFill":
        return Color(0x5b787880);
      case "secondaryBackground":
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
    if (value.length == 6 || value.length == 7) buffer.write('ff');
    buffer.write(value.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
