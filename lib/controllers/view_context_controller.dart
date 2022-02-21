//  Created by T Brennan on 30/1/21.

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/controllers/cvu_controller.dart';
import 'package:memri/controllers/cvu_lookup_controller.dart';
import 'package:memri/controllers/database_controller.dart';
import 'package:memri/controllers/page_controller.dart' as memri;
import 'package:memri/core/cvu/resolving/cvu_context.dart';
import 'package:memri/core/cvu/resolving/cvu_property_resolver.dart';
import 'package:memri/models/cvu/cvu_parsed_definition.dart';
import 'package:memri/models/cvu/cvu_value.dart';
import 'package:memri/models/cvu/cvu_view_arguments.dart';
import 'package:memri/models/database/item_record.dart';
import 'package:memri/models/view_context.dart';
import 'package:memri/utils/binding.dart';
import 'package:memri/utils/extensions/collection.dart';

class ViewContextController extends ChangeNotifier {
  late ViewContextHolder configHolder;

  late DatabaseController databaseController;
  late CVUController cvuController;
  late CVULookupController lookupController;
  final memri.PageController pageController;

  var configObservation;
  var queryObservation;

  CVUDefinitionContent rendererDefinition;

  ViewContext get config => configHolder.config;

  ViewContextController(
      {required ViewContextHolder config,
      DatabaseController? databaseController,
      CVUController? cvuController,
      required memri.PageController this.pageController,
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

    searchStringNotifier = ValueNotifier(configHolder.config.query.searchString);
  }

  int get focusedIndex {
    var focusedItem = config.focusedItem;
    if (focusedItem == null) {
      return 0;
    }
    return max(items.indexOf(focusedItem), 0);
  }

  set focusedIndex(int newValue) {
    var item = items.asMap()[newValue];
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

    configHolder.addListener(_updateCachedValues);
  }

  onDisappear() {
    isObservingQuery = false;

    configHolder.removeListener(_updateCachedValues);
  }

  /// Return a Widget for the given item based on it's CVU definition.
  /// Set `overrideRenderer` if you want to render the item as though it is in a different renderer to the context (eg. "list" to get the list-specific appearance)
  Widget render(
      {ItemRecord? item,
      List<ItemRecord>? items,
      String? overrideRenderer,
      CVUDefinitionContent? overrideViewDefinition,
      CVUDefinitionContent? nodeDefinition,
      CVUViewArguments? viewArguments,
      bool blankIfNoDefinition = false}) {
    var key = item != null ? Key(item.uid) : null;
    return cvuController.render(
        cvuContext: getCVUContext(
            item: item,
            items: items,
            overrideViewDefinition: overrideViewDefinition,
            overrideRenderer: overrideRenderer,
            viewArguments: viewArguments),
        nodeDefinition: nodeDefinition,
        lookup: lookupController,
        db: databaseController,
        blankIfNoDefinition: blankIfNoDefinition,
        pageController: pageController,
        key: key);
  }

  CVUContext getCVUContext(
      {ItemRecord? item,
      List<ItemRecord>? items,
      CVUViewArguments? viewArguments,
      CVUDefinitionContent? overrideViewDefinition,
      String? overrideRenderer}) {
    return CVUContext(
        currentItem: item,
        items: items,
        selector: null,
        viewName: config.viewName,
        rendererName: overrideRenderer ?? config.rendererName,
        viewDefinition: overrideViewDefinition ?? config.viewDefinition,
        viewArguments: viewArguments ?? config.viewArguments);
  }

  _updateCachedValues() {
    var viewName = config.viewName;
    var newDef = viewName != null ? cvuController.viewDefinitionFor(viewName: viewName) : null;

    if (newDef == null) {
      var item = config.focusedItem;
      newDef = item != null ? cvuController.viewDefinitionForItemRecord(itemRecord: item) : null;
    }
    if (newDef != null) {
      config.viewDefinition = newDef;
    }

    rendererDefinition =
        cvuController.rendererDefinitionFor(getCVUContext())?.parsed ?? CVUDefinitionContent();

    viewDefinitionPropertyResolver = config.viewDefinition.propertyResolver(
        context: getCVUContext(), lookup: CVULookupController(), db: databaseController);

    rendererDefinitionPropertyResolver = rendererDefinition.propertyResolver(
        context: getCVUContext(), lookup: CVULookupController(), db: databaseController);
    notifyListeners();
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
            if (def.type != CVUDefinitionType.renderer) {
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

  late CVUPropertyResolver viewDefinitionPropertyResolver = () {
    return config.viewDefinition.propertyResolver(
        context: getCVUContext(), lookup: CVULookupController(), db: databaseController);
  }();

  late CVUPropertyResolver rendererDefinitionPropertyResolver = () {
    return rendererDefinition.propertyResolver(
        context: getCVUContext(), lookup: CVULookupController(), db: databaseController);
  }();

  CVUPropertyResolver? get itemPropertyResolver {
    var viewDefinition = cvuController.viewDefinitionForItemRecord(itemRecord: focusedItem);
    if (viewDefinition == null) {
      return null;
    }
    return viewDefinition.propertyResolver(
        context: getCVUContext(item: focusedItem),
        lookup: CVULookupController(),
        db: databaseController);
  }

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
    var context = getCVUContext(item: item);
    return cvuController
        .nodeDefinitionFor(context)
        ?.propertyResolver(context: context, lookup: CVULookupController(), db: databaseController);
  }

  // MARK: Query RESULT
  /// This holds the array of results for the query. If `isObserving` is set to true, this will be up to date with any changes in the database.
  // @Published
  List<ItemRecord>? _items;

  List<ItemRecord> get items => _items ?? [];

  set items(List<ItemRecord> items) {
    /*if (config.focusedItem != null) {//TODO doesn't work correctly with add item action
      if (items.indexOf(config.focusedItem!) < 0) {
        config.focusedItem = null;
      }
    }*/

    _items = items;
    /*if (focusedItem != null) {
      focusedItem = items[focusedIndex];
    }*/
    itemsValueNotifier.value = _items!;
    notifyListeners();
  }

  ValueNotifier<List<ItemRecord>> itemsValueNotifier =
      ValueNotifier([]); //TODO not sure if this is right architecture

  // AnyPublisher<[ItemRecord], Never> _itemsChangePublisher;

  /// Convenience variable returning whether the items are loaded or not
  bool get isLoaded => _items != null;

  /// Convenience variable returning whether there are any items
  bool get hasItems => items.isNotEmpty;

  // MARK: Selection State
  List<int> selectedItems = <int>[];

  Binding<Set<int>> get selectedIndicesBinding {
    return Binding(
        () => Set.of(selectedItems
            .map((rowId) => items.indexWhere((item) => item.rowId == rowId))
            .whereType<int>()
            .toList()), (Set<int> newValue) {
      selectedItems =
          Set.of(newValue.toList().compactMap((index) => items.asMap()[index]?.rowId)).toList();
      config.viewArguments?.args["selectedItems"] =
          CVUValueArray(selectedItems.compactMap((rowId) => CVUValueItem(rowId)));
    });
  }

  // MARK: Search State
  String? get searchString => config.query.searchString;

  set searchString(String? newValue) {
    config.query.searchString = newValue;
    searchStringNotifier.value = newValue;
    setupQueryObservation();
  }

  ValueNotifier<String?> searchStringNotifier = ValueNotifier(null);

  // MARK: OTHER
  bool isFullScreen = false;

  // MARK: Configuration
  /// Determines if the query is actively observing for changes. If set to false, it won't respond to changes.
  /// Use this to avoid unneccessary observation if a query isn't being shown in the UI currently
  bool _isObservingQuery = true;

  bool get isObservingQuery => _isObservingQuery;

  set isObservingQuery(bool isObservingQuery) {
    if (_isObservingQuery == isObservingQuery) {
      return;
    }
    _isObservingQuery = isObservingQuery;
    setupQueryObservation();
  }

  /// Sets up a database observation so that all
  setupQueryObservation() {
    var queryConfig = config.query;

    /// Remove old observation
    queryObservation?.cancel();
    queryConfig.removeListener(setupQueryObservation);

    /// Only set up an observation if `isObserving` is true
    if (!isObservingQuery) {
      return;
    }

    queryConfig.addListener(setupQueryObservation);
    queryObservation =
        queryConfig.executeRequest(databaseController).asBroadcastStream().listen((records) {
      items = records;
    });
  }

  update() async {
    var currentItem = config.focusedItem;
    if (currentItem != null) {
      var refreshedItem = await ItemRecord.fetchWithRowID(currentItem.rowId!);
      if (refreshedItem != null) {
        config.focusedItem = refreshedItem;
      }
    }
    items = await Future.wait<ItemRecord>(items.compactMap<Future<ItemRecord>>(
        (el) async => (await ItemRecord.fetchWithRowID(el.rowId!))!));

    _updateCachedValues();
    notifyListeners();
  }
}
