//
//  ViewContext.swift
//  memri
//
//  Created by T Brennan on 7/12/20.
//  Copyright © 2020 memri. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUViewArguments.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseQuery.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';

/// This type is used to hold all the configuration necessary to display a screen.
/// It is stored as part of the navigation stack, and the whole stack is persisted to the database
class ViewContext {
  String? viewName;

  ValueNotifier<String> rendererName;

  CVUDefinitionContent viewDefinition;

  DatabaseQueryConfig query;

  CVUViewArguments? viewArguments;

  ItemRecord? focusedItem;

  ViewContext(
      {required rendererName,
      required this.query,
      this.viewName,
      viewDefinition,
      this.viewArguments,
      this.focusedItem})
      : this.rendererName = ValueNotifier(rendererName),
        this.viewDefinition = viewDefinition ?? CVUDefinitionContent();
}

/// A class type that holds a ViewContext struct. This allows the struct to be shared between objects while maintaining value semantics.
class ViewContextHolder {
  ViewContext config; //TODO configPublisher.send() on set

  ViewContextHolder(this.config);
}
