import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUViewArguments.dart';
import 'package:memri/MemriApp/Controllers/AppController.dart';
import 'package:memri/MemriApp/Controllers/Database/DatabaseQuery.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/Collection.dart';
import 'package:memri/MemriApp/UI/SceneContentView.dart';
import 'package:memri/MemriApp/UI/ViewContext.dart';
import 'package:uuid/uuid.dart';
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
  late List<ItemRecord>? items;
  late Future _init;
  bool isInited = false;
  Key? key; //used for updating on cvu change from cvuEditor

  CVUDefinitionContent? _viewDefinition;
  String? _id;

  ViewContextController? _viewContext;

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

  Future init() async {
    var viewDefinition = widget.nodeResolver.propertyResolver.value("view")?.getSubdefinition();
    if (viewDefinition == null) {
      _viewContext = null;
      return;
    }

    var id = await widget.nodeResolver.propertyResolver.string("id");
    if (id == _id && _viewDefinition == viewDefinition) {
      return;
    }
    key = Key(Uuid().v4());

    if (_id != null) {
      widget.nodeResolver.context.viewArguments?.subViewArguments.remove(_id!);
    }

    _viewDefinition = viewDefinition;
    _id = id;

    String? rendererName;
    var defaultRenderer = viewDefinition.properties["defaultRenderer"];
    if (defaultRenderer is CVUValueConstant && defaultRenderer.value is CVUConstantArgument) {
      rendererName = (defaultRenderer.value as CVUConstantArgument).value;
    }

    if (rendererName == null) {
      return null;
    }

    String? viewName;
    var viewNameProp = viewDefinition.properties["viewName"];
    if (viewNameProp is CVUValueConstant && viewNameProp.value is CVUConstantArgument) {
      viewName = (viewNameProp.value as CVUConstantArgument).value;
    }

    var datasource = viewDefinition.definitions
        .firstWhereOrNull((element) => element.type == CVUDefinitionType.datasource);

    ItemRecord? initialItem = await widget.nodeResolver.propertyResolver.item("initialItem");
    items = await widget.nodeResolver.propertyResolver.items("query");

    var viewArgs = viewDefinition.properties["viewArguments"];
    var viewArguments = CVUViewArguments(
        args: viewArgs?.value.properties,
        argumentItem: initialItem,
        argumentItems: items,
        parentArguments: widget.nodeResolver.context.viewArguments);

    if (_id != null) {
      widget.nodeResolver.context.viewArguments?.subViewArguments[id!] = viewArguments;
    }

    var newContext = CVUContext(
        currentItem: initialItem,
        items: items,
        selector: null,
        viewName: viewName,
        rendererName: rendererName,
        viewDefinition: viewDefinition,
        viewArguments: viewArguments);

    DatabaseQueryConfig queryConfig =
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
    _viewContext = ViewContextController(
        config: holder,
        databaseController: AppController.shared.databaseController,
        cvuController: AppController.shared.cvuController,
        pageController: widget.nodeResolver.pageController);
  }

  Widget get renderer {
    if (_viewContext != null) {
      return SceneContentView(
        key: key,
        viewContext: _viewContext!,
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
          isInited = isInited || snapshot.connectionState == ConnectionState.done;
          if (isInited) {
            return Flexible(child: renderer);
          }
          return Empty();
        });
  }
}
