//
//  ViewContext.swift
//  memri
//
//  Created by T Brennan on 7/12/20.
//  Copyright © 2020 memri. All rights reserved.
//

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUViewArguments.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseQuery.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';

import 'package:json_annotation/json_annotation.dart';

part 'ViewContext.g.dart';

/// This type is used to hold all the configuration necessary to display a screen.
/// It is stored as part of the navigation stack, and the whole stack is persisted to the database
@JsonSerializable()
class ViewContext extends ChangeNotifier with EquatableMixin {
  String? _viewName;

  String _rendererName;

  CVUDefinitionContent _viewDefinition;

  DatabaseQueryConfig _query;

  CVUViewArguments? _viewArguments;

  ItemRecord? _focusedItem;

  String? get viewName => _viewName;

  set viewName(String? value) {
    if (_viewName == value) return;
    _viewName = value;
    notifyListeners();
  }

  String get rendererName => _rendererName;

  set rendererName(String value) {
    if (_rendererName == value) return;
    _rendererName = value;
    notifyListeners();
  }

  CVUDefinitionContent get viewDefinition => _viewDefinition;

  set viewDefinition(CVUDefinitionContent value) {
    if (_viewDefinition == value) return;
    _viewDefinition = value;
    notifyListeners();
  }

  DatabaseQueryConfig get query => _query;

  set query(DatabaseQueryConfig value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  CVUViewArguments? get viewArguments => _viewArguments;

  set viewArguments(CVUViewArguments? value) {
    if (_viewArguments == value) return;
    _viewArguments = value;
    notifyListeners();
  }

  ItemRecord? get focusedItem => _focusedItem;

  set focusedItem(ItemRecord? value) {
    if (_focusedItem == value) return;
    _focusedItem = value;
    notifyListeners();
  }

  ViewContext(
      {required String rendererName,
      required DatabaseQueryConfig query,
      String? viewName,
      CVUDefinitionContent? viewDefinition,
      CVUViewArguments? viewArguments,
      ItemRecord? focusedItem})
      : this._rendererName = rendererName,
        this._query = query,
        this._viewName = viewName,
        this._viewDefinition = viewDefinition ?? CVUDefinitionContent(),
        this._viewArguments = viewArguments,
        this._focusedItem = focusedItem;

  factory ViewContext.fromJson(Map<String, dynamic> json) => _$ViewContextFromJson(json);
  Map<String, dynamic> toJson() => _$ViewContextToJson(this);

  @override
  List<Object?> get props =>
      [_viewName, _rendererName, _viewDefinition, _query, _viewArguments, _focusedItem];
}

/// A class type that holds a ViewContext struct. This allows the struct to be shared between objects while maintaining value semantics.
@JsonSerializable()
class ViewContextHolder extends ChangeNotifier with EquatableMixin {
  ViewContext config; //TODO configPublisher.send() on set

  ViewContextHolder(this.config) {
    config.addListener(notifyListeners);
  }

  factory ViewContextHolder.fromJson(Map<String, dynamic> json) =>
      _$ViewContextHolderFromJson(json);
  Map<String, dynamic> toJson() => _$ViewContextHolderToJson(this);

  @override
  List<Object?> get props => [config];
}
