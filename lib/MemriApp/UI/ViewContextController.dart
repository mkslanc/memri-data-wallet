//
//  ViewContextControllerController.swift
//  Memri
//
//  Created by T Brennan on 30/1/21.
//

import 'package:flutter/cupertino.dart';
import 'package:memri/MemriApp/CVU/CVUController.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/CVU/resolving/CVULookupController.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUPropertyResolver.dart';
import 'package:memri/MemriApp/Controllers/AppController.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseController.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';

import 'ViewContext.dart';

class ViewContextController {
  late ViewContextHolder configHolder;

  late DatabaseController databaseController;
  late CVUController cvuController;
  late CVULookupController lookupController;

  var configObservation;
  var queryObservation;

  CVUDefinitionContent rendererDefinition;

  ViewContext get config => configHolder.config;

  set config(ViewContext newValue) {
    if (configHolder.config != newValue) {
      configHolder.config = newValue;
      _updateCachedValues();
    }
  }

  ViewContextController(
      {required ViewContextHolder config,
      DatabaseController? databaseController,
      CVUController? cvuController,
      rendererDefinition})
      : this.rendererDefinition = rendererDefinition ?? CVUDefinitionContent() {
    this.databaseController = databaseController ?? AppController.shared.databaseController;
    this.cvuController = cvuController ?? AppController.shared.cvuController;
    this.lookupController = CVULookupController();
    this.configHolder = config;

    _updateCachedValues();

    setupQueryObservation();

    // Watch for changes to the config
    // configObservation = configHolder.configPublisher.sink { [weak self] _ in
    // self?.setupQueryObservation()
    // }
  }

  int get focusedIndex {
    var focusedItem = config.focusedItem;
    if (focusedItem == null) {
      return 0;
    }
    return items.indexOf(focusedItem) ?? 0;
  }

  set focusedIndex(int newValue) {
    var item = items[newValue];
    if (item != null) {
      config.focusedItem = item;
    } else {
      config.focusedItem = null;
    }
  }

  ItemRecord? get focusedItem => config.focusedItem;

  set focusedItem(ItemRecord? newValue) {
    config.focusedItem = newValue;
  }

  onAppear() {
    isObservingQuery = true;
  }

  onDisappear() {
    isObservingQuery = false;
  }

  /// Return a SwiftUI view for the given item based on it's CVU definition.
  /// Set `overrideRenderer` if you want to render the item as though it is in a different renderer to the context (eg. "list" to get the list-specific appearance)
  Widget? render(ItemRecord item, [String? overrideRenderer, bool blankIfNoDefinition = false]) {
    cvuController.render(
        cvuContext: getCVUContext(item, overrideRenderer),
        lookup: lookupController,
        db: databaseController,
        blankIfNoDefinition: blankIfNoDefinition);
  }

  CVUContext getCVUContext([ItemRecord? item, String? overrideRenderer]) {
    return CVUContext(
        currentItem: item,
        selector: null,
        viewName: config.viewName,
        rendererName: overrideRenderer ?? config.rendererName,
        viewDefinition: config.viewDefinition,
        viewArguments: config.viewArguments);
  }

  _updateCachedValues() {
    rendererDefinition =
        cvuController.rendererDefinitionFor(getCVUContext())?.parsed ?? CVUDefinitionContent();

    viewDefinitionPropertyResolver = config.viewDefinition.propertyResolver(
        context: getCVUContext(), lookup: CVULookupController(), db: databaseController);

    rendererDefinitionPropertyResolver = rendererDefinition.propertyResolver(
        context: getCVUContext(), lookup: CVULookupController(), db: databaseController);
  }

  Future<Set<String>> get supportedRenderers async {
    var defined = (await viewDefinitionPropertyResolver.stringArray("supportedRenderers"))
        .map((property) => property.toLowerCase());
    if (defined.isNotEmpty) {
      return Set.of(defined);
    } else {
      var defaultRenderer =
          (await viewDefinitionPropertyResolver.string("defaultRenderer"))?.toLowerCase();
      List<String> list = config.viewDefinition.definitions
          .map((def) {
            if (def.type == CVUDefinitionType.renderer) {
              return null;
            }
            return def.name?.toLowerCase();
          })
          .whereType<String>()
          .toList();
      if (defaultRenderer != null) {
        list.add(defaultRenderer);
      }
      return Set.of(list);
    }
  }

  late CVUPropertyResolver viewDefinitionPropertyResolver

      /* = (){TODO check if these functions are needed
    return config.viewDefinition.propertyResolver(context: getCVUContext(), lookup: CVULookupController(), db: databaseController);
  }()*/
      ;

  late CVUPropertyResolver rendererDefinitionPropertyResolver

      /* = (){
    return rendererDefinition.propertyResolver(context: getCVUContext(), lookup: CVULookupController(), db: databaseController);
  }()*/
      ;

  setRendererProperty(String renderer, String property, CVUValue value) {
    var index = config.viewDefinition.definitions.indexWhere((definition) =>
        definition.type == CVUDefinitionType.renderer && definition.name == renderer);
    if (index >= 0) {
      config.viewDefinition.definitions[index].parsed.properties[property] = value;
    } else {
      var props = CVUDefinitionContent(properties: {property: value});
      var def =
          CVUParsedDefinition(type: CVUDefinitionType.renderer, name: renderer, parsed: props);
      config.viewDefinition.definitions.add(def);
    }
    _updateCachedValues();
  }

  CVUPropertyResolver? nodePropertyResolver(ItemRecord item) {
    var context = getCVUContext(item);
    return cvuController
        .nodeDefinitionFor(context)
        ?.propertyResolver(context: context, lookup: CVULookupController(), db: databaseController);
  }

  // MARK: Query RESULT
  /// This holds the array of results for the query. If `isObserving` is set to true, this will be up to date with any changes in the database.
  // @Published
  List<ItemRecord> _items = [];

  List<ItemRecord> get items => _items;

  set items(List<ItemRecord> items) {
    this._items = items;
  }

  // AnyPublisher<[ItemRecord], Never> _itemsChangePublisher;

  /// Convenience variable returning whether there are any items
  bool get hasItems => !items.isEmpty;

  // MARK: Selection State
  List<String> selectedItems = <String>[];

  Binding<Set<int>> get selectedIndicesBinding {
    return Binding(
        () => Set.of(selectedItems
            .map((uid) => items.indexWhere((item) => item.uid == uid))
            .whereType<int>()
            .toList()), (newValue) {
      selectedItems =
          Set.of(newValue.map<String?>((index) => items[index]?.uid).whereType<String>().toList())
              .toList();
    });
  }

  // MARK: Search State
  String? get searchString => config.query.searchString;

  set searchString(String? newValue) {
    config.query.searchString = newValue;
  }

  // MARK: OTHER
  bool isFullScreen = false;

  // MARK: Configuration
  /// Determines if the query is actively observing for changes. If set to false, it won't respond to changes.
  /// Use this to avoid unneccessary observation if a query isn't being shown in the UI currently
  bool _isObservingQuery = true;

  bool get isObservingQuery => _isObservingQuery;

  set isObservingQuery(bool isObservingQuery) {
    if (this._isObservingQuery == isObservingQuery) {
      return;
    }
    this._isObservingQuery = isObservingQuery;
    this.setupQueryObservation();
  }

  /// Sets up a database observation so that all
  setupQueryObservation() {
    /// Remove old observation
    queryObservation?.cancel();
    queryObservation = null;

    /// Only set up an observation if `isObserving` is true
    if (!isObservingQuery) {
      return;
    }

    var queryConfig = config.query;
    // var observation = ValueObservation
    //     .tracking { db in
    // try queryConfig.executeRequest(db: db)
    // }

    /// Subscribe to changes in the value, with the first result being reported immediately
    /*queryObservation = observation.publisher(
    in: databaseController.databasePool,
    scheduling: .immediate)
        .sink(
    receiveCompletion: { completion in },
    receiveValue: { result in
    self.items = result
    })*/
  }
}
