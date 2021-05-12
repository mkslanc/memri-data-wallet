import 'package:flutter/material.dart';

class Circle extends StatelessWidget {
  final Color color;
  final Widget? child;

  Circle({this.color = Colors.transparent, this.child});

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: child,
    );
  }
}
