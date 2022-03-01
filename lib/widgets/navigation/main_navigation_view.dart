import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memri/controllers/scene_controller.dart';

import 'navigation_pane_view.dart';

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
        /*SvgPicture.asset("assets/images/ico_search.svg"),*/ //TODO: uncomment this after search implemented
        Spacer(),
        NavigationItemView(
          item: Item(name: 'Data', targetViewName: "allData"),
          sceneController: widget.sceneController,
        ),
        SizedBox(
          width: 30,
        ),
        NavigationItemView(
          item: Item(name: 'Projects', targetViewName: "allProjects"),
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
