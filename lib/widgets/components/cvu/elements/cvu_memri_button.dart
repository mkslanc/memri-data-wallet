import 'package:flutter/material.dart';
import 'package:memri/models/database/item_record.dart';
import 'package:memri/widgets/components/button/memri_button.dart';
import 'package:memri/widgets/components/cvu/cvu_ui_node_resolver.dart';
import 'package:memri/widgets/empty.dart';

class CVUMemriButton extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUMemriButton({required this.nodeResolver});

  @override
  _CVUMemriButtonState createState() => _CVUMemriButtonState();
}

class _CVUMemriButtonState extends State<CVUMemriButton> {
  late final Future<ItemRecord?> _item;

  @override
  initState() {
    super.initState();
    _item = widget.nodeResolver.propertyResolver.item("item");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _item,
        builder: (BuildContext context, AsyncSnapshot<ItemRecord?> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              var item = snapshot.data;
              return MemriButton(
                item: item,
                db: widget.nodeResolver.db,
              );
            }
          }
          return Empty();
        });
  }
}
