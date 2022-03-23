import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../cvu_ui_node_resolver.dart';

/// A CVU element for displaying a toggle
/// - Set the `value` property to an expression representing the boolean item property to be toggled
class CVULoadingIndicator extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVULoadingIndicator({required this.nodeResolver});

  @override
  _CVULoadingIndicatorState createState() => _CVULoadingIndicatorState();
}

class _CVULoadingIndicatorState extends State<CVULoadingIndicator> with TickerProviderStateMixin {
  double size = 20;
  double? speed;
  Color? color;

  late AnimationController rotateController;
  late Animation<double> rotateAnimation;

  late Future _init;

  @override
  void initState() {
    rotateController = AnimationController(
      duration: const Duration(seconds: 1),
      reverseDuration: const Duration(seconds: 1),
      vsync: this,
    );

    rotateAnimation = CurvedAnimation(parent: rotateController, curve: Curves.linear);
    super.initState();
    _init = init();
  }

  init() async {
    speed = (await widget.nodeResolver.propertyResolver.number("speed"));
    rotateController.repeat(min: 0, max: 1, period: Duration(milliseconds: 1000 ~/ (speed ?? 1)));
    color = await widget.nodeResolver.propertyResolver.color();
    size = (await widget.nodeResolver.propertyResolver.number("size")) ?? 20;
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init = init();
  }

  @override
  void dispose() {
    rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, _) => RotationTransition(
        turns: rotateAnimation,
        child: SizedBox(
          height: size,
          width: size,
          child: SvgPicture.asset("assets/images/loader.svg", color: color ?? Color(0xFFFE570F)),
        ),
      ),
    );
  }
}
