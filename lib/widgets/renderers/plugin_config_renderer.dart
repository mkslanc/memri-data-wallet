import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/core/controllers/view_context_controller.dart';
import 'package:memri/core/cvu/cvu_action.dart';
import 'package:memri/core/cvu/resolving/cvu_context.dart';
import 'package:memri/core/models/database/item_record.dart';
import 'package:memri/core/models/plugin_config_json.dart';
import 'package:memri/core/services/database/property_database_value.dart';
import 'package:memri/utilities/binding.dart';
import 'package:memri/widgets/components/text_field/memri_text_field.dart';
import 'package:memri/widgets/empty.dart';
import 'package:memri/widgets/renderers/renderer.dart';
import 'package:memri/widgets/space.dart';

/// The plugin config renderer
/// specific renderer to change plugin config
/// may be deleted after implemented via cvu
class PluginConfigRendererView extends Renderer {
  PluginConfigRendererView(
      {required pageController, required ViewContextController viewContext})
      : super(pageController: pageController, viewContext: viewContext);

  @override
  _PluginConfigRendererViewState createState() =>
      _PluginConfigRendererViewState();
}

class _PluginConfigRendererViewState extends RendererViewState {
  late Future _init;
  late EdgeInsets insets;
  late ItemRecord plugin;
  late List<PluginConfigJson> configJsonList;
  late Map<String, dynamic> configData;

  @override
  void initState() {
    super.initState();
    _init = init();
  }

  Future init() async {
    insets = await viewContext.rendererDefinitionPropertyResolver.edgeInsets ??
        EdgeInsets.fromLTRB(30, 30, 30, 0);
    plugin = viewContext.focusedItem!;
    var configString = (await plugin.property("configJson"))!.$value.value;
    var configDataString = (await plugin.property("config"))?.$value.value;
    configJsonList = (jsonDecode(configString) as List)
        .map((json) => PluginConfigJson.fromJson(json))
        .toList();
    configData = configDataString != null
        ? jsonDecode(configDataString) as Map<String, dynamic>
        : <String, dynamic>{};
  }

  setConfigValue(name, value) {
    configData[name] = value;
  }

  Future<void> saveConfigValue() async {
    await plugin.setPropertyValue(
        "config", PropertyDatabaseValueString(jsonEncode(configData)));
  }

  Widget get configWidget => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: space(
            2,
            configJsonList
                .map((configJson) => getConfigWidget(configJson))
                .toList()
              ..add(Row(
                children: [
                  TextButton(
                    style: primaryButtonStyle,
                    onPressed: () async {
                      await saveConfigValue();
                      await CVUActionNavigateBack()
                          .execute(pageController, CVUContext());
                    },
                    child: Text("Save"),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: () async {
                      await CVUActionNavigateBack()
                          .execute(pageController, CVUContext());
                    },
                    child: Text("Cancel"),
                  ),
                ],
              )),
            Axis.vertical),
      );

  Widget getConfigWidget(PluginConfigJson configJson) {
    configData[configJson.name] ??= configJson.defaultData;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 500),
      child: Row(children: [
        Text(configJson.display + ": "),
        Spacer(),
        () {
          switch (configJson.dataType.toLowerCase()) {
            case "bool":
              var currentValue = configData[configJson.name] ?? false;
              return Switch(
                  value: currentValue,
                  onChanged: (newValue) {
                    setState(() => setConfigValue(configJson.name, newValue));
                  });
            //TODO all types
            default:
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 350),
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xFFF0F0F0),
                      border: Border.all(color: Color(0xff00000), width: 1)),
                  child: MemriTextField.sync(
                      binding: Binding<String>(
                          () => configData[configJson.name],
                          (newValue) =>
                              setConfigValue(configJson.name, newValue))),
                ),
              );
          }
        }()
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.done
                ? Padding(
                    padding: insets,
                    child: configWidget,
                  )
                : Empty());
  }
}
