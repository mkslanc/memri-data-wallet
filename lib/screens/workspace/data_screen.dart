import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/cvu/constants/cvu_font.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';

class DataScreen extends StatefulWidget {
  final showMainNavigation;

  DataScreen({this.showMainNavigation = true});

  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  @override
  Widget build(BuildContext context) {
    return WorkspaceScaffold(
      currentItem: NavigationItem.data,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(30, 30, 500, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 60),
            Row(
              children: [
                Text("Datastreams", style: CVUFont.headline1),
                Spacer(),
                TextButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.all(0))),
                  onPressed: () {},
                  child: Text(
                    'Open data explorer',
                    style: CVUFont.bodyText1.copyWith(color: Color(0xffFE570F)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 30,
              runSpacing: 30,
              children: [
                _buildBox(
                  title: 'Whatsapp',
                  description: '23 feature variables',
                  size: 'MB',
                  status: 'ACTIVE',
                  onTap: () => RouteNavigator.navigateToRoute(
                      context: context, route: Routes.importer),
                ),
                _buildBox(
                  title: 'Gmail Plugin',
                  description: '23 feature variables',
                  size: 'MB',
                  status: 'ACTIVE',
                  onTap: () {},
                ),
                _buildBox(
                  title: 'Instagram',
                  description: '23 feature variables',
                  size: 'MB',
                  status: 'ACTIVE',
                  onTap: () {},
                ),
              ],
            ),
            SizedBox(height: 30),
            Divider(),
            SizedBox(height: 60),
            Row(
              children: [
                Text("Uploaded data", style: CVUFont.headline1),
                Spacer(),
                TextButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.all(0))),
                  onPressed: () {},
                  child: Text(
                    'Upload New Data',
                    style: CVUFont.bodyText1.copyWith(color: Color(0xffFE570F)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBox({
    required String title,
    required String description,
    required String size,
    required String status,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 205,
        height: 95,
        color: Color(0xfff6f6f6),
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: CVUFont.headline3,
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: CVUFont.bodyTiny.copyWith(color: Color(0xff989898)),
            ),
            Text(
              size,
              style: CVUFont.bodyTiny.copyWith(color: Color(0xff989898)),
            ),
            Text(
              status,
              style: CVUFont.bodyTiny.copyWith(color: Color(0xff15B599)),
            ),
          ],
        ),
      ),
    );
  }
}
