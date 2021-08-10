import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/Controllers/AppController.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseQuery.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';
import 'package:memri/MemriApp/UI/SceneContentView.dart';
import 'package:memri/MemriApp/UI/ViewContext.dart';
import '../../ViewContextController.dart';
import '../CVUUINodeResolver.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

class CVUSubView extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUSubView({required this.nodeResolver});

  @override
  _CVUSubViewState createState() => _CVUSubViewState();
}

class _CVUSubViewState extends State<CVUSubView> {
  late Point spacing;
  late List<ItemRecord>? items;
  late String? content;
  late String? title;
  late Future _init;
  late Widget renderer;

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
    items = await widget.nodeResolver.propertyResolver.items("query");
    content = await _content;
    title = await _title;
    renderer = await _renderer;
    spacing = await widget.nodeResolver.propertyResolver.spacing ?? Point(0, 0);
  }

  Future<String?> get _content async {
    return (await widget.nodeResolver.propertyResolver.string("text"))?.nullIfBlank;
  }

  Future<String?> get _title async {
    return (await widget.nodeResolver.propertyResolver.string("title"))?.nullIfBlank;
  }

  get viewContext async {
    var viewDefinition = widget.nodeResolver.propertyResolver.value("view")?.getSubdefinition();
    if (viewDefinition == null) {
      return null;
    }
    var defaultRenderer = viewDefinition.properties["defaultRenderer"];
    if (defaultRenderer == null || defaultRenderer is! CVUValueConstant) {
      return null;
    }
    if (defaultRenderer.value is! CVUConstantArgument) {
      return null;
    }
    String rendererName = (defaultRenderer.value as CVUConstantArgument).value;
    var viewNameProp = viewDefinition.properties["viewName"];
    if (viewNameProp == null || viewNameProp is! CVUValueConstant) {
      return null;
    }
    if (viewNameProp.value is! CVUConstantArgument) {
      return null;
    }
    String viewName = (viewNameProp.value as CVUConstantArgument).value;
    var datasource = viewDefinition.definitions
        .firstWhereOrNull((element) => element.type == CVUDefinitionType.datasource);
    if (datasource == null) {
      return null;
    }
    ItemRecord? initialItem = await widget.nodeResolver.propertyResolver.item("initialItem");
    var nodeItem = initialItem ?? widget.nodeResolver.context.currentItem;

    var newContext = CVUContext(
        currentItem: nodeItem, selector: null, viewName: viewName, viewDefinition: viewDefinition);

    var queryConfig =
        await DatabaseQueryConfig.queryConfigWith(context: newContext, datasource: datasource);

    var config = ViewContext(
        viewName: viewName,
        rendererName: rendererName,
        viewDefinition: viewDefinition,
        query: queryConfig);
    var holder = ViewContextHolder(config);
    var viewControllerContext = ViewContextController(
        config: holder,
        databaseController: AppController.shared.databaseController,
        cvuController: AppController.shared.cvuController);

    return viewControllerContext;
  }

  Future<Widget> get _renderer async {
    var context = await viewContext;
    if (context != null) {
      return SceneContentView(
        viewContext: context,
        sceneController: SceneController.sceneController,
      );
    } else {
      return Center(
          child: Text(
        "No renderer selected",
        style: TextStyle(fontWeight: FontWeight.bold),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Expanded(
              child: Column(
                children: [
                  if (title != null)
                    Column(
                      children: space(10, [
                        Text(
                          title!,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        )
                      ]),
                    ),
                  Expanded(child: renderer)
                ],
              ),
            );
          }
          return Empty();
        });
  }
}
