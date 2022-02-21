import 'package:flutter/material.dart';

class Circle extends StatelessWidget {
  final Color color;
  final Widget? child;
  final BoxBorder? border;

  Circle({this.color = Colors.transparent, this.child, this.border});

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
        color: color,
      ),
      child: child,
    );
  }
}
