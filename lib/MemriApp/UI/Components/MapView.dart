import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:memri/MemriApp/Helpers/MapHelper.dart';
import 'package:memri/MemriApp/UI/CVUComponents/CVUElements/CVUMap.dart';

class MapView extends StatelessWidget {
  final MapViewConfig config;
  final MapModel _mapModel;
  late final MapboxMapController? controller;
  late final LatLng currentCoords;

  MapView({required this.config})
      : _mapModel = MapModel(
            dataItems: config.dataItems,
            locationResolver: config.locationResolver,
            addressResolver: config.addressResolver,
            labelResolver: config.labelResolver);

  void _onMapCreated(MapboxMapController controller) async {
    this.controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _mapModel.updateModel(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var firstItem = _mapModel.items.asMap()[0];
            currentCoords = firstItem?.coordinate ?? LatLng(0.0, 0.0);
            return MapboxMap(
              onMapCreated: _onMapCreated,
              accessToken: MapHelper.accessToken,
              initialCameraPosition: CameraPosition(
                  target: (firstItem != null) ? firstItem.coordinate : LatLng(0.0, 0.0), zoom: 13),
            );
          } else {
            return SizedBox(
              child: CircularProgressIndicator(),
              width: 60,
              height: 60,
            );
          }
        });
  }
}
