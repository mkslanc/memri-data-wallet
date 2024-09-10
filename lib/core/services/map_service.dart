import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:memri/utilities/extensions/collection.dart';

import '../../utilities/helpers/app_helper.dart';
import '../models/item.dart';

class MapService {
  Map<int, Position> addressLookupResults = {};
  static var shared = MapService();

  final String _url = 'https://api.mapbox.com/geocoding/v5/mapbox.places/';

  Future<List<MapBoxObject>?> lookupAddress(String string) async {
    String finalUrl = '$_url${Uri.encodeFull(string)}.json?';
    finalUrl += 'access_token=${app.settings.mapboxAccessToken}';

    final response = await http.get(Uri.parse(finalUrl));

    if (response.body.contains('message')) {
      throw Exception(json.decode(response.body)['message']);
    }
    return (json.decode(response.body)["features"] as List<dynamic>)
        .map((el) => MapBoxObject.fromJson(el))
        .whereType<MapBoxObject>()
        .toList();
  }

  Position? getLocationForAddress(Item address) {
    // Check if the address holds a valid location
    var location = address.getEdgeTargets("location");

    if (location == null || location.length == 0) {
      return null;
    }
    var latitude = location[0].get("latitude");
    var longitude = location[0].get("longitude");
    if (latitude != null && longitude != null) {
      return Position(longitude, latitude);
    }
    return null;
  }

  Future<Position?> lookupLocationForAddress(Item address) async {
    // Make new lookup
    var inclusions = ["street", "city", "state"];
    var addressString = inclusions.compactMap((el) => address.get(el)).join("");
    var lookupHash = addressString.hashCode;

    // Check lookups in progress
    var knownLocation = addressLookupResults[lookupHash];
    if (knownLocation != null) {
      // Successful lookup already completed
      return knownLocation;
    }

    // Check if the address holds a valid location
    var location = address.getEdgeTargets("location");
    if (location != null && location.length > 0) {
      var latitude = location[0].get("latitude");
      var longitude = location[0].get("longitude");
      if (latitude != null && longitude != null) {
        var clLocation = Position(longitude, latitude);
        var oldLookupHash = address.get("locationAutoLookupHash");
        if (oldLookupHash != null) {
          // This was an automatic lookup - check it's still current
          if (oldLookupHash == lookupHash.toString()) {
            return clLocation;
          }
        }
      }
    }
    var lookup = await lookupAddress(addressString);
    if (lookup != null) {
      var location = lookup.firstWhereOrNull((element) => element.center != null);
      if (location != null) {
        /*var locationItem = Item(type: "Location");
        var itemRowId = await locationItem.insert(db.databasePool);

        var locationItemProperties = [
          ItemPropertyRecord(
              itemRowID: itemRowId,
              name: "latitude",
              value: PropertyDatabaseValueDouble(location.center![1])),
          ItemPropertyRecord(
              itemRowID: itemRowId,
              name: "longitude",
              value: PropertyDatabaseValueDouble(location.center![0]))
        ];
        var locationEdge =
            ItemEdgeRecord(sourceRowID: address.rowId, name: "location", targetRowID: itemRowId);

        await Future.forEach(locationItemProperties,
            ((ItemPropertyRecord el) async => await el.save(db!.databasePool)));
        await locationEdge.save(db.databasePool);*/
        addressLookupResults[lookupHash] = Position(location.center![0], location.center![1]);
        return addressLookupResults[lookupHash];
      }
    }
  }
}

class MapBoxObject {
  String id;
  String? addressNumber;
  String text;
  String placeName;
  List<double>? bbox;
  List<double>? center;
  String matchingText;
  String matchingPlaceName;

  //TODO: we could use more params

  MapBoxObject({
    required this.id,
    required this.addressNumber,
    required this.text,
    required this.placeName,
    required this.bbox,
    required this.center,
    required this.matchingText,
    required this.matchingPlaceName,
  });

  factory MapBoxObject.fromJson(Map<String, dynamic> json) => MapBoxObject(
        id: json["id"],
        addressNumber: json["address"],
        text: json["text"],
        placeName: json["place_name"],
        bbox:
            json["bbox"] == null ? null : List<double>.from(json["bbox"].map((x) => x.toDouble())),
        center: json["center"] == null
            ? null
            : List<double>.from(json["center"].map((x) => x.toDouble())),
        matchingText: json["matching_text"] ?? "",
        matchingPlaceName: json["matching_place_name"] ?? "",
      );
}
