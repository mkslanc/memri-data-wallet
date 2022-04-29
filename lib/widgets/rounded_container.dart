import 'package:flutter/material.dart';

class RoundedContainer extends StatelessWidget {
  final Widget child;
  final double? radius;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final Color? color;
  final BoxBorder? border;
  final BoxConstraints? constraints;

  const RoundedContainer(
      {required this.child,
      this.radius,
      this.color,
      this.width,
      this.height,
      this.padding,
      this.border,
      this.constraints,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: constraints,
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        border: border,
        borderRadius: BorderRadius.circular(radius ?? 16),
        color: color,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
