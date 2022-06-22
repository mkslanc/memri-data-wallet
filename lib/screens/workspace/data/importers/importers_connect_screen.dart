import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/utils/app_helper.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';

import '../../../../constants/app_logger.dart';
import '../../../../controllers/app_controller.dart';
import '../../../../core/services/database/property_database_value.dart';
import '../../../../core/services/mixpanel_analytics_service.dart';
import '../../../../core/services/plugin_handler.dart';
import '../../../../models/database/item_property_record.dart';
import '../../../../models/database/item_record.dart';
import '../../../../widgets/components/html_view/html_view.dart';

class ImporterInfoLine extends StatelessWidget {
  const ImporterInfoLine({Key? key, required this.content}) : super(key: key);

  final String content;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            padding: new EdgeInsets.only(top: 12, bottom: 12, right: 12),
            child: SvgPicture.asset("assets/images/arrow-right-circle.svg")),
        Text(content, style: TextStyle(fontSize: 14)),
      ],
    );
  }
}

class ImportersConnectScreen extends StatelessWidget {
  const ImportersConnectScreen({Key? key}) : super(key: key);

  @override
  State<ImportersConnectScreen> createState() => _ImportersConnectScreenState();
}

class _ImportersConnectScreenState extends State<ImportersConnectScreen> {
  @override
  Widget build(BuildContext context) {
    return WorkspaceScaffold(
      currentItem: NavigationItem.data,
      child: Container(
          padding: new EdgeInsets.symmetric(vertical: 64, horizontal: 64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Step 2", style: TextStyle(fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  Text("On your phone", style: TextStyle(fontSize: 30)),
                ],
              ),
              ImporterInfoLine(content: "Open Whatsapp"),
              ImporterInfoLine(
                  content: "Tap settings and select linked devices"),
              ImporterInfoLine(content: "Tap link device"),
              ImporterInfoLine(
                  content:
                      "Point your phone to the QR code on the screen of your computer and capture the code"),
              Container(
                  height: 300,
                  width: 300,
                  child: HtmlView(src: "https://docs.memri.io", reload: true)),
            ],
          )),
    );
  }

  @override
  void initState() {
    super.initState();
    execute();
  }

  @override
  void dispose() {
    pluginRunItemStreamSubscription.cancel();
    super.dispose();
  }

  String? url = null;
  String? status = null;
  bool authenticated = false;
  late StreamSubscription<Item> pluginRunItemStreamSubscription;
  late Stream<Item> pluginRunItemStream;

  void execute() async {
    var db = AppController.shared.databaseController;

    // TODO, what are we doing with things from the default database?

    try {
      // TODO UID generator
      String id = Uuid().v4();

      Item item = Item(type: "PluginRun", id: id, properties: {
        "pluginName": "WhatsappPlugin",
        "pluginModule": "whatsapp.plugin",
        "containerImage":
            "gitlab.memri.io:5050/memri/plugins/whatsapp-multi-device:dev-latest",
        "status": "idle",
        "targetItemId": id
      });
      MixpanelAnalyticsService().logImporterConnect("WhatsappPlugin");

      List<Item> createItems = [item];
      var bulkPayload = PodPayloadBulkAction(
          createItems: createItems.map((e) => e.toJson()).toList(),
          updateItems: [],
          deleteItems: [],
          createEdges: []);

      Stream<Item> itemStream(String id) async* {
        while (true) {
          await Future.delayed(Duration(seconds: 1));
          Item? res = null;
          await AppController.shared.podApi.getItem(
              id: id,
              completion: (data, error) {
                var pluginrunItem = data;
                if (pluginrunItem != null) {
                  res = pluginrunItem;
                }
              });
          if (res != null) {
            yield res!;
          }
        }
      }

      pluginRunItemStream = itemStream(id);

      AppController.shared.podApi.bulkAction(
          bulkPayload: bulkPayload,
          completion: ((error) async {
            pluginRunItemStreamSubscription = pluginRunItemStream.listen((item) {
              var _status = item.get("status");
              authenticated = _status == "daemon";
              if (authenticated){
                RouteNavigator.navigateToRoute(
                    context: context, route: Routes.importerDownloading, param: {"id": id});
              }
              else{
                setState(() {
                  url = item.get("authUrl");
                  status = _status;
                  print(url);
                  print(status);
                });
              }
            });
          }));


    } catch (error) {
      AppLogger.err("Error starting plugin: $error");
    }
  }

  void execute() async {
    // var lookup = CVULookupController();
    // var db = pageController.appController.databaseController;
    var db = AppController.shared.databaseController;

    // TODO, what are we doing with things from the default database?
    var pluginIdValue = 20004000000;
    var pluginModuleValue = "whatsapp.plugin";
    var pluginNameValue = "WhatsappPlugin";
    var containerValue = "gitlab.memri.io:5050/memri/plugins/whatsapp-multi-device:dev-latest";
    // if (pluginIdValue == null ||
    //     containerValue == null ||
    //     pluginModuleValue == null ||
    //     pluginNameValue == null) {
    //   AppLogger.warn("Not all params provided for PluginRun");
    //   return;
    // }
    // var configValue = vars["config"];

    // String? pluginId = await lookup.resolve<String>(value: pluginIdValue, context: context, db: db);

    // String? container =
    //     await lookup.resolve<String>(value: containerValue, context: context, db: db);
    // if (container == null) return;

    // TODO, make more robust
    ItemRecord plugin = (await ItemRecord.fetchWithUID("20004", db))!;

    // String? pluginModule =
    //     await lookup.resolve<String>(value: pluginModuleValue, context: context, db: db) ?? "";
    // String? pluginName =
    //     await lookup.resolve<String>(value: pluginNameValue, context: context, db: db) ?? "";
    // String? config;
    // if (configValue != null) {
    //   config = await lookup.resolve<String>(value: configValue, context: context, db: db) ?? "";
    // }
    try {
      var pluginRunItem = ItemRecord(type: "PluginRun");
      var propertyRecords = [
        ItemPropertyRecord(
            name: "targetItemId", value: PropertyDatabaseValueString(pluginRunItem.uid)),
        ItemPropertyRecord(name: "pluginModule", value: PropertyDatabaseValueString(pluginModuleValue)),
        ItemPropertyRecord(name: "pluginName", value: PropertyDatabaseValueString(pluginNameValue)),
        ItemPropertyRecord(name: "containerImage", value: PropertyDatabaseValueString(containerValue)),
        ItemPropertyRecord(name: "status", value: PropertyDatabaseValueString("idle")),
      ];

      // if (config != null) {
      //   propertyRecords
      //       .add(ItemPropertyRecord(name: "config", value: PropertyDatabaseValueString(config)));
      // }

      await pluginRunItem.save();
      await pluginRunItem.addEdge(edgeName: "plugin", targetItem: plugin);
      await pluginRunItem.setPropertyValueList(propertyRecords, db: db);

    //   MixpanelAnalyticsService().logImporterConnect(pluginNameValue);
    //   // TODO: fix handling updated plugin
    //   await PluginHandler.run(
    //       plugin: plugin, runner: pluginRunItem, context: context);
    } catch (error) {
      AppLogger.err("Error starting plugin: $error");
    }
  }
}
