import 'package:flutter/material.dart';

class HtmlViewUIKit extends StatelessWidget {
  final String? html;
  final String? src;
  final Function? callback;
  final bool reload;

  HtmlViewUIKit({this.html, this.src, this.callback, required this.reload});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Text("Not implemented now"));
  }
}
