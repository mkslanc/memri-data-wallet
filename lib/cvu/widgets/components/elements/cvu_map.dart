import 'package:flutter/material.dart';
import 'package:memri/core/models/database/item_record.dart';
import 'package:memri/cvu/widgets/components/cvu_ui_node_resolver.dart';
import 'package:memri/widgets/components/map/map_view.dart';

/// A CVU element for displaying a map
class CVUMap extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;

  CVUMap({required this.nodeResolver});

  Future<String?> get content async {
    return await nodeResolver.propertyResolver.string("text") ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return MapView(config: config);
  }

  Future<List<ItemRecord>> Function(ItemRecord) get locationResolver {
    return (ItemRecord item) => nodeResolver.propertyResolver.items("location");
  }

  Future<List<ItemRecord>> Function(ItemRecord) get addressResolver {
    return (ItemRecord item) async =>
        await nodeResolver.propertyResolver.items("address");
  }

  Future<String?> Function(ItemRecord) get labelResolver {
    return (ItemRecord item) async =>
        await nodeResolver.propertyResolver.string("label");
  }

  MapViewConfig get config {
    var currentItem = nodeResolver.propertyResolver.context.currentItem;
    return MapViewConfig(
        dataItems: currentItem != null ? [currentItem] : [],
        locationResolver: locationResolver,
        addressResolver: addressResolver,
        labelResolver: labelResolver,
        moveable: nodeResolver.propertyResolver.boolean("moveable", true));
  }
}

class MapViewConfig {
  List<ItemRecord> dataItems;
  Future<List<ItemRecord>> Function(ItemRecord) locationResolver;
  Future<List<ItemRecord>> Function(ItemRecord) addressResolver;
  Future<String?> Function(ItemRecord) labelResolver;
  double maxInitialZoom;
  Future<bool?> moveable;

  void Function(ItemRecord)? onPress;

  var colorScheme;

  MapViewConfig(
      {List<ItemRecord>? dataItems,
      required this.locationResolver,
      required this.addressResolver,
      required this.labelResolver,
      this.maxInitialZoom = 16,
      Future<bool?>? moveable,
      this.onPress})
      : this.dataItems = dataItems ?? [],
        this.moveable = moveable ?? Future(() => true);
}
