import 'package:flutter/material.dart';
import 'unsupported.dart' if (dart.library.html) 'web.dart' if (dart.library.io) 'mobile.dart';

class EmailView extends StatelessWidget {
  final String? emailHTML;

  EmailView({this.emailHTML});

  @override
  Widget build(BuildContext context) {
    return EmailViewUIKit();
  }
}
