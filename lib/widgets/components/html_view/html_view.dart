import 'package:flutter/material.dart';

import 'html_view_kit_mobile.dart';

class HtmlView extends StatelessWidget {
  final String? html;
  final String? src;
  final bool reload;

  HtmlView({this.html, this.src, required this.reload});

  @override
  Widget build(BuildContext context) {
    return HtmlViewUIKit(
      html: html,
      src: src,
      reload: reload,
    );
  }
}
