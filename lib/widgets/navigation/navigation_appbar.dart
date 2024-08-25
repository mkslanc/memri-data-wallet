import 'package:flutter/material.dart';
import 'package:memri/utilities/helpers/app_helper.dart';

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
