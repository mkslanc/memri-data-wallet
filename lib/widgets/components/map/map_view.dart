/*
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../cvu/widgets/components/elements/cvu_map.dart';
import 'map_marker.dart';

class MapViewWidget extends StatefulWidget {
  final MapViewConfig config;

  MapViewWidget({required this.config});

  @override
  _MapViewWidgetState createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
 // late final MapboxMap mapController;
  late final MapModel _mapModel;

  late Position currentCoords;

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
    moveable = widget.config.moveable!;
  }

  void _addMarkerStates(MapMarkerState markerState) {
    _markerStates.add(markerState);
  }

*/
/*  void _onMapCreated(MapboxMap controller) {
    mapController = controller;
   *//*
*/
/* mapController.addListener(() {
      if (mapController.isCameraMoving) {
        _updateMarkerPosition();
      }
    });*//*
*/
/*
  }*//*


  void _onCameraIdleCallback(MapIdleEventData? mapIdleEventData) {
    _updateMarkerPosition();
  }

  void _updateMarkerPosition() {
    final coordinates = <Position>[];

    for (final markerState in _markerStates) {
      coordinates.add(markerState.getCoordinate());
    }

    */
/*mapController.toScreenLocationBatch(coordinates).then((points) {
      _markerStates.asMap().forEach((i, value) {
        _markerStates[i].updatePosition(points[i]);
      });
    });*//*

  }

  void _addMarker(math.Point point, Position coordinates) {
    _markers
        .add(MapMarker(math.Random().nextInt(100000).toString(), coordinates, point, _addMarkerStates));
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
              //_addMarker(math.Point(0,0), currentCoords);
            }

            return IgnorePointer(
              ignoring: !moveable,
              child: Stack(
                children: [
                  MapWidget(
                    styleUri: MapboxStyles.LIGHT,
                    key: ValueKey("mapWidget"),
                    //trackCameraPosition: true,
                    //onMapCreated: _onMapCreated,
                    cameraOptions: CameraOptions(
                      center: (firstItem != null) ? Point(coordinates: firstItem.coordinate) : null,
                      zoom: widget.config.maxInitialZoom
                    ),
                    onMapIdleListener: _onCameraIdleCallback
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
*/
