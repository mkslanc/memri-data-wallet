import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:memri/core/models/database/item_record.dart';
import 'package:memri/utilities/helpers/map_helper.dart';
import 'package:memri/widgets/components/cvu/cvu_ui_node_resolver.dart';
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

class MapModel {
  List<ItemRecord> dataItems;
  Future<List<ItemRecord>> Function(ItemRecord) locationResolver;
  Future<List<ItemRecord>> Function(ItemRecord) addressResolver;
  Future<String?> Function(ItemRecord) labelResolver;
  late List<MapItem> items;

  MapModel(
      {required this.dataItems,
      required this.locationResolver,
      required this.addressResolver,
      required this.labelResolver});

  updateModel() async {
    var newItems = await Future.wait(dataItems.map((item) async {
      var locations = await resolveItem(item);
      String labelString = await labelResolver(item) ?? "";
      return locations.map((el) {
        return MapItem(label: labelString, coordinate: el, dataItem: item);
      });
    }));
    items = newItems.expand((element) => element).toList();
  }

  Future<List<LatLng>> resolveItem(ItemRecord dataItem) async {
    List<LatLng> clLocations = [];
    List<LatLng> locations =
        (await Future.wait((await locationResolver(dataItem)).map((item) async {
      var latitude = (await item.propertyValue("latitude"))?.asDouble();
      var longitude = (await item.propertyValue("longitude"))?.asDouble();
      if (latitude == null || longitude == null) {
        return null;
      }
      return LatLng(latitude, longitude);
    })))
            .whereType<LatLng>()
            .toList();
    clLocations.addAll(locations);

    var addresses = await addressResolver(dataItem);
    var resolvedLocations =
        await Future.wait(addresses.map((el) async => await lookupAddress(el)));
    clLocations.addAll(resolvedLocations.whereType<LatLng>());

    return clLocations;
  }

  Future<LatLng?> lookupAddress(ItemRecord address) async {
    var location = await MapHelper.shared.getLocationForAddress(address);
    if (location != null) {
      return location;
    } else {
      return await MapHelper.shared.lookupLocationForAddress(address);
    }
  }
}

class MapItem {
  String label;
  LatLng coordinate;
  ItemRecord? dataItem;

  MapItem(
      {required this.label, required this.coordinate, required this.dataItem});
}
