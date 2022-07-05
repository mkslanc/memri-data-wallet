import 'package:flutter/material.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/cvu/widgets/components/cvu_ui_node_resolver.dart';

/// A CVU element for displaying a loading indicator
class CVULoadingIndicator extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVULoadingIndicator({required this.nodeResolver});

  @override
  _CVULoadingIndicatorState createState() => _CVULoadingIndicatorState();
}

class _CVULoadingIndicatorState extends State<CVULoadingIndicator>
    with TickerProviderStateMixin {
  double size = 20;
  double? speed;
  Color? color;

  late AnimationController rotateController;
  late Animation<double> rotateAnimation;

  @override
  void initState() {
    rotateController = AnimationController(
      duration: const Duration(seconds: 1),
      reverseDuration: const Duration(seconds: 1),
      vsync: this,
    );

    rotateAnimation =
        CurvedAnimation(parent: rotateController, curve: Curves.linear);
    super.initState();
    init();
  }

  void init() {
    speed = (widget.nodeResolver.propertyResolver.number("speed"));
    rotateController.repeat(
        min: 0, max: 1, period: Duration(milliseconds: 1000 ~/ (speed ?? 1)));
    color = widget.nodeResolver.propertyResolver.color();
    size = (widget.nodeResolver.propertyResolver.number("size")) ?? 20;
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() => init());
  }

  @override
  void dispose() {
    rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
        turns: rotateAnimation,
        child: app.icons.loader(
            color: color ?? app.colors.primary, width: size, height: size),
      );
}
