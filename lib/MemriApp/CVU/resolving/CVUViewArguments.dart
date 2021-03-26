//
//  CVUViewArguments.swift
//  Memri
//
//  Created by T Brennan on 28/1/21.
//

import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';

class CVUViewArguments {
  // The view arguments
  Map<String, CVUValue> args;

  // The item that is `.` when resolving these view arguments
  ItemRecord? argumentItem;

  // The view arguments of the parent view (used to resolve)
  CVUViewArguments? parentArguments;

  CVUViewArguments({
    args,
    this.argumentItem,
    this.parentArguments
  }) : this.args = args ?? {};
}