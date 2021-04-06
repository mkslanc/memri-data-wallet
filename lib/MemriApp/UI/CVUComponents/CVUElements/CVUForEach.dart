import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/UI/CVUComponents/CVUElementView.dart';

import '../CVUUINodeResolver.dart';

/// A CVU element for displaying a child for each item in an array
/// - use this inside a HStack or VStack
/// - set the `items` property to an expression resolving to a list of items
/// - any child elements will be repeated for each item. The `.` in any expressions will resolve to each particular item being shown within the ForEach
class CVUForEach extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;

  CVUForEach({required this.nodeResolver});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: nodeResolver.propertyResolver.items("items"),
        builder: (BuildContext builder, AsyncSnapshot<List<ItemRecord>> snapshot) {
          if (snapshot.hasData) {
            var items = snapshot.requireData;
            if (items.isNotEmpty) {
              return Wrap(
                children: items.map((item) {
                  var context = nodeResolver.context.replacingItem(item);
                  return Wrap(
                    children: nodeResolver.node.children
                        .map((child) => CVUElementView(
                            nodeResolver: CVUUINodeResolver(
                                context: context,
                                lookup: nodeResolver.lookup,
                                node: child,
                                db: nodeResolver.db)))
                        .toList(),
                  );
                }).toList(),
              );
            }
          }
          return SizedBox.shrink();
        });
  }
}
