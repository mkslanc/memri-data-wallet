import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/CVUComponents/CVUUINodeResolver.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';

import 'CVUTextPropertiesModifier.dart';

/// A CVU element for displaying text
/// - Set the `text` property to the desired content
/// - Set the `font` property to change text appearance
/// - Set the `color` property to change text color
class CVUText extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;
  final Future<TextProperties> textProperties;
  late final TextProperties resolvedTextProperties;
  late final Color? color;
  late final String? content;

  CVUText({required this.nodeResolver, required this.textProperties});

  init() async {
    font = await nodeResolver.propertyResolver.font();
    color = await nodeResolver.propertyResolver.color();
    content = (await nodeResolver.propertyResolver.string("text")) ?? "";
    textAlign = await nodeResolver.propertyResolver.textAlignment();
    lineLimit = await nodeResolver.propertyResolver.lineLimit;
    content = (await nodeResolver.propertyResolver.string("text"))?.nullIfBlank;
    resolvedTextProperties = await textProperties;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init(),
        builder: (BuildContext builder, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Text(
              content ?? "",
              maxLines: resolvedTextProperties.lineLimit,
              style: resolvedTextProperties.textStyle,
              textAlign: resolvedTextProperties.textAlign,
            );
          }
          return Text("");
          // .fixedSize(horizontal: false, vertical: true) TODO
        });
  }
}

/// A CVU element for displaying text with URLs and phone numbers auto-detected and clickable
/// - Set the `text` property to the desired content
/// - Set the `font` property to change text appearance
/// - Set the `color` property to change text color
class CVUSmartText extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;
  final Future<TextProperties> textProperties;
  late final TextProperties resolvedTextProperties;
  late final String? content;

  CVUSmartText({required this.nodeResolver, required this.textProperties});

  init() async {
    resolvedTextProperties = await textProperties;
    content = (await nodeResolver.propertyResolver.string("text"))?.nullIfBlank;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init(),
        builder: (BuildContext builder, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Text(
              content ?? "",
              style: resolvedTextProperties.textStyle,
              textAlign: resolvedTextProperties.textAlign,
              maxLines: resolvedTextProperties.lineLimit,
            );
          } else {
            return SizedBox.shrink();
          }
        });
  }
}
