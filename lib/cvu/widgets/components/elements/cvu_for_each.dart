import 'package:flutter/material.dart';
import 'package:memri/core/models/item.dart';
import 'package:memri/cvu/models/cvu_ui_element_family.dart';
import 'package:memri/cvu/widgets/components/cvu_element_view.dart';
import 'package:memri/cvu/widgets/components/cvu_ui_node_resolver.dart';
import 'package:memri/widgets/empty.dart';

/// A CVU element for displaying a child for each item in an array
/// - use this inside a HStack or VStack
/// - set the `items` property to an expression resolving to a list of items
/// - any child elements will be repeated for each item. The `.` in any expressions will resolve to each particular item being shown within the ForEach
class CVUForEach extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUForEach({required this.nodeResolver, required this.getWidget});

  final Widget Function(List<Widget> children) getWidget;

  @override
  _CVUForEachState createState() => _CVUForEachState();
}

class _CVUForEachState extends State<CVUForEach> {
  late List<Item> items;

  @override
  initState() {
    super.initState();
    items = widget.nodeResolver.propertyResolver.items("items");
  }

  @override
  Widget build(BuildContext context) {
    if (items.isNotEmpty) {
      return widget.getWidget(items
          .map((item) {
            var context = widget.nodeResolver.context.replacingItem(item);
            return widget.nodeResolver.node.children
                .map((child) => CVUElementView(
                        nodeResolver: CVUUINodeResolver(
                      context: context,
                      lookup: widget.nodeResolver.lookup,
                      node: child,
                    )))
                .toList();
          })
          .expand((element) => element)
          .toList());
    }
    return Empty();
  }
}

mixin StackWidget {
  late final CVUUINodeResolver? nodeResolver;

  Widget initWidget() {
    if (nodeResolver!.node.children[0].type == CVUUIElementFamily.ForEach) {
      return nodeResolver!
          .childrenInForEach(additionalParams: {"getWidget": getWidget})[0];
    } else {
      return getWidget(nodeResolver!.childrenInForEach());
    }
  }

  Widget getWidget(List<Widget> children);
}
