import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import '../ViewContextController.dart';

/// The list renderer
/// This presents the data in a list (aka tableView)
class ListRendererView extends StatefulWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  ListRendererView({required this.sceneController, required this.viewContext});

  @override
  _ListRendererViewState createState() => _ListRendererViewState(sceneController, viewContext);
}

class _ListRendererViewState extends State<ListRendererView> {
  final SceneController sceneController;
  final ViewContextController viewContext;

  _ListRendererViewState(this.sceneController, this.viewContext);

  late EdgeInsets insets;
  late Point spacing;
  late String backgroundColor;
  late bool separatorsEnabled;

  Future<bool> init() async {
    insets = await viewContext.rendererDefinitionPropertyResolver.edgeInsets ??
        EdgeInsets.only(top: 10, left: 10, bottom: 10, right: 10);
    spacing = await viewContext.rendererDefinitionPropertyResolver.spacing ?? Point(10, 10);
    backgroundColor = await viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
        "systemBackground"; //TODO CVUColor.system(.systemBackground);
    separatorsEnabled =
        !(await viewContext.rendererDefinitionPropertyResolver.boolean("hideSeparators", false))!;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: init(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                if (viewContext.hasItems) {
                  return Text("Has items");
                } else {
                  return Text("No items");
                }
              default:
                return SizedBox(
                  child: CircularProgressIndicator(),
                  width: 60,
                  height: 60,
                );
            }
          }),
    );
  }
}
