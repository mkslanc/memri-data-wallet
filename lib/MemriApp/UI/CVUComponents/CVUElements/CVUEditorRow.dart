import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUPropertyResolver.dart';

import '../CVUUINodeResolver.dart';

class CVUEditorRow extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;
  late final AlignmentResolver alignment;
  late final Widget header;
  late final bool noPadding;

  CVUEditorRow({required this.nodeResolver});

  init(String alignType) async {
    alignment = await nodeResolver.propertyResolver.alignment(alignType);
    header = await _header;
    noPadding = (await nodeResolver.propertyResolver.boolean("nopadding", false))!;
  }

  Future<Widget> get _header async {
    var text = await nodeResolver.propertyResolver.string("title");
    if (text != null) {
      Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    }
    return Text("");
  }

  List<Widget> get content {
    return nodeResolver.childrenInForEach();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init("column"),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: (!noPadding) ? 10 : 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: alignment.mainAxis,
                crossAxisAlignment: alignment.crossAxis,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: header,
                  ),
                  ...content
                ],
              ),
            );
          }
          return Text("");
        });
  }
}
