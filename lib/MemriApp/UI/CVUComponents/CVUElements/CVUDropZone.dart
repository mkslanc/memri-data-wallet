import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/Components/ImagesAndFiles/FileDropZone_unsupported.dart'
    if (dart.library.html) 'package:memri/MemriApp/UI/Components/ImagesAndFiles/FileDropZone_web.dart';

import '../CVUUINodeResolver.dart';

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
