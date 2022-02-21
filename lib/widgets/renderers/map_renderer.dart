import 'package:flutter/material.dart';
import 'package:memri/controllers/page_controller.dart' as memri;
import 'package:memri/controllers/view_context_controller.dart';
import 'package:memri/models/database/item_record.dart';
import 'package:memri/widgets/components/cvu/elements/cvu_map.dart';
import 'package:memri/widgets/components/map/map_view.dart';

/// The map renderer
/// This presents the data items on a map
/// - for an item to be shown the CVU for ItemType > map {...} must define an expression resolving to either a `Location` or `Address` item
/// - you can provide a `label` property in the CVU for ItemType > map {...}
class MapRendererView extends StatelessWidget {
  final memri.PageController pageController;
  final ViewContextController viewContext;

  MapRendererView({required this.pageController, required this.viewContext});

  @override
  Widget build(BuildContext context) {
    return MapView(config: mapConfig);
  }

  Future<List<ItemRecord>> Function(ItemRecord) get locationResolver {
    return (ItemRecord item) async =>
        await viewContext.nodePropertyResolver(item)?.items("location") ?? [];
  }

  Future<List<ItemRecord>> Function(ItemRecord) get addressResolver {
    return (ItemRecord item) async =>
        await viewContext.nodePropertyResolver(item)?.items("address") ?? [];
  }

  Future<String?> Function(ItemRecord) get labelResolver {
    return (ItemRecord item) async => await viewContext.nodePropertyResolver(item)?.string("label");
  }

  MapViewConfig get mapConfig {
    var resolver = viewContext.rendererDefinitionPropertyResolver;
    var moveable = resolver.boolean("moveable", true);

    return MapViewConfig(
        dataItems: viewContext.items,
        locationResolver: locationResolver,
        addressResolver: addressResolver,
        labelResolver: labelResolver,
        moveable: moveable);
  }
}
