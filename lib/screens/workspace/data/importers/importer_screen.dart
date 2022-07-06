import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/cvu/constants/cvu_font.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';

class ImporterScreen extends StatelessWidget {
  const ImporterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WorkspaceScaffold(
      currentItem: NavigationItem.data,
      child: Padding(
        padding: EdgeInsets.fromLTRB(30, 60, 0, 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("WhatsApp authorisation", style: CVUFont.headline1),
            SizedBox(height: 10),
            Text(
                "To connect your Whatsapp to memri you will need your phone with a camera to scan a QR code and a current version of Whatsapp installed.",
                style: CVUFont.bodyText1.copyWith(color: Color(0xff737373))),
            SizedBox(height: 60),
            Row(
              children: [
                TextButton(
                  onPressed: () => RouteNavigator.navigateTo(
                      context: context, route: Routes.importerConnect),
                  style: primaryButtonStyle,
                  child: Text("Ok, let's go!"),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: TextButton(
                    onPressed: () => RouteNavigator.navigateTo(
                        context: context, route: Routes.data),
                    style: secondaryButtonStyle,
                    child: Text("Cancel"),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
