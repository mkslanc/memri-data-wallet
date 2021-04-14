import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/Components/Email/EmailView.dart';

import '../CVUUINodeResolver.dart';

/// A CVU element for displaying HTML content
/// - Set the `content` property to a HTML string
/// - If no width/height is set the view will take up as much space as possible
class CVUHTMLView extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;

  CVUHTMLView({required this.nodeResolver});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: nodeResolver.propertyResolver.string("content"),
        builder: (BuildContext builder, AsyncSnapshot<String?> snapshot) {
          if (snapshot.hasData) {
            return EmailView(emailHTML: snapshot.data);
          }
          return Text("");
        });
  }
}
