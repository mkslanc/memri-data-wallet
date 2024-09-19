import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:memri/core/services/pod_service.dart';
import 'package:memri/cvu/controllers/view_context_controller.dart';
import 'package:memri/utilities/extensions/collection.dart';
import 'package:memri/utilities/extensions/string.dart';
import 'package:provider/provider.dart';

import '../core/models/item.dart';
import '../core/services/database/schema.dart';
import '../providers/app_provider.dart';
import '../utilities/helpers/app_helper.dart';
import '../widgets/scaffold/cvu_scaffold.dart';
import 'cvu_screen.dart';
import 'error_connectivity_screen.dart';

class AllItemTypesScreen extends StatefulWidget {
  @override
  State<AllItemTypesScreen> createState() => _AllItemTypesScreenState();
}

class _AllItemTypesScreenState extends State<AllItemTypesScreen> {
  late Future<void> _initFuture;
  late Schema _schema;
  late PodService _podService;
  late Map<String, int> _itemCounts;
  late ViewContextController viewContextController; //TODO

  final List<String> _ignoreList = [
    "CVUStoredDefinition",
    "NavigationItem",
    "CryptoKey",
    "ItemEdgeSchema",
    "ItemPropertySchema",
    "Any",
    "AuditItem",
    "PluginRun"
  ];
  late List<Item> _navigationItems;
  late List<String> _favoriteList;
  late List<SchemaType> _sortedTypes;
  List<SchemaType> _filteredTypes = [];

  @override
  void initState() {
    super.initState();
    _schema = GetIt.I<Schema>();
    _podService = GetIt.I<PodService>();
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    try {
      viewContextController = ViewContextController.fromParams();

      var appProvider = Provider.of<AppProvider>(context, listen: false);
      appProvider.isConnectionError = false;
      appProvider.currentViewContext = viewContextController;

      await _schema.loadFromPod();
      List<SchemaType> types =
          _schema.types.values.where((type) => !_ignoreList.contains(type.type)).toList();
      _itemCounts = await _podService.countItemsByType(types.map((type) => type.type).toList());
      _sortedTypes = types
        ..sort((a, b) {
          final countA = _itemCounts[a.type] ?? 0;
          final countB = _itemCounts[b.type] ?? 0;
          return countB.compareTo(countA);
        });
      _navigationItems = await _podService.getNavigationItems();
      _favoriteList =
          _navigationItems.map((item) => item.get<String>("itemType")).toList().compactMap();
    } catch (error) {
      _itemCounts = {};
      _sortedTypes = [];
      _navigationItems = [];
      _favoriteList = [];
      throw error;
    }
  }

  _markFavourite(itemType) async {
    final bool isFavorite = _favoriteList.contains(itemType);
    await (isFavorite ? _removeFavourite(itemType) : _addFavourite(itemType));
    setState(() {
      isFavorite ? _favoriteList.remove(itemType) : _favoriteList.add(itemType);
    });
  }

  String _title(String itemType) => itemType.camelCaseToWords();

  String _viewName(String itemType) => "all" + itemType;

  _addFavourite(String itemType) async {
    Item item = await _podService.createItem(
        item: Item(
      type: "NavigationItem",
      properties: {
        "title": _title(itemType),
        "itemType": itemType,
        "sessionName": _viewName(itemType),
      },
    ));
    _navigationItems.add(item);
  }

  _removeFavourite(String itemType) {
    Item item = _navigationItems.firstWhere((item) => item.get<String>("itemType") == itemType);
    _podService.deleteItem(item: item);
    _navigationItems.remove(item);
  }

  Widget listTile(int index) {
    final SchemaType schemaType = _filteredTypes[index];
    final String itemType = schemaType.type;
    final int itemCount = _itemCounts[itemType] ?? 0;
    final bool isFavorite = _favoriteList.contains(itemType);
    return ListTile(
      title: Text(
        '$itemType ($itemCount)',
        style: TextStyle(
          color: itemCount > 0 ? app.colors.black : app.colors.textLight,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          color: isFavorite == true ? Colors.yellow : null,
        ),
        onPressed: () => _markFavourite(itemType),
      ),
      onTap:
          itemCount > 0 ? openItemView(schemaType.type) : null, // Disable button if itemCount is 0
    );
  }

  openItemView(itemType) => () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CVUScreen(
              viewContextController: ViewContextController.fromParams(
                  viewName: _viewName(itemType), itemType: itemType),
            ),
          ),
        );
      };

  @override
  Widget build(BuildContext context) {
    return CVUScaffold(
      viewContextController: viewContextController,
      child: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return ErrorConnectivityScreen(
                errorMessage: snapshot.error.toString(),
                onRetry: () {
                  setState(() {
                    _initFuture = _initialize(); // Retry initialization
                  });
                });
          } else {
            if (!_schema.isLoaded) {
              return Center(child: Text('Failed to load schema data.'));
            }

            return ValueListenableBuilder<String?>(
              valueListenable: viewContextController.searchStringNotifier,
              builder: (context, searchString, child) {
                var needle = searchString?.toLowerCase() ?? "";
                _filteredTypes =
                    _sortedTypes.where((type) => type.type.toLowerCase().contains(needle)).toList();
                return ListView.builder(
                  itemCount: _filteredTypes.length,
                  itemBuilder: (context, index) {
                    return listTile(index);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
