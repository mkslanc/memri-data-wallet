import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/PageController.dart' as memri;

import '../ViewContextController.dart';

/// The file viewer renderer
/// This presents the data items in a file viewer, that can page horizontally between files
/// The CVU for ItemType > FileViewer {...} must define a `file` expression pointing to a `File` item
/// Optionally the CVU for ItemType > FileViewer {...} can define an `itemTitle` expression
class FileRendererView extends StatelessWidget {
  final memri.PageController pageController;
  final ViewContextController viewContext;

  FileRendererView({required this.pageController, required this.viewContext});

  @override
  Widget build(BuildContext context) {
    return Text("FileRendererView");
  }
}
