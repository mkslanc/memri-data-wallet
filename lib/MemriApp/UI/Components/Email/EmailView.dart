import 'package:flutter/material.dart';
import 'unsupported.dart' if (dart.library.html) 'web.dart' if (dart.library.io) 'mobile.dart';

class EmailView extends StatelessWidget {
  final String? emailHTML;
  final String? src;

  EmailView({this.emailHTML, this.src});

  @override
  Widget build(BuildContext context) {
    return EmailViewUIKit(emailHTML: emailHTML ?? "", src: src);
  }
}
