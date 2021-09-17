import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUPropertyResolver.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import '../CVUUINodeResolver.dart';

class CVUEditorRow extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUEditorRow({required this.nodeResolver});

  @override
  _CVUEditorRowState createState() => _CVUEditorRowState();
}

class _CVUEditorRowState extends State<CVUEditorRow> {
  AlignmentResolver? alignment;

  Widget? header;

  bool noPadding = false;

  late final Future _init;

  @override
  initState() {
    super.initState();
    _init = init();
  }

  init() async {
    alignment = await widget.nodeResolver.propertyResolver.alignment("column");
    header = await _header;
    noPadding = (await widget.nodeResolver.propertyResolver.boolean("nopadding", false))!;
  }

  Future<Widget> get _header async {
    var text = await widget.nodeResolver.propertyResolver.string("title");
    if (text != null) {
      return Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    }
    return Empty();
  }

  List<Widget> get content {
    return widget.nodeResolver.childrenInForEach();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext context, snapshot) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: alignment?.mainAxis ?? MainAxisAlignment.start,
            crossAxisAlignment: alignment?.crossAxis ?? CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: header,
              ),
              ...content
            ],
          );
        });
  }
}
