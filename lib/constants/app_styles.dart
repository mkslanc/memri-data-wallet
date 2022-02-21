import 'package:flutter/material.dart';
import 'package:memri/constants/cvu/cvu_font.dart';

final ButtonStyle primaryButtonStyle = TextButton.styleFrom(
  backgroundColor: Color(0xff333333),
  primary: Color(0xffF5F5F5),
  textStyle: CVUFont.buttonLabel,
  minimumSize: Size.zero,
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  padding: const EdgeInsets.all(10),
);

final Map<String, ButtonStyle> buttonStyles = {"primaryButton": primaryButtonStyle};
