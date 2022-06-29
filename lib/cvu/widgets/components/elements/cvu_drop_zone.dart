import 'package:flutter/material.dart';
import 'package:memri/cvu/widgets/components/cvu_ui_node_resolver.dart';
import 'package:memri/widgets/components/image_files/file_drop_zone_unsupported.dart'
    if (dart.library.html) 'package:memri/widgets/components/image_files/file_drop_zone_web.dart';

/// A CVU element for displaying a drop zone
class CVUDropZone extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUDropZone({required this.nodeResolver});

  @override
  _CVUDropZoneState createState() => _CVUDropZoneState();
}

class _CVUDropZoneState extends State<CVUDropZone> {
  @override
  Widget build(BuildContext context) {
    return FileDropZone();
  }
}
