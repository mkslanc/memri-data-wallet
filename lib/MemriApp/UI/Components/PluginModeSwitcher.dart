import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemPropertyRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/Database/PropertyDatabaseValue.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

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
        future: widget.item.property("container"),
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
                              RegExp(r"(:)dev(-.+$)"), (Match m) => "${m[1]}prod${m[2]}");
                        } else {
                          newContainer = currentContainer.replaceFirstMapped(
                              RegExp(r"(:)prod(-.+$)"), (Match m) => "${m[1]}dev${m[2]}");
                        }
                        await widget.item.setPropertyValue(
                            "container", PropertyDatabaseValueString(newContainer));
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
