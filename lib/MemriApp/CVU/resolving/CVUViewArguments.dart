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
  Map<String, CVUValue> _args = {};

  set args(Map<String, CVUValue> newArgs) => _args = Map.of(newArgs);
  Map<String, CVUValue> get args => _args;

  // The item that is `.` when resolving these view arguments
  ItemRecord? argumentItem;

  List<ItemRecord>? argumentItems;

  // The view arguments of the parent view (used to resolve)
  @JsonKey(ignore: true)
  CVUViewArguments? parentArguments;

  // The view arguments of the sub views (used to resolve)
  Map<String, CVUViewArguments> subViewArguments = {};

  //used to deserialize from json for parentArguments //TODO maybe there's better way
  List<CVUViewArguments> childrenArguments = [];

  CVUViewArguments(
      {Map<String, CVUValue>? args, this.argumentItem, this.parentArguments, this.argumentItems}) {
    this.args = args ?? {};
    this.parentArguments?.childrenArguments.add(this);
  }

  factory CVUViewArguments.fromJson(Map<String, dynamic> json) {
    var viewArguments = _$CVUViewArgumentsFromJson(json);
    viewArguments.childrenArguments.forEach((subArgument) {
      subArgument.parentArguments = viewArguments;
    });
    return viewArguments;
  }
  Map<String, dynamic> toJson() => _$CVUViewArgumentsToJson(this);

  @override
  List<Object?> get props => [args, argumentItem, parentArguments, subViewArguments];
}
