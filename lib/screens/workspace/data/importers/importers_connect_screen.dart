import 'dart:convert';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memri/core/apis/pod/pod_payloads.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';

import '../../../../constants/app_logger.dart';
import '../../../../controllers/app_controller.dart';
import '../../../../core/apis/pod/item.dart';
import '../../../../core/services/mixpanel_analytics_service.dart';
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

class ImportersConnectScreen extends StatefulWidget {
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
                  child:
                  (() {
                    if (status == "idle" && url == null){
                      return CircularProgressIndicator();
                    }
                    else if (status=="userActionNeeded" || status=="daemon"){
                      return Column(
                        children: [
                          Container(
                            height: 300,
                            width: 300,
                            child: HtmlView(src: url, reload: true)
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () =>
                                    RouteNavigator.navigateToRoute(context: context, route: Routes.importerDownloading),
                                style: primaryButtonStyle,
                                child: Text("Create a new project"),
                              ),
                              TextButton(
                                onPressed: () =>
                                    RouteNavigator.navigateToRoute(context: context, route: Routes.data),
                                style: primaryButtonStyle,
                                child: Text("Back to data screen"),
                              ),
                            ],
                          )
                        ],
                      );
                    }
                    else if (status=="started"){
                      return Text("plugin already running");
                    }
                    else if (status=="error"){
                      return Text("Something went wrong");
                    }
                    }()) 
                  // url==null ? CircularProgressIndicator(): HtmlView(src: url, reload: true)),
                  )
            ],
          )),
    );
  }

  @override
  void initState() {
    super.initState();
    execute();
  }

  String? url = null;
  String? status = null;

  void execute() async {
    var db = AppController.shared.databaseController;

    // TODO, what are we doing with things from the default database?

    try {
      // TODO UID generator
      String id = Uuid().v4();

      Item item = Item(type: "PluginRun", id: id, properties: {
        "pluginName": "WhatsappPlugin",
        "pluginModule": "whatsapp.plugin",
        "containerImage": "gitlab.memri.io:5050/memri/plugins/whatsapp-multi-device:dev-latest",
        "status": "idle",
        "targetItemId": id}
       );
      MixpanelAnalyticsService().logImporterConnect("WhatsappPlugin");

      List<Item> createItems = [item];
      var bulkPayload = PodPayloadBulkAction(createItems: createItems.map((e) => e.toJson()).toList(), updateItems: [], deleteItems: [], createEdges: []);
      print("CALLING");


      Stream<Item> itemStream(String id) async* {
        while (true){
          await Future.delayed(Duration(seconds: 1));
          Item? res = null;
          await AppController.shared.podApi.getItem(id: id, completion: (data, error) {
              var pluginrunItem = data;
              if (pluginrunItem != null){
                res = pluginrunItem;
              }
          });
          if (res != null){
            yield res!;
          }
        }
      }

      Stream<Item> pluginRunItemStream = itemStream(id);


      AppController.shared.podApi.bulkAction(bulkPayload: bulkPayload, completion: ((error) async {
        pluginRunItemStream.listen((item) {
          print("Polling pluginrun");
          var _status = item.get("status");
          setState(() {
            print("setting state");
            url = item.get("authUrl");
            status = _status;
            print(url);
            print(status);
          });

        });
      }));

      // AppController.shared.podApi.bulkAction(bulkPayload: bulkPayload, completion: ((error) async {
      //   print("called bulkaction");
      //     String status ="idle";
      //     while (status=="idle"){
      //       AppController.shared.podApi.getItem(id: id, completion: (error, data) async {
      //         await Future.delayed(Duration(seconds: 1));
      //         // TODO this should happen in a PodClient
      //         item = Item.fromJson(jsonDecode(data!));
      //         else{
                
      //         }
      //       });

      //     }
      // }));



      print("SYNCING");

      // TODO: fix handling updated plugin
      // await PluginHandler.run(
      //     plugin: plugin, runner: pluginRunItem, context: context);
      
    } catch (error) {
      AppLogger.err("Error starting plugin: $error");
    }
  }
}
