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

  CVUText({required this.nodeResolver});

  Future<String?> get content async {
    return (await nodeResolver.propertyResolver.string("text"))?.nullIfBlank;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: content,
        builder: (BuildContext builder, AsyncSnapshot<String?> snapshot) {
          return Text(snapshot.data ?? "");
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
  late final String? color;
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
        builder: (BuildContext builder, AsyncSnapshot<String?> snapshot) {
          return Text(snapshot.data ?? "");
          //TODO: MemriSmartTextView
        });
  }
}
