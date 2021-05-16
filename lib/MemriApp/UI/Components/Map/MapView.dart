import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:memri/MemriApp/Helpers/MapHelper.dart';
import 'package:memri/MemriApp/UI/CVUComponents/CVUElements/CVUMap.dart';
import 'package:memri/MemriApp/UI/Components/Map/MapMarker.dart';

class MapView extends StatelessWidget {
  final MapViewConfig config;
  final MapModel _mapModel;
  late final MapboxMapController mapController;
  late final LatLng currentCoords;
  final List<MapMarker> _markers = [];
  final List<MapMarkerState> _markerStates = [];
  late final bool moveable;

  MapView({required this.config})
      : _mapModel = MapModel(
            dataItems: config.dataItems,
            locationResolver: config.locationResolver,
            addressResolver: config.addressResolver,
            labelResolver: config.labelResolver);

  Future<void> init() async {
    await _mapModel.updateModel();
    moveable = (await config.moveable)!;
  }

  void _addMarkerStates(MapMarkerState markerState) {
    _markerStates.add(markerState);
  }

  void _onMapCreated(MapboxMapController controller) {
    mapController = controller;
    mapController.addListener(() {
      if (mapController.isCameraMoving) {
        _updateMarkerPosition();
      }
    });
  }

  void _onCameraIdleCallback() {
    _updateMarkerPosition();
  }

  void _updateMarkerPosition() {
    final coordinates = <LatLng>[];

    for (final markerState in _markerStates) {
      coordinates.add(markerState.getCoordinate());
    }

    mapController.toScreenLocationBatch(coordinates).then((points) {
      _markerStates.asMap().forEach((i, value) {
        _markerStates[i].updatePosition(points[i]);
      });
    });
  }

  void _addMarker(Point<double> point, LatLng coordinates) {
    _markers
        .add(MapMarker(Random().nextInt(100000).toString(), coordinates, point, _addMarkerStates));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var firstItem = _mapModel.items.asMap()[0];

            if (firstItem != null) {
              currentCoords = firstItem.coordinate;
              _addMarker(Point(0, 0), currentCoords);
            }

            return IgnorePointer(
              ignoring: !moveable,
              child: Stack(
                children: [
                  MapboxMap(
                    trackCameraPosition: true,
                    onMapCreated: _onMapCreated,
                    onCameraIdle: _onCameraIdleCallback,
                    accessToken: MapHelper.accessToken,
                    initialCameraPosition: CameraPosition(
                        target: (firstItem != null) ? firstItem.coordinate : LatLng(0.0, 0.0),
                        zoom: config.maxInitialZoom),
                  ),
                  Stack(
                    children: _markers,
                  ),
                ],
              ),
            );
          } else {
            return Flexible(
              child: Center(
                child: SizedBox(
                  child: CircularProgressIndicator(),
                  width: 30,
                  height: 30,
                ),
              ),
            );
          }
        });
  }
}
