//
//  CVUViewArguments.swift
//  Memri
//
//  Created by T Brennan on 28/1/21.
//

import 'package:equatable/equatable.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';

class CVUViewArguments with EquatableMixin {
  // The view arguments
  Map<String, CVUValue> args;

  // The item that is `.` when resolving these view arguments
  ItemRecord? argumentItem;

  // The view arguments of the parent view (used to resolve)
  CVUViewArguments? parentArguments;

  CVUViewArguments({Map<String, CVUValue>? args, this.argumentItem, this.parentArguments})
      : this.args = args ?? {};

  @override
  List<Object?> get props => [args, argumentItem, parentArguments];
}
