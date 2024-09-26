//  Created by T Brennan on 30/1/21.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:memri/core/models/item.dart';
import 'package:memri/cvu/controllers/cvu_controller.dart';
import 'package:memri/cvu/controllers/cvu_lookup_controller.dart';
import 'package:memri/cvu/models/cvu_parsed_definition.dart';
import 'package:memri/cvu/models/cvu_value.dart';
import 'package:memri/cvu/models/cvu_view_arguments.dart';
import 'package:memri/cvu/models/view_context.dart';
import 'package:memri/cvu/utilities/binding.dart';
import 'package:memri/providers/connection_provider.dart';
import 'package:memri/providers/settings_provider.dart';
import 'package:memri/utilities/extensions/collection.dart';

import '../services/resolving/cvu_context.dart';
import '../services/resolving/cvu_property_resolver.dart';
import 'database_query.dart';

class ViewContextController extends ChangeNotifier {
  late ViewContextHolder configHolder;

  late CVUController cvuController;
  late CVULookupController lookupController;

  var configObservation;

  CVUDefinitionContent? viewDefinition;
  CVUDefinitionContent rendererDefinition;

  ViewContext get config => configHolder.config;

  ViewContextController? previousViewContext;

  ViewContextController(
      {required ViewContextHolder config,
      CVUController? cvuController,
      rendererDefinition})
      : this.rendererDefinition = rendererDefinition ?? CVUDefinitionContent() {
    this.cvuController = cvuController ?? GetIt.instance();
    this.lookupController = CVULookupController();
    config.config.viewArguments ?? CVUViewArguments();
    this.configHolder = config;

    if (this.config.viewName != null && this.config.viewName != "customView") {
      viewDefinition = config.config.viewDefinition;
    }

    _updateCachedValues();

    setupQueryObservation();

    searchStringNotifier = ValueNotifier(configHolder.config.query.searchString);

    this.cvuController.addListener(() => updateUI());
  }

  factory ViewContextController.fromParams({
    String viewName = "customView",
    String rendererName = "custom",
    CVUDefinitionContent? viewDefinition,
    CVUViewArguments? viewArguments,
    Item? focusedItem,
    CVUController? cvuController,
    String defaultRenderer = "list",
    String? overrideRenderer,
    CVUDefinitionContent? customDefinition,
    List<Item>? items,
    bool inheritDatasource = false,
    ViewContextController? previousContext,
    String? itemType,
  }) {
    viewArguments ??= CVUViewArguments();
    viewArguments.argumentItem = focusedItem;
    cvuController ??= GetIt.instance();

    viewDefinition ??=
        cvuController.viewDefinitionFor(viewName: viewName, customDefinition: customDefinition) ??
            CVUDefinitionContent();
    var newContext = CVUContext(
        currentItem: focusedItem,
        selector: null,
        viewName: viewName,
        viewDefinition: viewDefinition,
        viewArguments: viewArguments);
    var datasource = viewDefinition.definitions.firstWhereOrNull(
            (definition) => definition.type == CVUDefinitionType.datasource);
    var queryConfig = DatabaseQueryConfig.queryConfigWith(
      context: newContext,
      datasource: datasource,
      inheritQuery: inheritDatasource ? previousContext?.config.query : null,
      itemType: itemType//TODO types?
    );

    var rendererName = overrideRenderer ?? ((() =>
        viewDefinition!
            .propertyResolver(
              context: newContext,
              lookup: CVULookupController(),
            )
            .string("defaultRenderer") ??
        defaultRenderer))();

    var config = ViewContext(
        viewName: viewName,
        rendererName: rendererName,
        viewDefinition: viewDefinition,
        viewArguments: viewArguments,
        focusedItem: focusedItem,
        query: queryConfig);

    var holder = ViewContextHolder(config);
    var viewContextController =  ViewContextController(config: holder, cvuController: cvuController);
    //TODO: not sure of side effects for now
    if (items != null) {
      viewContextController.items = items;
      viewContextController.focusedIndex = items.indexWhere((item) => item == focusedItem); //TODO: remake

    }
    viewContextController.previousViewContext = previousContext; //TODO:
    return viewContextController;
  }

  // MARK: Search State
  String? get searchString => searchStringNotifier.value;

  late ValueNotifier<String?> searchStringNotifier;
  set searchString(String? newValue) {
    searchStringNotifier.value = newValue;
    config.query.searchString = newValue;
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

  Item? get focusedItem => config.focusedItem;

  set focusedItem(Item? newValue) {
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
      {Item? item,
      List<Item>? items,
      String? overrideRenderer,
      CVUDefinitionContent? overrideViewDefinition,
      CVUDefinitionContent? nodeDefinition,
      CVUViewArguments? viewArguments,
      bool blankIfNoDefinition = false}) {
    var key = item != null ? Key(item.id) : null;
    return cvuController.render(
        cvuContext: getCVUContext(
            item: item,
            items: items,
            overrideViewDefinition: overrideViewDefinition,
            overrideRenderer: overrideRenderer,
            viewArguments: viewArguments),
        nodeDefinition: nodeDefinition,
        lookup: lookupController,
        blankIfNoDefinition: blankIfNoDefinition,
        key: key);
  }

  CVUContext getCVUContext(
      {Item? item,
      List<Item>? items,
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
    viewDefinition ??= viewName != null
        ? cvuController.viewDefinitionFor(viewName: viewName)
        : null; //TODO this part is full of unused legacy we keep stumbling on

    if (viewDefinition == null) {
      var item = config.focusedItem;
      viewDefinition = item != null
          ? cvuController.viewDefinitionForItemRecord(item: item)
          : null;
    }

    if (viewDefinition != null) {
      config.viewDefinition = viewDefinition!;
    }

    rendererDefinition =
        cvuController.rendererDefinitionFor(getCVUContext())?.parsed ??
            CVUDefinitionContent();

    viewDefinitionPropertyResolver = config.viewDefinition.propertyResolver(
      context: getCVUContext(),
      lookup: CVULookupController(),
    );

    rendererDefinitionPropertyResolver = rendererDefinition.propertyResolver(
      context: getCVUContext(),
      lookup: CVULookupController(),
    );
    notifyListeners();
  }

  Set<String> get supportedRenderers {
    var defined =
        (viewDefinitionPropertyResolver.stringArray("supportedRenderers"))
            .map((property) => property.toLowerCase());
    if (defined.isNotEmpty) {
      return Set.of(defined);
    } else {
      var defaultRenderer =
          (viewDefinitionPropertyResolver.string("defaultRenderer"))
              ?.toLowerCase();
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
      context: getCVUContext(),
      lookup: CVULookupController(),
    );
  }();

  late CVUPropertyResolver rendererDefinitionPropertyResolver = () {
    return rendererDefinition.propertyResolver(
      context: getCVUContext(),
      lookup: CVULookupController(),
    );
  }();

  CVUPropertyResolver? get itemPropertyResolver {
    var viewDefinition =
        cvuController.viewDefinitionForItemRecord(item: focusedItem);
    if (viewDefinition == null) {
      return null;
    }
    return viewDefinition.propertyResolver(
      context: getCVUContext(item: focusedItem),
      lookup: CVULookupController(),
    );
  }

  setRendererProperty(String renderer, String property, CVUValue value) {
    var index = config.viewDefinition.definitions.indexWhere((definition) =>
        definition.type == CVUDefinitionType.renderer &&
        definition.name == renderer);
    if (index >= 0) {
      config.viewDefinition.definitions[index].parsed.properties[property] =
          value;
    } else {
      var props = CVUDefinitionContent(properties: {property: value});
      var def = CVUParsedDefinition(
          type: CVUDefinitionType.renderer, name: renderer, parsed: props);
      config.viewDefinition.definitions.add(def);
    }
    _updateCachedValues();
  }

  CVUPropertyResolver? nodePropertyResolver(Item item) {
    var context = getCVUContext(item: item);
    return cvuController.nodeDefinitionFor(context)?.propertyResolver(
          context: context,
          lookup: CVULookupController(),
        );
  }

  // MARK: Query RESULT
  /// This holds the array of results for the query. If `isObserving` is set to true, this will be up to date with any changes in the database.
  List<Item>? _items;
  List<Item> get items => _items ?? [];
  set items(List<Item> items) {
    _items = items;
    notifyListeners();
  }

  /// Convenience variable returning whether the items are loaded or not
  bool get isLoaded => _items != null;

  /// Convenience variable returning whether there are any items
  bool get hasItems => items.isNotEmpty;

  // MARK: Selection State
  List<dynamic> _selectedItems = <String>[];

  get selectedItems => _selectedItems;

  set selectedItems(selectedItems) {
    _selectedItems = selectedItems;
    config.viewArguments?.args["selectedItems"] =
        CVUValueArray(_selectedItems.compactMap((uid) => CVUValueItem(uid)));
  }

  Binding<Set<int>> get selectedIndicesBinding {
    _selectedItems =
        (config.viewArguments?.args["selectedItems"] is CVUValueArray)
            ? (config.viewArguments?.args["selectedItems"] as CVUValueArray)
                .value
                .compactMap((CVUValue e) => (e as CVUValueItem).value)
            : [];
    return Binding(
        () => Set.of(selectedItems
            .map((uid) => items.indexWhere((item) => item.id == uid))
            .whereType<int>()
            .toList()), (Set<int> newValue) {
      selectedItems = Set.of(
              newValue.toList().compactMap((index) => items.asMap()[index]?.id))
          .toList();
    });
  }

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
    queryConfig.removeListener(setupQueryObservation);

    /// Only set up an observation if `isObserving` is true
    if (!isObservingQuery) {
      return;
    }

    queryConfig.addListener(setupQueryObservation);
    getItems(queryConfig);
  }

  getItems(DatabaseQueryConfig queryConfig) {
    final connectionProvider = GetIt.I<ConnectionProvider>();
    connectionProvider.isConnectionError = false;
    queryConfig.executeRequest().then((records) {
      items = records;
    }).onError((e, s) {
      connectionProvider.isConnectionError = true;
    });
  }

  refreshScreen() async { //TODO:
    var settingsProvider = GetIt.I<SettingsProvider>();
    if(settingsProvider.cvuDeveloperMode) {
      var cvuController = GetIt.I<CVUController>();
      await cvuController.init(forceLoad: true);
    }
    getItems(config.query);
  }

  updateUI() {
    viewDefinition = null;
    _updateCachedValues();
  }
}
