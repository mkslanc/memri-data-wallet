import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import 'NavigationPaneView.dart';

class MainNavigationView extends StatefulWidget {
  final SceneController sceneController;

  MainNavigationView({required this.sceneController});

  @override
  _MainNavigationViewState createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
            onPressed: () => widget.sceneController.navigationIsVisible.value = true,
            child: SvgPicture.asset("assets/images/ico_hamburger.svg")),
        SizedBox(
          width: 34,
        ),
        SvgPicture.asset("assets/images/ico_search.svg"),
        Spacer(),
        NavigationItemView(
          item: Item(name: 'Data', targetViewName: "allItemsForDS"),
          sceneController: widget.sceneController,
        ),
        SizedBox(
          width: 30,
        ),
        NavigationItemView(
          item: Item(name: 'Projects'),
          sceneController: widget.sceneController,
        ),
        SizedBox(
          width: 30,
        ),
        NavigationItemView(
          item: Item(name: 'Apps', targetViewName: "apps-and-plugins"),
          sceneController: widget.sceneController,
        ),
        Spacer(),
        InkWell(
            onTap: () => widget.sceneController
                .navigateToNewContext(clearStack: true, animated: false, viewName: "home"),
            child: SvgPicture.asset("assets/images/logo.svg"))
      ],
    );
  }
}
