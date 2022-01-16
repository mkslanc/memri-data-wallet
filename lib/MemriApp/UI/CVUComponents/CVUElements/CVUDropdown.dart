import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUPropertyResolver.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import '../CVUUINodeResolver.dart';
import 'CVUTextPropertiesModifier.dart';

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
  List<ItemRecord> items = [];
  ItemRecord? selectedItem;

  late Future _init;

  @override
  initState() {
    super.initState();
    _init = init();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init = init();
  }

  onChange() async {
    var actions = widget.nodeResolver.propertyResolver.actions("onChange");
    if (actions == null) {
      return;
    }
    for (var action in actions) {
      await action.execute(widget.nodeResolver.pageController,
          widget.nodeResolver.context.replacingItem(selectedItem!));
    }
  }

  init() async {
    resolvedTextProperties =
        await CVUTextPropertiesModifier(nodeResolver: widget.nodeResolver).init();
    style = await widget.nodeResolver.propertyResolver.style<ButtonStyle>(type: StyleType.button);
    items = await widget.nodeResolver.propertyResolver.items("list");

    var edgeName = await widget.nodeResolver.propertyResolver.string("edgeName");
    if (edgeName != null) {
      selectedItem = (await widget.nodeResolver.propertyResolver.edge("item", edgeName));
    }

    selectedItem ??= items.asMap()[0];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext builder, snapshot) {
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
                icon: SvgPicture.asset("images/ico_arrow_down.svg"),
                iconSize: 40,
                onChanged: (ItemRecord? newValue) {
                  setState(() {
                    selectedItem = newValue;
                    onChange();
                  });
                },
                items: items
                    .map((e) => DropdownMenuItem(
                        value: e,
                        child: widget.nodeResolver.childrenInForEachWithWrap(usingItem: e)))
                    .toList());
          }
          return Empty();
        });
  }
}
