import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';

import '../ViewContextController.dart';

class SingleItemRendererView extends StatefulWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;

  SingleItemRendererView({required this.sceneController, required this.viewContext});

  @override
  _SingleItemRendererViewState createState() => _SingleItemRendererViewState();
}

class _SingleItemRendererViewState extends State<SingleItemRendererView> {
  late final EdgeInsets insets;

  late final Color backgroundColor;

  late final Future _init;

  @override
  initState() {
    super.initState();
    _init = init();
    widget.sceneController.addListener(updateState);
  }

  @override
  dispose() {
    super.dispose();
    widget.sceneController.removeListener(updateState);
  }

  updateState() {
    setState(() {});
  }

  Future init() async {
    insets =
        await widget.viewContext.rendererDefinitionPropertyResolver.edgeInsets ?? EdgeInsets.zero;
    backgroundColor = await widget.viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
        CVUColor.system("systemBackground");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return ValueListenableBuilder(
                  valueListenable: widget.viewContext.itemsValueNotifier,
                  builder: (BuildContext context, List<ItemRecord> value, Widget? child) {
                    var item =
                        widget.viewContext.focusedItem ?? widget.viewContext.items.asMap()[0];
                    if (item != null) {
                      return Expanded(
                          child: ColoredBox(
                        color: backgroundColor,
                        child: Padding(
                          padding: insets,
                          child: widget.viewContext.render(item: item),
                        ),
                      ));
                    } else {
                      return Expanded(
                          child: ColoredBox(
                        color: backgroundColor,
                        child: Padding(
                          padding: insets,
                          child: Center(
                            child: Text("No item selected"),
                          ),
                        ),
                      ));
                    }
                  });
            default:
              return SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              );
          }
        });
  }
}
