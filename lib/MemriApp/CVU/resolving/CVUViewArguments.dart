//
//  CVUViewArguments.swift
//  Memri
//
//  Created by T Brennan on 28/1/21.
//

import 'package:equatable/equatable.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';

import 'package:json_annotation/json_annotation.dart';

part 'CVUViewArguments.g.dart';

@JsonSerializable()
class CVUViewArguments with EquatableMixin {
  // The view arguments
  Map<String, CVUValue> args;

  // The item that is `.` when resolving these view arguments
  ItemRecord? argumentItem;

  // The item that is `.` when resolving these view arguments
  List<ItemRecord>? argumentItems;

  // The view arguments of the parent view (used to resolve)
  CVUViewArguments? parentArguments;

  // The view arguments of the sub views (used to resolve)
  Map<String, CVUViewArguments> subViewArguments = {};

  CVUViewArguments(
      {Map<String, CVUValue>? args, this.argumentItem, this.parentArguments, this.argumentItems})
      : this.args = args ?? {};

  factory CVUViewArguments.fromJson(Map<String, dynamic> json) => _$CVUViewArgumentsFromJson(json);
  Map<String, dynamic> toJson() => _$CVUViewArgumentsToJson(this);

  @override
  List<Object?> get props => [args, argumentItem, parentArguments];
}
