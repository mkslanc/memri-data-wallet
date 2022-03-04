import 'package:flutter/material.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/controllers/database_query.dart';
import 'package:memri/controllers/view_context_controller.dart';
import 'package:memri/core/cvu/resolving/cvu_context.dart';
import 'package:memri/models/cvu/cvu_parsed_definition.dart';
import 'package:memri/models/cvu/cvu_value.dart';
import 'package:memri/models/cvu/cvu_value_constant.dart';
import 'package:memri/models/cvu/cvu_view_arguments.dart';
import 'package:memri/models/database/item_record.dart';
import 'package:memri/models/view_context.dart';
import 'package:memri/utils/extensions/collection.dart';
import 'package:memri/widgets/components/cvu/cvu_ui_node_resolver.dart';
import 'package:memri/widgets/empty.dart';
import 'package:memri/widgets/scene_content_view.dart';
import 'package:uuid/uuid.dart';

class CVUSubView extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUSubView({required this.nodeResolver});

  @override
  _CVUSubViewState createState() => _CVUSubViewState();
}

class _CVUSubViewState extends State<CVUSubView> {
  late Future _init;
  bool isInited = false;
  Key? key; //used for updating on cvu change from cvuEditor

  CVUDefinitionContent? _viewDefinition;
  String? _id;

  CVUViewArguments? viewArguments;
  DatabaseQueryConfig? queryConfig;

  late ValueNotifier<ViewContextController?> viewContextValue;

  ViewContextController? get _viewContext => viewContextValue.value;
  set _viewContext(ViewContextController? viewContext) {
    _viewContext?.removeListener(viewContextUpdate);
    viewContextValue.value = viewContext;
    _viewContext?.addListener(viewContextUpdate);
  }

  viewContextUpdate() {
    if (!mounted) return; //TODO check why this happening
    setState(() {
      viewArguments?.argumentItems = _viewContext?.items;
    });
  }

  @override
  dispose() {
    _viewContext?.removeListener(viewContextUpdate);
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    viewContextValue = ValueNotifier(null);
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
      _viewContext?.setupQueryObservation();
      _viewContext = _viewContext;
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
    var items = await widget.nodeResolver.propertyResolver.items("query");

    var viewArgs = viewDefinition.properties["viewArguments"];
    viewArguments = CVUViewArguments(
        args: viewArgs?.value.properties,
        argumentItem: initialItem,
        argumentItems: items,
        parentArguments: widget.nodeResolver.context.viewArguments);

    if (_id != null) {
      widget.nodeResolver.context.viewArguments?.subViewArguments[id!] = viewArguments!;
    }

    var newContext = CVUContext(
        currentItem: initialItem,
        items: items,
        selector: null,
        viewName: viewName,
        rendererName: rendererName,
        viewDefinition: viewDefinition,
        viewArguments: viewArguments);

    queryConfig = await DatabaseQueryConfig.queryConfigWith(
        context: newContext,
        datasource: datasource,
        databaseController: AppController.shared.databaseController);

    var config = ViewContext(
        viewName: viewName,
        pageLabel: widget.nodeResolver.pageController.label,
        rendererName: rendererName,
        viewDefinition: viewDefinition,
        viewArguments: viewArguments,
        focusedItem: initialItem,
        query: queryConfig!);

    var holder = ViewContextHolder(config);
    _viewContext = ViewContextController(
        config: holder,
        databaseController: AppController.shared.databaseController,
        cvuController: AppController.shared.cvuController,
        pageController: widget.nodeResolver.pageController);
  }

  Widget get renderer => ValueListenableBuilder(
        valueListenable: viewContextValue,
        builder: (BuildContext context, ViewContextController? value, Widget? child) {
          if (value != null) {
            return SceneContentView(
              key: key,
              viewContext: value,
              pageController: widget.nodeResolver.pageController,
            );
          } else {
            print("No renderer selected"); //TODO
            return Empty();
          }
        },
      );

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
