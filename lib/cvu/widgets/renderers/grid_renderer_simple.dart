import 'package:flutter/material.dart';
import 'package:memri/cvu/widgets/renderers/grid_renderer.dart';

/// The grid renderer simple layout
/// This presents the data in a grid (aka collection view)
class GridRendererSimpleView extends GridRenderer {
  final Axis scrollDirection;
  final EdgeInsets insets;

  GridRendererSimpleView(
      {required this.scrollDirection,
      required this.insets,
      required spacing,
      required elements})
      : super(spacing: spacing, elements: elements);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      //TODO layout
      addRepaintBoundaries: false,
      physics: AlwaysScrollableScrollPhysics(),
      scrollDirection: scrollDirection,
      childAspectRatio: 2,
      shrinkWrap: true,
      primary: false,
      padding: insets,
      //crossAxisSpacing: 5,
      //mainAxisSpacing: 5,
      crossAxisCount: 3,
      children: elements,
    );
  }
}
