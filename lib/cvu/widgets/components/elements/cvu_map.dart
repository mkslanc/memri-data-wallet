/*

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:memri/utilities/extensions/collection.dart';

import '../../../../core/models/item.dart';
import '../../../../core/services/map_service.dart';
import '../../../../widgets/components/map/map_view.dart';
import '../cvu_ui_node_resolver.dart';

/// A CVU element for displaying a Map
class CVUMap extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;

  CVUMap({required this.nodeResolver});

  String? get content {
    return nodeResolver.propertyResolver.string("text") ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return MapViewWidget(
      config: config,
    );
  }

  List<Item> Function(Item) get locationResolver {
    return (Item item) => nodeResolver.propertyResolver.items("location");
  }

  List<Item> Function(Item) get addressResolver {
    return (Item item) => nodeResolver.propertyResolver.items("address");
  }

  String? Function(Item) get labelResolver {
    return (Item item) => nodeResolver.propertyResolver.string("label");
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
  List<Item> dataItems;
  List<Item> Function(Item) locationResolver;
  List<Item> Function(Item) addressResolver;
  String? Function(Item) labelResolver;
  double maxInitialZoom;
  bool? moveable;

  void Function(Item)? onPress;

  var colorScheme;

  MapViewConfig(
      {List<Item>? dataItems,
      required this.locationResolver,
      required this.addressResolver,
      required this.labelResolver,
      this.maxInitialZoom = 16,
      bool? moveable,
      this.onPress})
      : this.dataItems = dataItems ?? [],
        this.moveable = moveable ?? true;
}

class MapModel {
  List<Item> dataItems;
  List<Item> Function(Item) locationResolver;
  List<Item> Function(Item) addressResolver;
  String? Function(Item) labelResolver;
  late List<MapItem> items;

  MapModel(
      {required this.dataItems,
      required this.locationResolver,
      required this.addressResolver,
      required this.labelResolver});

  updateModel() async {
    List<MapItem> newItems = [];

    for (var item in dataItems) {
      var locations = await resolveItem(item);
      String labelString = labelResolver(item) ?? "";
      for (var el in locations) {
        newItems.add(MapItem(label: labelString, coordinate: el, dataItem: item));
      }
    }
    items = newItems;
  }

  Future<List<Position>> resolveItem(Item dataItem) async {
    List<Position> clLocations = [];
    List<Position> locations = locationResolver(dataItem).compactMap((item) {
      var latitude = item.get("latitude");
      var longitude = item.get("longitude");
      if (latitude == null || longitude == null) {
        return null;
      }
      return Position(longitude, latitude);
    });
    clLocations.addAll(locations);

    var addresses = addressResolver(dataItem);
    List<Position?> resolvedLocations = [];
    for (var address in addresses) {
      resolvedLocations.add(await lookupAddress(address));
    }
    clLocations.addAll(resolvedLocations.whereType<Position>());

    return clLocations;
  }

  Future<Position?> lookupAddress(Item address) async {
    var location = MapService.shared.getLocationForAddress(address);
    if (location != null) {
      return location;
    } else {
      return await MapService.shared.lookupLocationForAddress(address);
    }
  }
}

class MapItem {
  String label;
  Position coordinate;
  Item? dataItem;

  MapItem({required this.label, required this.coordinate, required this.dataItem});
}
*/
