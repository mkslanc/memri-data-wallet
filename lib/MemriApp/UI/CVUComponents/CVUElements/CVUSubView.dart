import 'dart:math';

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUViewArguments.dart';
import 'package:memri/MemriApp/Controllers/AppController.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseQuery.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
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
    String? rendererName;
    if (defaultRenderer is CVUValueConstant && defaultRenderer.value is CVUConstantArgument) {
      rendererName = (defaultRenderer.value as CVUConstantArgument).value;
    }

    var viewNameProp = viewDefinition.properties["viewName"];
    String? viewName;
    if (viewNameProp is CVUValueConstant && viewNameProp.value is CVUConstantArgument) {
      viewName = (viewNameProp.value as CVUConstantArgument).value;
    }

    if (rendererName == null) {
      return null;
    }

    var datasource = viewDefinition.definitions
        .firstWhereOrNull((element) => element.type == CVUDefinitionType.datasource);

    ItemRecord? initialItem = await widget.nodeResolver.propertyResolver.item("initialItem");
    List<ItemRecord> initialItems =
        await widget.nodeResolver.propertyResolver.items("initialItems");

    var viewArgs = viewDefinition.properties["viewArguments"];
    var viewArguments = CVUViewArguments(
        args: viewArgs?.value.properties,
        argumentItem: initialItem,
        argumentItems: initialItems,
        parentArguments: widget.nodeResolver.context.viewArguments);

    var newContext = CVUContext(
        currentItem: initialItem,
        items: initialItems,
        selector: null,
        viewName: viewName,
        rendererName: rendererName,
        viewDefinition: viewDefinition,
        viewArguments: viewArguments);

    var queryConfig =
        await DatabaseQueryConfig.queryConfigWith(context: newContext, datasource: datasource);

    var config = ViewContext(
        viewName: viewName,
        pageLabel: widget.nodeResolver.pageController.label,
        rendererName: rendererName,
        viewDefinition: viewDefinition,
        viewArguments: viewArguments,
        focusedItem: initialItem,
        query: queryConfig);
    var holder = ViewContextHolder(config);
    var viewControllerContext = ViewContextController(
        config: holder,
        databaseController: AppController.shared.databaseController,
        cvuController: AppController.shared.cvuController,
        pageController: widget.nodeResolver.pageController);
    var id = await widget.nodeResolver.propertyResolver.string("id");
    if (id != null) {
      widget.nodeResolver.context.viewArguments?.subViewArguments[id] = viewArguments;
    }
    return viewControllerContext;
  }

  Future<Widget> get _renderer async {
    var context = await viewContext;
    if (context != null) {
      return SceneContentView(
        viewContext: context,
        pageController: widget.nodeResolver.pageController,
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
            return Flexible(child: renderer);
          }
          return Empty();
        });
  }
}
