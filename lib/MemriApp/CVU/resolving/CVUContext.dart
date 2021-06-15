//
//  CVUContext.swift
//  MemriDatabase
//
//  Created by T Brennan on 7/12/20.
//

import 'dart:math';

import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';

import 'CVUViewArguments.dart';

class CVUContext {
  ItemRecord? currentItem;
  List<ItemRecord>? items;

  String? selector;
  String? viewName;
  String? rendererName;
  CVUDefinitionContent viewDefinition;
  CVUViewArguments? viewArguments;

  int get currentIndex {
    if (currentItem == null) {
      return 0;
    }
    return max(items?.indexOf(currentItem!) ?? 0, 0);
  }

  CVUContext(
      {this.currentItem,
      this.items,
      this.selector,
      this.viewName,
      this.rendererName,
      viewDefinition,
      this.viewArguments})
      : this.viewDefinition = viewDefinition ?? CVUDefinitionContent();

  CVUContext replacingItem(ItemRecord item) {
    return CVUContext(
        currentItem: item,
        items: items,
        selector: selector,
        viewName: viewName,
        rendererName: rendererName,
        viewDefinition: viewDefinition,
        viewArguments: viewArguments);
  }
}
