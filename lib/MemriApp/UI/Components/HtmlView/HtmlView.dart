import 'package:flutter/material.dart';
import 'unsupported.dart' if (dart.library.html) 'web.dart' if (dart.library.io) 'mobile.dart';

class HtmlView extends StatelessWidget {
  final String? html;
  final String? src;

  HtmlView({this.html, this.src});

  @override
  Widget build(BuildContext context) {
    return HtmlViewUIKit(html: html, src: src);
  }
}
