//  Created by T Brennan on 7/12/20.

import 'dart:math';

import 'package:memri/core/models/item.dart';
import 'package:memri/cvu/models/cvu_parsed_definition.dart';
import 'package:memri/cvu/models/cvu_view_arguments.dart';

class CVUContext {
  Item? currentItem;
  List<Item>? items;

  String? selector;
  String? viewName;
  String? rendererName;
  CVUDefinitionContent viewDefinition;
  CVUViewArguments? viewArguments;

  Map<String, dynamic> cache =
      {}; //TODO: review and improve, extreme mvp optimisation
  dynamic getCache(String key) => cache[key];
  bool hasCache(String key) => cache.containsKey(key);
  setCache(String key, dynamic value) => cache[key] = value;
  clearCache() => cache = {};

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

  CVUContext clone() {
    return CVUContext(
        currentItem: currentItem,
        items: items,
        selector: selector,
        viewName: viewName,
        rendererName: rendererName,
        viewDefinition: viewDefinition,
        viewArguments: viewArguments);
  }

  CVUContext replacingItem(Item item) {
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
