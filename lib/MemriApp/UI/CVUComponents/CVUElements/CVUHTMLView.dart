import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/Components/Email/EmailView.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import '../CVUUINodeResolver.dart';

/// A CVU element for displaying HTML content
/// - Set the `content` property to a HTML string
/// - If no width/height is set the view will take up as much space as possible
class CVUHTMLView extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUHTMLView({required this.nodeResolver});

  @override
  _CVUHTMLViewState createState() => _CVUHTMLViewState();
}

class _CVUHTMLViewState extends State<CVUHTMLView> {
  late final Future<String?> _content;

  @override
  initState() {
    super.initState();
    _content = widget.nodeResolver.propertyResolver.string("content");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _content,
        builder: (BuildContext builder, AsyncSnapshot<String?> snapshot) {
          if (snapshot.hasData) {
            return EmailView(emailHTML: snapshot.data);
          }
          return Empty();
        });
  }
}
