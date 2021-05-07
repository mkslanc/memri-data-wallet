import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUUIElementFamily.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/UI/CVUComponents/CVUElementView.dart';

import '../CVUUINodeResolver.dart';

/// A CVU element for displaying a child for each item in an array
/// - use this inside a HStack or VStack
/// - set the `items` property to an expression resolving to a list of items
/// - any child elements will be repeated for each item. The `.` in any expressions will resolve to each particular item being shown within the ForEach
class CVUForEach extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;

  CVUForEach({required this.nodeResolver, required this.getWidget});

  final Widget Function(List<Widget> children) getWidget;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: nodeResolver.propertyResolver.items("items"),
        builder: (BuildContext builder, AsyncSnapshot<List<ItemRecord>> snapshot) {
          if (snapshot.hasData) {
            var items = snapshot.requireData;
            if (items.isNotEmpty) {
              return getWidget(items
                  .map((item) {
                    var context = nodeResolver.context.replacingItem(item);
                    return nodeResolver.node.children
                        .map((child) => CVUElementView(
                            nodeResolver: CVUUINodeResolver(
                                context: context,
                                lookup: nodeResolver.lookup,
                                node: child,
                                db: nodeResolver.db)))
                        .toList();
                  })
                  .expand((element) => element)
                  .toList());
            }
          }
          return SizedBox.shrink();
        });
  }
}

abstract class StackWidget {
  late final CVUUINodeResolver? nodeResolver;

  Widget initWidget() {
    if (nodeResolver!.node.children[0].type == CVUUIElementFamily.ForEach) {
      return nodeResolver!.childrenInForEach(additionalParams: {"getWidget": getWidget})[0];
    } else {
      return getWidget(nodeResolver!.childrenInForEach());
    }
  }

  Widget getWidget(List<Widget> children);
}
