import 'package:flutter/material.dart';

class AppColors {
  static final AppColors _colors = AppColors._internal();

  factory AppColors() => _colors;

  AppColors._internal();

  final Color white = Colors.white;
  final Color black = Colors.black;
  final Color greyLight = const Color(0xfff2f2f7);
  final Color grey = const Color(0xff636161);
  final Color greyDark = const Color(0x5b787880);
  final Color greyDarkest = const Color(0x993c3c43);
  final Color blue = const Color(0xff007aff);
  final Color purple = const Color(0xff800080);
  final Color red = const Color(0xffff3b30);
  final Color orange = const Color(0xffff9500);
  final Color yellow = const Color(0xffffcc00);
  final Color green = const Color(0xff34c759);

  final Color primary = const Color(0xffFE570F);
  final Color accent = const Color(0xff007aff);

  final Color tertiary = const Color(0x4c3c3c43);

  final Color greenBackground = const Color(0xffdbf7c5);
  final Color purpleBackground = const Color(0xffefe4fd);

  final Color greyInactive = const Color(0xffd0d0d0);
  final Color textLight = const Color(0xffc0c0c0);

  final Color brandPurple = const Color(0xff532a84);
  final Color brandPurpleText = const Color(0xff543184);
  final Color brandBlue = const Color(0xff4abff1);
  final Color brandBlueText = const Color(0xff17a4e0);
  final Color brandGreyText = const Color(0xff999999);
  final Color brandWhite = const Color(0xfff5f5f5);
  final Color brandBlack = const Color(0xff333333);
  final Color brandOrange = const Color(0xffE9500F);
}
