import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:memri/core/controllers/app_controller.dart';
import 'package:memri/core/controllers/database_controller.dart';
import 'package:memri/core/models/database/item_edge_record.dart';
import 'package:memri/core/models/database/item_property_record.dart';
import 'package:memri/core/models/database/item_record.dart';
import 'package:memri/core/services/database/property_database_value.dart';
import 'package:memri/utilities/extensions/collection.dart';

class MapHelper {
  Map<int, LatLng> addressLookupResults = {};
  static var shared = MapHelper();

  static String accessToken =
      "pk.eyJ1IjoibWtzbGFuYyIsImEiOiJja29pdHJrbW0wNWl4Mm9ud2Fla212Z2ozIn0.tDDonSujiNPa3GiobveWvw";
  final String _url = 'https://api.mapbox.com/geocoding/v5/mapbox.places/';

  Future<List<MapBoxObject>?> lookupAddress(String string) async {
    String finalUrl = '$_url${Uri.encodeFull(string)}.json?';
    finalUrl += 'access_token=${MapHelper.accessToken}';

    final response = await http.get(Uri.parse(finalUrl));

    if (response.body.contains('message')) {
      throw Exception(json.decode(response.body)['message']);
    }
    return (json.decode(response.body)["features"] as List<dynamic>)
        .map((el) => MapBoxObject.fromJson(el))
        .whereType<MapBoxObject>()
        .toList();
  }

  Future<LatLng?> getLocationForAddress(ItemRecord address,
      [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;
    // Check if the address holds a valid location
    var location = await address.edgeItem("location");
    if (location == null) {
      return null;
    }
    var latitude = (await location.propertyValue("latitude"))?.asDouble();
    var longitude = (await location.propertyValue("longitude"))?.asDouble();
    if (latitude != null && longitude != null) {
      return LatLng(latitude, longitude);
    }
    return null;
  }

  Future<LatLng?> lookupLocationForAddress(ItemRecord address,
      [DatabaseController? db]) async {
    db ??= AppController.shared.databaseController;

    // Make new lookup
    var inclusions = ["street", "city", "state"];
    var addressString = (await Future.wait(inclusions.compactMap(
            (el) async => (await address.propertyValue(el))?.asString())))
        .join("");
    var lookupHash = addressString.hashCode;

    // Check lookups in progress
    var knownLocation = addressLookupResults[lookupHash];
    if (knownLocation != null) {
      // Successful lookup already completed
      return knownLocation;
    }

    // Check if the address holds a valid location
    var location = await address.edgeItem("location");
    if (location != null) {
      var latitude = (await location.propertyValue("latitude"))?.asDouble();
      var longitude = (await location.propertyValue("longitude"))?.asDouble();
      if (latitude != null && longitude != null) {
        var clLocation = LatLng(latitude, longitude);
        var oldLookupHash =
            (await address.propertyValue("locationAutoLookupHash"))?.asString();
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
      var location =
          lookup.firstWhereOrNull((element) => element.center != null);
      if (location != null) {
        var locationItem = ItemRecord(type: "Location");
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
        var locationEdge = ItemEdgeRecord(
            sourceRowID: address.rowId,
            name: "location",
            targetRowID: itemRowId);

        await Future.forEach(locationItemProperties,
            ((ItemPropertyRecord el) async => await el.save(db!.databasePool)));
        await locationEdge.save(db.databasePool);
        addressLookupResults[lookupHash] =
            LatLng(location.center![1], location.center![0]);
        return addressLookupResults[lookupHash];
      }
    }
    return null;
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
        bbox: json["bbox"] == null
            ? null
            : List<double>.from(json["bbox"].map((x) => x.toDouble())),
        center: json["center"] == null
            ? null
            : List<double>.from(json["center"].map((x) => x.toDouble())),
        matchingText: json["matching_text"] ?? "",
        matchingPlaceName: json["matching_place_name"] ?? "",
      );
}
