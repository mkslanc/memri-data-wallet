import 'package:flutter/material.dart';
import 'package:memri/core/models/database/item_property_record.dart';
import 'package:memri/core/models/database/item_record.dart';
import 'package:memri/core/services/database/property_database_value.dart';
import 'package:memri/widgets/empty.dart';

class PluginModeSwitcher extends StatefulWidget {
  final ItemRecord item;

  PluginModeSwitcher(this.item);

  @override
  _PluginModeSwitcherState createState() => _PluginModeSwitcherState();
}

class _PluginModeSwitcherState extends State<PluginModeSwitcher> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ItemPropertyRecord?>(
        future: widget.item.property("containerImage"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var currentContainer = snapshot.data!.$value.asString()!;
            var isDev = currentContainer.contains(RegExp(r":dev-.+$"));

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Dev"),
                  Switch(
                      value: !isDev,
                      onChanged: (bool newValue) async {
                        var newContainer;
                        if (newValue) {
                          newContainer = currentContainer.replaceFirstMapped(
                              RegExp(r"(:)dev(-.+$)"),
                              (Match m) => "${m[1]}prod${m[2]}");
                        } else {
                          newContainer = currentContainer.replaceFirstMapped(
                              RegExp(r"(:)prod(-.+$)"),
                              (Match m) => "${m[1]}dev${m[2]}");
                        }
                        await widget.item.setPropertyValue("containerImage",
                            PropertyDatabaseValueString(newContainer));
                        setState(() {});
                      }),
                  Text("Prod"),
                ],
              ),
            );
          } else {
            return Empty();
          }
        });
  }
}
