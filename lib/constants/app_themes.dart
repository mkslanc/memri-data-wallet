import 'package:flutter/material.dart';
import 'package:memri/constants/cvu/cvu_font.dart';

final lightTheme = ThemeData(
  fontFamily: 'Karla',
  backgroundColor: Color(0xffE5E5E5),
  textTheme: const TextTheme(
    headline1: CVUFont.headline1,
    headline2: CVUFont.headline2,
    headline3: CVUFont.headline3,
    headline4: CVUFont.headline4,
    bodyText1: CVUFont.bodyText1,
    bodyText2: CVUFont.bodyText2,
  ),
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
          visualDensity: VisualDensity(horizontal: 0, vertical: 0),
          primary: Color(0xff515151),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.all(10.0))),
  scrollbarTheme: const ScrollbarThemeData(isAlwaysShown: true),
  pageTransitionsTheme: PageTransitionsTheme(builders: {
    TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
  }),
);
