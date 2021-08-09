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

  CVUFont({this.name, this.size = 15, this.weight = FontWeight.normal, this.italic = false});

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
    "headline1": CVUFont(size: headline1.fontSize!, weight: headline1.fontWeight),
    "headline2": CVUFont(size: headline2.fontSize!, weight: headline2.fontWeight),
    "headline3": CVUFont(size: headline3.fontSize!, weight: headline3.fontWeight),
    "headline4": CVUFont(size: headline4.fontSize!, weight: headline4.fontWeight),
    "bodyText1": CVUFont(size: bodyText1.fontSize!, weight: bodyText1.fontWeight),
    "bodyText2": CVUFont(size: bodyText2.fontSize!, weight: bodyText2.fontWeight),
  };

  static const headline1 = TextStyle(fontSize: 44, fontWeight: FontWeight.w300);
  static const headline2 = TextStyle(fontSize: 30, fontWeight: FontWeight.w400);
  static const headline3 = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  static const headline4 = TextStyle(fontSize: 16, fontWeight: FontWeight.w300);
  static const bodyText1 = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  static const bodyText2 = TextStyle(fontSize: 13, fontWeight: FontWeight.w400);
}
