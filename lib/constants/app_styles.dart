import 'package:flutter/material.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/cvu/constants/cvu_font.dart';

final ButtonStyle primaryButtonStyle = TextButton.styleFrom(
    foregroundColor: app.colors.brandWhite, backgroundColor: app.colors.brandOrange, disabledForegroundColor: Colors.white.withOpacity(0.38),
    textStyle: CVUFont.buttonLabel,
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    padding: const EdgeInsets.all(10));

final ButtonStyle secondaryButtonStyle = TextButton.styleFrom(
    foregroundColor: app.colors.brandOrange, textStyle: CVUFont.buttonLabel, disabledForegroundColor: Colors.white.withOpacity(0.38),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    padding: const EdgeInsets.all(10));

final ButtonStyle tertiaryButtonStyle = TextButton.styleFrom(
    foregroundColor: app.colors.brandWhite, backgroundColor: app.colors.brandBlack, disabledForegroundColor: Colors.white.withOpacity(0.38),
    textStyle: CVUFont.buttonLabel,
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    padding: const EdgeInsets.all(10));

final Map<String, ButtonStyle> buttonStyles = {
  "primaryButton": primaryButtonStyle,
  "secondaryButton": secondaryButtonStyle,
  "tertiaryButton": tertiaryButtonStyle
};
