import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';

class WhatsappScreen extends StatelessWidget {
  const WhatsappScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WorkspaceScaffold(
      currentItem: NavigationItem.data,
      child: Padding(
        padding: EdgeInsets.fromLTRB(30, 60, 0, 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Step 1", style: CVUFont.link),
            SizedBox(height: 4),
            Text("WhatsApp authorisation", style: CVUFont.headline1),
            SizedBox(height: 10),
            Text(
                "To complete the WhatsApp authorisation you will need your phone to scan the QR code",
                style: CVUFont.bodyText1.copyWith(color: Color(0xff737373))),
            SizedBox(height: 60),
            TextButton(
              onPressed: () =>
                  RouteNavigator.navigateToRoute(context: context, route: Routes.whatsappConnect),
              style: primaryButtonStyle,
              child: Text("Connect!"),
            ),
          ],
        ),
      ),
    );
  }
}
