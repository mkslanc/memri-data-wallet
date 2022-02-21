import 'package:flutter/material.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/models/database/item_record.dart';
import 'package:memri/widgets/components/cvu/cvu_ui_node_resolver.dart';
import 'package:memri/widgets/components/cvu/elements/cvu_text_properties_modifier.dart';
import 'package:moor/moor.dart';

class CVUObserver extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUObserver({required this.nodeResolver});

  @override
  _CVUObserverState createState() => _CVUObserverState();
}

class _CVUObserverState extends State<CVUObserver> {
  late TextProperties resolvedTextProperties;

  late ItemRecord? item;
  late String? itemType;
  late String? property;
  Stream<List<dynamic>>? stream;

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
    itemType = await widget.nodeResolver.propertyResolver.string("itemType");
    if (itemType != null || (property != null && item != null)) {
      initPropertyRecordStream();
    }
  }

  initPropertyRecordStream() {
    //TODO: model from UI = bad
    var query = "";
    var binding = <Variable<dynamic>>[Variable(property)];
    if (itemType != null) {
      stream = AppController.shared.databaseController.databasePool
          .itemRecordsFetchByTypeStream(itemType!);
    } else {
      query = "name = ? AND item = ?";
      binding = [Variable(property), Variable(item!.rowId)];
      stream = AppController.shared.databaseController.databasePool
          .itemPropertyRecordsCustomSelectStream(query, binding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext builder, snapshot) {
          return StreamBuilder(
              stream: stream,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return widget.nodeResolver.childrenInForEachWithWrap();
              });
        });
  }
}
