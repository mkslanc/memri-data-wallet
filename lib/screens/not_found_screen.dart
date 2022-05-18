import 'package:flutter/material.dart';
import 'package:memri/constants/cvu/cvu_font.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Text(
      '404 Not Found',
      style: CVUFont.headline1,
    )));
  }
}
