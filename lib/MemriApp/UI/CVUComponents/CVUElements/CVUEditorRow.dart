import 'package:flutter/material.dart';

import '../CVUUINodeResolver.dart';

class CVUEditorRow extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;

  CVUEditorRow({required this.nodeResolver});

  Future<Widget> get header async {
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
        //TODO: alignment: nodeResolver.propertyResolver.alignment() .if(!nodeResolver.propertyResolver.bool("nopadding", defaultValue: false)) { $0.padding(.horizontal) }
        future: header,
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return SizedBox(
                //TODO:
                height: 200,
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: snapshot.data!,
                    ),
                    ...content
                  ],
                ),
              );
            }
          }
          return Text("");
        });
  }
}
