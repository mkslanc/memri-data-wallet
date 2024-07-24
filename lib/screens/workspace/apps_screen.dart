import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/cvu/constants/cvu_font.dart';
import 'package:memri/widgets/empty.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';

class AppsScreen extends StatefulWidget {
  final showMainNavigation;

  AppsScreen({this.showMainNavigation = true});

  @override
  _AppsScreenState createState() => _AppsScreenState();
}

class _AppsScreenState extends State<AppsScreen> {
  @override
  Widget build(BuildContext context) {
    return WorkspaceScaffold(
      currentItem: NavigationItem.apps,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(30, 30, 0, 30),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Color(0xfff5f5f5),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text("Inbox", style: CVUFont.headline2),
                            Spacer(),
                            Text("Running",
                                style: CVUFont.bodyText1
                                    .copyWith(color: Color(0xff15B599))),
                          ],
                        ),
                        SizedBox(height: 15),
                        Text(
                          " The Inbox app displays all incoming messages and emails, and allows sending and receiving them. It requires the use of at least one messenger or email importer.",
                          style: CVUFont.bodyTiny
                              .copyWith(color: Color(0xff989898)),
                        ),
                        SizedBox(height: 10),
                        Row(children: [
                          TextButton(
                            style: ButtonStyle(
                                padding: WidgetStateProperty.all(
                                    EdgeInsets.all(0))),
                            onPressed: () => RouteNavigator.navigateTo(
                                context: context, route: Routes.inbox),
                            child: Text(
                              'Open App',
                              style: CVUFont.buttonLabel
                                  .copyWith(color: Color(0xffFE570F)),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(flex: 1, child: Empty()),
          ],
        ),
      ),
    );
  }
}
