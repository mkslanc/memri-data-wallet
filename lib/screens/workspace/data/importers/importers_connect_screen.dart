import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/core/apis/pod/pod_payloads.dart';
import 'package:memri/core/controllers/app_controller.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';
import 'package:uuid/uuid.dart';

import '../../../../constants/app_logger.dart';
import '../../../../core/apis/pod/item.dart';
import '../../../../core/services/mixpanel_analytics_service.dart';
import '../../../../widgets/components/html_view/html_view.dart';

class ImporterInfoLine extends StatelessWidget {
  const ImporterInfoLine(
      {Key? key, required this.weights, required this.contents})
      : super(key: key);

  final List<FontWeight> weights;
  final List<String> contents;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            padding: new EdgeInsets.only(top: 12, bottom: 12, right: 12),
            child: SvgPicture.asset("assets/images/arrow-right-circle.svg")),
        for (int i = 0; i < contents.length; i++)
          Text(contents[i],
              style: TextStyle(fontSize: 14, fontWeight: weights[i]))
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
              // Row(
              //   children: [
              //     Text("Step 2", style: TextStyle(fontSize: 12)),
              //   ],
              // ),
              Row(
                children: [
                  Text("On your phone", style: TextStyle(fontSize: 30)),
                ],
              ),
              ImporterInfoLine(
                  contents: ["Open", " Whatsapp"],
                  weights: [FontWeight.normal, FontWeight.bold]),
              ImporterInfoLine(
                contents: [
                  "Tap",
                  " settings",
                  " and select",
                  " Linked devices"
                ],
                weights: [
                  FontWeight.normal,
                  FontWeight.bold,
                  FontWeight.normal,
                  FontWeight.bold
                ],
              ),
              ImporterInfoLine(
                contents: ["Tap", " Link a device"],
                weights: [FontWeight.normal, FontWeight.bold],
              ),
              ImporterInfoLine(
                contents: [
                  "Point your phone to the QR code on the screen of your computer to",
                  " capture the code"
                ],
                weights: [FontWeight.normal, FontWeight.bold],
              ),
              Container(
                  child: (() {
                if ((status == "idle" && url == null) || status == "started") {
                  return Container(
                      height: 350,
                      constraints: BoxConstraints(maxWidth: 350),
                      // color:Color.fromARGB(194, 66, 14, 14),
                      color: Color(0xffF6F6F6),
                      padding: EdgeInsets.all(32),
                      child: Center(
                          child: Text(
                              "Please wait for your QR code to be generated. This make take a few moments.",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: app.colors.brandGreyText))));
                } else if (status == "userActionNeeded") {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          // dont change this height, it will cut off the qr code
                          height: 350,
                          width: 350,
                          child: HtmlView(src: url, reload: true)),
                    ],
                  );
                } else if (status == "daemon") {
                  return Container(
                      child: Row(
                    children: [
                      Text(
                        "Signing in",
                        style: TextStyle(
                            color: app.colors.brandOrange, fontSize: 14),
                      ),
                    ],
                  ));
                } else if (status == "error") {
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
            pluginRunItemStreamSubscription =
                pluginRunItemStream.listen((item) {
              var _status = item.get("status");
              authenticated = _status == "daemon";
              if (authenticated) {
                RouteNavigator.navigateToRoute(
                    context: context,
                    route: Routes.importerDownloading,
                    param: {"id": id});
              } else {
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
}
