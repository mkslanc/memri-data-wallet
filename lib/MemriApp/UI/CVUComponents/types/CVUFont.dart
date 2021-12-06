//
// CVUFont.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/material.dart';

/// Represents a font in the CVU language
class CVUFont {
  String? name;
  double size;
  FontWeight? weight;
  bool italic;
  double? letterSpacing;

  CVUFont(
      {this.name,
      this.size = 15,
      this.weight = FontWeight.normal,
      this.italic = false,
      this.letterSpacing});

  Map<String, dynamic> get font {
    return {"family": name, "size": size, "weight": weight ?? FontWeight.normal, "italic": italic};
  }

  static const Map<String, FontWeight> Weight = {
    "black": FontWeight.w900,
    "bold": FontWeight.w700,
    "heavy": FontWeight.w800,
    "light": FontWeight.w300,
    "medium": FontWeight.w500,
    "regular": FontWeight.normal,
    "semibold": FontWeight.w600,
    "thin": FontWeight.w200,
    "ultraLight": FontWeight.w100,
  };

  static Map<String, CVUFont> predefined = {
    "headline1": CVUFont(
        size: headline1.fontSize!,
        weight: headline1.fontWeight,
        letterSpacing: headline1.letterSpacing),
    "headline2": CVUFont(
        size: headline2.fontSize!,
        weight: headline2.fontWeight,
        letterSpacing: headline2.letterSpacing),
    "headline3": CVUFont(
        size: headline3.fontSize!,
        weight: headline3.fontWeight,
        letterSpacing: headline3.letterSpacing),
    "headline4": CVUFont(
        size: headline4.fontSize!,
        weight: headline4.fontWeight,
        letterSpacing: headline4.letterSpacing),
    "bodyText1": CVUFont(
        size: bodyText1.fontSize!,
        weight: bodyText1.fontWeight,
        letterSpacing: bodyText1.letterSpacing),
    "bodyText2": CVUFont(
        size: bodyText2.fontSize!,
        weight: bodyText2.fontWeight,
        letterSpacing: bodyText2.letterSpacing),
    "button_label": CVUFont(
        size: buttonLabel.fontSize!,
        weight: buttonLabel.fontWeight,
        letterSpacing: buttonLabel.letterSpacing),
    "tile_Label": CVUFont(
        size: tileLabel.fontSize!,
        weight: tileLabel.fontWeight,
        letterSpacing: tileLabel.letterSpacing),
    "link":
        CVUFont(size: link.fontSize!, weight: link.fontWeight, letterSpacing: link.letterSpacing),
    "small_caps": CVUFont(
        size: smallCaps.fontSize!,
        weight: smallCaps.fontWeight,
        letterSpacing: smallCaps.letterSpacing),
    "tab_list": CVUFont(
      size: tabList.fontSize!,
      weight: tabList.fontWeight,
    ),
    "body_tiny": CVUFont(
      size: bodyTiny.fontSize!,
      weight: bodyTiny.fontWeight,
    ),
  };

  static const headline1 = TextStyle(
      fontFamily: 'Karla',
      fontSize: 30,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.01,
      color: Color(0xff333333));
  static const headline2 = TextStyle(
      fontFamily: 'Karla',
      fontSize: 20,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.01,
      color: Color(0xff333333));
  static const headline3 = TextStyle(
      fontFamily: 'Karla', fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xff333333));
  static const headline4 = TextStyle(
      fontFamily: 'Karla',
      fontSize: 16,
      fontWeight: FontWeight.w300,
      letterSpacing: 0.16,
      color: Color(0xff333333));
  static const bodyText1 = TextStyle(
      fontFamily: 'Karla', fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff333333));
  static const bodyBold = TextStyle(
      fontFamily: 'Karla', fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xff333333));
  static const bodyText2 = TextStyle(
      fontFamily: 'Karla', fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xff333333));
  static const buttonLabel = TextStyle(
      fontFamily: 'Karla', fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff333333));
  static const tileLabel = TextStyle(
      fontFamily: 'Karla',
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.04,
      color: Color(0xff333333));
  static const link = TextStyle(
      fontFamily: 'Karla', fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff333333));
  static const smallCaps = TextStyle(
      fontFamily: 'Karla',
      fontSize: 10,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.11,
      color: Color(0xff333333));
  static const tabList = TextStyle(
      fontFamily: 'Karla', fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff333333));
  static const bodyTiny = TextStyle(
      fontFamily: 'Karla', fontSize: 10, fontWeight: FontWeight.w400, color: Color(0xff333333));
}
