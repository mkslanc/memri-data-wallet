//
//  CVUContext.swift
//  MemriDatabase
//
//  Created by T Brennan on 7/12/20.
//

import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';

import 'CVUViewArguments.dart';

class CVUContext {
  ItemRecord? currentItem;

  String? selector;
  String? viewName;
  String? rendererName;
  CVUDefinitionContent viewDefinition;
  CVUViewArguments? viewArguments;

  CVUContext(
      {this.currentItem,
      this.selector,
      this.viewName,
      this.rendererName,
      viewDefinition,
      this.viewArguments})
      : this.viewDefinition = viewDefinition ?? CVUDefinitionContent();

  CVUContext replacingItem(ItemRecord item) {
    return CVUContext(
        currentItem: item,
        selector: selector,
        viewName: viewName,
        rendererName: rendererName,
        viewDefinition: viewDefinition,
        viewArguments: viewArguments);
  }
}
