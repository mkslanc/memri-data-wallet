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
}

//TODO extension FontWeight
