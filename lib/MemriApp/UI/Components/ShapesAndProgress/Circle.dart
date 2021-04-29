import 'package:flutter/material.dart';

class Circle extends StatelessWidget {
  final Color color;

  Circle({this.color = Colors.transparent});

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
