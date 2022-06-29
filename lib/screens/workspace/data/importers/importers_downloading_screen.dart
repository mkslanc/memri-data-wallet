import 'dart:async';

import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/core/apis/pod/item.dart';
import 'package:memri/utils/app_helper.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';

class ImportersDownloadingScreen extends StatefulWidget {
  const ImportersDownloadingScreen({Key? key, required this.id}) : super(key: key);

  final String id;

  @override
  State<ImportersDownloadingScreen> createState() => _ImportersDownloadingScreenState();
}

class _ImportersDownloadingScreenState extends State<ImportersDownloadingScreen> {
  
  StreamSubscription<Item>? pluginRunItemStreamSubscription = null;
  double? progress;

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
                      Text("Success!", style: TextStyle(fontSize: 12, color: app.colors.brandBlack)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text("On your phone", style: TextStyle(fontSize: 30, color: app.colors.brandBlack)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text("Whatsapp has sucessfully connected to your POD. Your data is being imported, this may take a while. You can navigate away from this screen while your data is importing.",
                       style: TextStyle(fontSize: 14, color: app.colors.brandGreyText)),
                    ],
                  ),
                  SizedBox(height: 64),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Uploading WhatsApp data:",
                       style: TextStyle(fontSize: 14, color: app.colors.brandBlack)),
                       SizedBox(width: 4),
                       if (progress != null)
                      Text((progress! * 100.0).toString() +"%",
                       style: TextStyle(fontSize: 30, color: app.colors.brandViolet)),
                    ],
                  ),
                  SizedBox(height: 64),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          onPressed: () => RouteNavigator.navigateToRoute(
                              context: context,
                              route: Routes.projects),
                          style: primaryButtonStyle,
                          child: Text("Create a new project"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextButton(
                          onPressed: () => RouteNavigator.navigateToRoute(
                              context: context, route: Routes.data),
                          style: secondaryButtonStyle,
                          child: Text("Back to data screen"),
                        ),
                      ),
                    ],
                  )
                ])));
  }

  @override
  void dispose() {
    pluginRunItemStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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

    Stream<Item> pluginRunItemStream = itemStream(widget.id);
    pluginRunItemStreamSubscription = pluginRunItemStream.listen((item) {

      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          progress = item.get("progress");
          print(progress);
        });
      },);
    });
  }
}
