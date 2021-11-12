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
        SvgPicture.asset("assets/images/ico_hamburger.svg"),
        SizedBox(
          width: 34,
        ),
        SvgPicture.asset("assets/images/ico_search.svg"),
        SizedBox(
          width: 34,
        ),
        SvgPicture.asset("assets/images/plus.svg"),
        Spacer(),
        NavigationItemView(
          item: Item(name: 'Dataflows'),
          sceneController: widget.sceneController,
        ),
        SizedBox(
          width: 30,
        ),
        NavigationItemView(
          item: Item(name: 'All data', targetViewName: "allItemsForDS"),
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
          item: Item(name: 'Plugins', targetViewName: "allPlugins"),
          sceneController: widget.sceneController,
        ),
        Spacer(),
        SvgPicture.asset("assets/images/logo.svg"),
      ],
    );
  }
}
