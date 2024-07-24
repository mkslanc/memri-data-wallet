import 'package:flutter/material.dart';
import 'package:memri/cvu/constants/cvu_font.dart';

final lightTheme = ThemeData(
  fontFamily: 'Karla',
  textTheme: const TextTheme(
    displayLarge: CVUFont.headline1,
    displayMedium: CVUFont.headline2,
    displaySmall: CVUFont.headline3,
    headlineMedium: CVUFont.headline4,
    bodyLarge: CVUFont.bodyText1,
    bodyMedium: CVUFont.bodyText2,
  ),
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
          foregroundColor: Color(0xff515151), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
          visualDensity: VisualDensity(horizontal: 0, vertical: 0),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.all(10.0))),
  // ignore: deprecated_member_use
  // scrollbarTheme: ScrollbarThemeData(thumbVisibility: AlwaysStoppedAnimation(true)),
  pageTransitionsTheme: PageTransitionsTheme(builders: {
    TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
  }), /*colorScheme: ColorScheme(surface: Color(0xffE5E5E5)),*/
);
