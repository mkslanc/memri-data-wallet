import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/UI/Components/Button/MemriButton.dart';

import '../CVUUINodeResolver.dart';

class CVUMemriButton extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;

  CVUMemriButton({required this.nodeResolver});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: nodeResolver.propertyResolver.item("item"),
        builder: (BuildContext context, AsyncSnapshot<ItemRecord?> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              var item = snapshot.data;
              return MemriButton(
                item: item,
                db: nodeResolver.db,
              );
            }
          }
          return Text("");
        });
  }
}
