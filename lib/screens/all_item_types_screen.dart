import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:memri/core/services/pod_service.dart';
import 'package:memri/cvu/controllers/view_context_controller.dart';
import 'package:provider/provider.dart';

import '../core/services/database/schema.dart';
import '../providers/app_provider.dart';
import '../utilities/helpers/app_helper.dart';
import '../widgets/scaffold/cvu_scaffold.dart';
import 'cvu_screen.dart';

class AllItemTypesScreen extends StatefulWidget {
  final ViewContextController viewContextController;

  const AllItemTypesScreen({Key? key, required this.viewContextController}) : super(key: key);

  @override
  State<AllItemTypesScreen> createState() => _AllItemTypesScreenState();
}

class _AllItemTypesScreenState extends State<AllItemTypesScreen> {
  late Future<void> _initFuture;
  late Schema _schema;
  late Map<String, int> _itemCounts;

  @override
  void initState() {
    super.initState();
    _schema = GetIt.I<Schema>();
    _initFuture = _initialize();
    Provider.of<AppProvider>(context, listen: false).currentViewContext =
        widget.viewContextController;
  }

  Future<void> _initialize() async {
    try {
      await _schema.loadFromPod();
      _itemCounts = await GetIt.I<PodService>().countItemsByType(_schema);
    } catch (error) {
      _itemCounts = {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return CVUScaffold(
      child: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }

          if (!_schema.isLoaded) {
            return Center(child: Text('Failed to load schema data.'));
          }

          final sortedTypes = _schema.types.values.toList()
            ..sort((a, b) {
              final countA = _itemCounts[a.type] ?? 0;
              final countB = _itemCounts[b.type] ?? 0;
              return countB.compareTo(countA);
            });

          return ListView.builder(
            itemCount: sortedTypes.length,
            itemBuilder: (context, index) {
              final schemaType = sortedTypes[index];
              final itemType = schemaType.type;
              final itemCount = _itemCounts[itemType] ?? 0;

              return ListTile(
                title: Text(
                  '$itemType ($itemCount)',
                  style: TextStyle(
                    color: itemCount > 0 ? app.colors.black : app.colors.textLight,
                  ),
                ),
                onTap: itemCount > 0
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CVUScreen(
                        viewContextController: ViewContextController.fromParams(
                          viewName: "all" + schemaType.type,
                          itemType: schemaType.type
                        ),
                      ),
                    ),
                  );
                }
                    : null, // Disable button if itemCount is 0
              );
            },
          );
        },
      ),
    );
  }
}
