import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/CVUComponents/CVUUINodeResolver.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';

import 'CVUTextPropertiesModifier.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

/// A CVU element for displaying text
/// - Set the `text` property to the desired content
/// - Set the `font` property to change text appearance
/// - Set the `color` property to change text color
class CVUText extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;
  final Future<TextProperties> textProperties;

  CVUText({required this.nodeResolver, required this.textProperties});

  @override
  _CVUTextState createState() => _CVUTextState();
}

class _CVUTextState extends State<CVUText> {
  late final TextProperties resolvedTextProperties;

  Color? color;

  String? content;

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
    content = (await widget.nodeResolver.propertyResolver.string("text"))?.nullIfBlank;
    resolvedTextProperties = await widget.textProperties;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext builder, snapshot) {
          if (content != null) {
            return Text(
              content!,
              maxLines: resolvedTextProperties.lineLimit,
              style: resolvedTextProperties.textStyle,
              textAlign: resolvedTextProperties.textAlign,
            );
          }
          return Empty();
          // .fixedSize(horizontal: false, vertical: true) TODO
        });
  }
}

/// A CVU element for displaying text with URLs and phone numbers auto-detected and clickable
/// - Set the `text` property to the desired content
/// - Set the `font` property to change text appearance
/// - Set the `color` property to change text color
class CVUSmartText extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;
  final Future<TextProperties> textProperties;

  CVUSmartText({required this.nodeResolver, required this.textProperties});

  @override
  _CVUSmartTextState createState() => _CVUSmartTextState();
}

class _CVUSmartTextState extends State<CVUSmartText> {
  late final TextProperties resolvedTextProperties;

  String? content;

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
    resolvedTextProperties = await widget.textProperties;
    content = (await widget.nodeResolver.propertyResolver.string("text"))?.nullIfBlank;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext builder, AsyncSnapshot snapshot) {
          if (content != null) {
            return Text(
              content!,
              style: resolvedTextProperties.textStyle,
              textAlign: resolvedTextProperties.textAlign,
              maxLines: resolvedTextProperties.lineLimit,
            );
          }
          return Empty();
        });
  }
}
