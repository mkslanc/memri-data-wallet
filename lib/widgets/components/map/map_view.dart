import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:memri/cvu/widgets/components/elements/cvu_map.dart';
import 'package:memri/utilities/helpers/map_helper.dart';
import 'package:memri/widgets/components/map/map_marker.dart';

class MapView extends StatefulWidget {
  final MapViewConfig config;

  MapView({required this.config});

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late final MapboxMapController mapController;
  late final MapModel _mapModel;

  late LatLng currentCoords;

  final List<MapMarker> _markers = [];

  final List<MapMarkerState> _markerStates = [];

  late final bool moveable;

  late final Future _init;

  @override
  initState() {
    super.initState();
    _mapModel = MapModel(
        dataItems: widget.config.dataItems,
        locationResolver: widget.config.locationResolver,
        addressResolver: widget.config.addressResolver,
        labelResolver: widget.config.labelResolver);
    _init = init();
  }

  Future<void> init() async {
    await _mapModel.updateModel();
    moveable = (await widget.config.moveable)!;
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
    _markers.add(MapMarker(Random().nextInt(100000).toString(), coordinates,
        point, _addMarkerStates));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
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
                        target: (firstItem != null)
                            ? firstItem.coordinate
                            : LatLng(0.0, 0.0),
                        zoom: widget.config.maxInitialZoom),
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
