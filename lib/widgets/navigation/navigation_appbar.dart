import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/cvu/constants/cvu_font.dart';
import 'package:memri/providers/app_provider.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/widgets/navigation/navigation_pane_view.dart';
import 'package:provider/provider.dart';

class NavigationAppBar extends StatelessWidget {
  const NavigationAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        leading: IconButton(
      icon: app.icons.hamburger(),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    ));
  }
}
