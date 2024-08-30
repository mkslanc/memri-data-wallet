
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/widgets/space.dart';
import 'package:provider/provider.dart';

import '../configs/routes/route_navigator.dart';
import '../providers/app_provider.dart';


class SettingsPane extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff333333),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 50, 25, 25),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: space(
                15,
                [
                  SizedBox(
                    height: 50,
                  ),
                  TextButton(
                      onPressed: () => showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text('Are you sure you want to logout?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () async {
                                    await Provider.of<AppProvider>(context, listen: false).resetApp();
                                    RouteNavigator.navigateTo(
                                        context: context,
                                        route: Routes.onboarding);
                                  },
                                  child: const Text('OK'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, 'Cancel'),
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          ),
                      child: Text("Logout",
                          style: TextStyle(color: app.colors.white, fontSize: 18)))
                ],
                Axis.vertical),
          ),
          Positioned(
              right: 0,
              child: FloatingActionButton(
                  backgroundColor: app.colors.black,
                  child: Icon(
                    Icons.close,
                    color: app.colors.blue,
                  ),
                  onPressed: () => Navigator.of(context).pop()))
        ],
      ),
    );
  }
}
