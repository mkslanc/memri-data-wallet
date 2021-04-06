//
// CVUFont.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/material.dart';

/// Represents a font in the CVU language
class CVUFont {
  String? name;
  double? size;
  FontWeight? weight;
  bool italic;

  CVUFont({this.name, this.size, this.weight, this.italic = false});

  Map<String, dynamic> get font {
    return {"family": name, "size": size, "weight": weight ?? FontWeight.normal, "italic": italic};
  }

  /*get uiFont(): UIFont {
      let font = UIFont.systemFont(
          ofSize: size ?? UIFont.systemFontSize,
          weight: weight?.uiKit ?? .regular
      )
      let fontWithTraits = font.withTraits(traits: italic ? .traitItalic : [])
      return fontWithTraits
  }*/
  static const Map<String, FontWeight> Weight = {
    "black": FontWeight.bold,
    "bold": FontWeight.bold,
    // heavy: "heavy",
    // light: "light",
    // medium: "medium",//TODO
    "regular": FontWeight.normal,
    // semibold: "semibold",
    // thin: "thin",
    // ultraLight: "ultraLight",
  };
}

//TODO extension FontWeight
