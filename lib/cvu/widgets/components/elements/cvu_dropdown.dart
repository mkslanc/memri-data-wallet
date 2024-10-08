import 'package:flutter/material.dart';
import 'package:memri/core/models/item.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/cvu/widgets/components/cvu_ui_node_resolver.dart';
import 'package:memri/widgets/empty.dart';

import '../../../services/resolving/cvu_property_resolver.dart';
import 'cvu_text_properties_modifier.dart';

/// A CVU element for displaying a dropdown list
/// - Use the `onPress` property to provide a CVU Action
class CVUDropdown extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUDropdown({required this.nodeResolver});

  @override
  _CVUDropdownState createState() => _CVUDropdownState();
}

class _CVUDropdownState extends State<CVUDropdown> {
  TextProperties? resolvedTextProperties;
  ButtonStyle? style;
  List<Item> items = [];
  Item? selectedItem;

  @override
  initState() {
    super.initState();
    init();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() => init());
  }

  onChange(BuildContext buildContext) async {
    var actions = widget.nodeResolver.propertyResolver.actions("onChange");
    if (actions == null) {
      return;
    }
    for (var action in actions) {
      await action
          .execute(widget.nodeResolver.context.replacingItem(selectedItem!), buildContext);
    }
  }

  void init() {
    resolvedTextProperties = CVUTextPropertiesModifier(
            propertyResolver: widget.nodeResolver.propertyResolver)
        .init();
    style = widget.nodeResolver.propertyResolver
        .style<ButtonStyle>(type: StyleType.button);
    items = widget.nodeResolver.propertyResolver.items("list");

    var edgeName = widget.nodeResolver.propertyResolver.string("edgeName");
    if (edgeName != null) {
      selectedItem =
          (widget.nodeResolver.propertyResolver.edge("item", edgeName));
    }

    selectedItem ??= items.asMap()[0];
  }

  @override
  Widget build(BuildContext context) {
    if (items.isNotEmpty) {
      return DropdownButtonFormField(
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.fromLTRB(10, 11, 10, 11),
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xffF0F0F0)),
                borderRadius: BorderRadius.all(Radius.circular(2.0))),
          ),
          value: selectedItem,
          icon: app.icons.arrowDown(),
          iconSize: 40,
          onChanged: (Item? newValue) {
            setState(() {
              selectedItem = newValue;
              onChange(context);
            });
          },
          items: items
              .map((e) => DropdownMenuItem(
                  value: e,
                  child: widget.nodeResolver
                      .childrenInForEachWithWrap(usingItem: e)))
              .toList());
    }
    return Empty();
  }
}
