import 'dart:math' as math; // Alias the dart:math import

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapMarker extends StatefulWidget {
  final math.Point _initialPosition;
  final Position _coordinate;
  final void Function(MapMarkerState) _addMarkerState;

  MapMarker(String key, this._coordinate, this._initialPosition, this._addMarkerState)
      : super(key: Key(key));

  @override
  State<StatefulWidget> createState() {
    final state = MapMarkerState(_initialPosition);
    _addMarkerState(state);
    return state;
  }
}

class MapMarkerState extends State<MapMarker> with TickerProviderStateMixin {
  var _initialIconSize = 30.0;
  var _iconSize;

  math.Point _position;

  MapMarkerState(this._position);

  @override
  void initState() {
    _iconSize = _initialIconSize;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var ratio = 1.0;

    if (!kIsWeb) {
      ratio = MediaQuery.of(context).devicePixelRatio;
    }

    return Positioned(
        left: _position.x / ratio - _iconSize / 2,
        top: _position.y / ratio - _iconSize,
        child: IconButton(
          onPressed: _onTap,
          icon: Icon(
            Icons.location_on,
            size: _iconSize,
            color: Colors.red,
          ),
        ));
  }

  void updatePosition(math.Point point) {
    setState(() {
      _position = point;
    });
  }

  Position getCoordinate() {
    return widget._coordinate;
  }

  void _onTap() {
    setState(() {
      _iconSize = _iconSize == _initialIconSize ? _iconSize * 2 : _initialIconSize;
    });
  }
}
