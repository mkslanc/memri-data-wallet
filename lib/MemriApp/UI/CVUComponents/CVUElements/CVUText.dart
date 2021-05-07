import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/CVUComponents/CVUUINodeResolver.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUFont.dart';

/// A CVU element for displaying text
/// - Set the `text` property to the desired content
/// - Set the `font` property to change text appearance
/// - Set the `color` property to change text color
class CVUText extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;

  late final CVUFont font;
  late final Color? color;
  late final String? content;
  late final TextAlign textAlign;
  late final int? lineLimit;

  CVUText({required this.nodeResolver});

  init() async {
    font = await nodeResolver.propertyResolver.font();
    color = await nodeResolver.propertyResolver.color();
    content = (await nodeResolver.propertyResolver.string("text")) ?? "";
    textAlign = await nodeResolver.propertyResolver.textAlignment();
    lineLimit = await nodeResolver.propertyResolver.lineLimit;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init(),
        builder: (BuildContext builder, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Text(
              content ?? "",
              maxLines: lineLimit,
              style: TextStyle(
                fontSize: font.size,
                fontWeight: font.weight,
                fontStyle: font.italic ? FontStyle.italic : FontStyle.normal,
                color: color,
              ),
              textAlign: textAlign,
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
  late final CVUFont font;
  late final Color? color;
  late final String? content;

  CVUSmartText({required this.nodeResolver});

  init() async {
    font = await nodeResolver.propertyResolver.font();
    color = await nodeResolver.propertyResolver.color();
    content = (await nodeResolver.propertyResolver.string("text"))?.nullIfBlank;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init(),
        builder: (BuildContext builder, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Text(content ?? "");
          } else {
            return SizedBox.shrink();
          }
        });
  }
}
