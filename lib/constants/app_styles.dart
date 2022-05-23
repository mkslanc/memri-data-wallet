import 'package:flutter/material.dart';
import 'package:memri/constants/cvu/cvu_color.dart';
import 'package:memri/constants/cvu/cvu_font.dart';

final ButtonStyle primaryButtonStyle = TextButton.styleFrom(
    backgroundColor: CVUColor.brandOrange,
    primary: CVUColor.brandWhite,
    textStyle: CVUFont.buttonLabel,
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    padding: const EdgeInsets.all(10),
    onSurface: Colors.white);

final ButtonStyle secondaryButtonStyle = TextButton.styleFrom(
    primary: CVUColor.brandOrange,
    textStyle: CVUFont.buttonLabel,
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    padding: const EdgeInsets.all(10),
    onSurface: Colors.white);

final Map<String, ButtonStyle> buttonStyles = {
  "primaryButton": primaryButtonStyle,
  "secondaryButton": secondaryButtonStyle
};
