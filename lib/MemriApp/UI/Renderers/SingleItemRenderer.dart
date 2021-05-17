import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/Database/ItemRecord.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';

import '../ViewContextController.dart';

class SingleItemRendererView extends StatelessWidget {
  final SceneController sceneController;
  final ViewContextController viewContext;
  late final EdgeInsets insets;
  late final Color backgroundColor;

  SingleItemRendererView({required this.sceneController, required this.viewContext});

  Future<bool> init() async {
    insets = await viewContext.rendererDefinitionPropertyResolver.edgeInsets ?? EdgeInsets.zero;
    backgroundColor = await viewContext.rendererDefinitionPropertyResolver.backgroundColor ??
        CVUColor.system("systemBackground");
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return ValueListenableBuilder(
                  valueListenable: viewContext.itemsValueNotifier,
                  builder: (BuildContext context, List<ItemRecord> value, Widget? child) {
                    var item = viewContext.focusedItem;
                    if (item != null) {
                      return Expanded(
                          child: ColoredBox(
                        color: backgroundColor,
                        child: Padding(
                          padding: insets,
                          child: viewContext.render(item: item),
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
