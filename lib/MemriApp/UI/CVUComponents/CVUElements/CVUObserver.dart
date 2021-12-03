import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/AppController.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/UI/CVUComponents/CVUUINodeResolver.dart';
import 'package:moor/moor.dart';

import 'CVUTextPropertiesModifier.dart';

class CVUObserver extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUObserver({required this.nodeResolver});

  @override
  _CVUObserverState createState() => _CVUObserverState();
}

class _CVUObserverState extends State<CVUObserver> {
  late TextProperties resolvedTextProperties;

  ItemRecord? item;
  String? property;
  Stream<List<dynamic>>? propertyStream;

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
    property = await widget.nodeResolver.propertyResolver.string("property");
    item = await widget.nodeResolver.propertyResolver.item("item");
    if (property != null && item != null) {
      initPropertyRecordStream();
    }
  }

  initPropertyRecordStream() {
    //TODO: model from UI = bad
    var query = "name = ? AND item = ?";
    var binding = [Variable(property), Variable(item!.rowId)];
    propertyStream = AppController.shared.databaseController.databasePool
        .itemPropertyRecordsCustomSelectStream(query, binding);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext builder, snapshot) {
          return StreamBuilder(
              stream: propertyStream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return widget.nodeResolver.childrenInForEachWithWrap();
              });
        });
  }
}
