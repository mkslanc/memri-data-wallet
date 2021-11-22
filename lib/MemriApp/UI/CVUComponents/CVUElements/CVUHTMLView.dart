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
  late String? _content;
  late String? src;

  late Future _init;

  @override
  initState() {
    super.initState();
    _init = init();
  }

  @override
  didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init = init();
  }

  init() async {
    src = await widget.nodeResolver.propertyResolver.string("src");
    _content = await widget.nodeResolver.propertyResolver.string("content");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext builder, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (_content != null || src != null) {
              return EmailView(
                emailHTML: _content,
                src: src,
              );
            }
          }
          return Empty();
        });
  }
}
