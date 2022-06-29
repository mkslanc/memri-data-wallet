import 'package:flutter/material.dart';
import 'package:memri/cvu/widgets/renderers/grid_renderer.dart';

/// The grid renderer flow layout
/// This presents the data in a one-after-each-other order
class GridRendererFlowView extends GridRenderer {
  GridRendererFlowView({required spacing, required elements})
      : super(spacing: spacing, elements: elements);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing.x.toDouble(),
      runSpacing: spacing.y.toDouble(),
      children: elements,
    );
  }
}
