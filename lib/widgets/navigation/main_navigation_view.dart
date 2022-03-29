import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memri/controllers/scene_controller.dart';

import 'navigation_pane_view.dart';

class MainNavigationView extends StatefulWidget {
  final SceneController sceneController;
  final String? currentViewName;

  MainNavigationView({required this.sceneController, this.currentViewName});

  @override
  _MainNavigationViewState createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  String? _currentViewName;

  @override
  void initState() {
    _currentViewName = widget.currentViewName;
    super.initState();
  }

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
        /*SvgPicture.asset("assets/images/ico_search.svg"),*/
        //TODO: uncomment this after search implemented
        Spacer(),
        _buildNavigationItemView('Workspace', 'home'),
        SizedBox(width: 30),
        _buildNavigationItemView('Data', 'allData'),
        SizedBox(width: 30),
        _buildNavigationItemView('Projects', 'allProjects'),
        SizedBox(width: 30),
        _buildNavigationItemView('Apps', 'apps-and-plugins'),
        Spacer(),
        InkWell(
            onTap: () => widget.sceneController
                .navigateToNewContext(clearStack: true, animated: false, viewName: "home"),
            child: SvgPicture.asset("assets/images/logo.svg"))
      ],
    );
  }

  Widget _buildNavigationItemView(String name, String viewName) {
    return NavigationItemView(
      item: Item(
        name: name,
        targetViewName: viewName,
        callback: () => setState(() => _currentViewName = viewName),
      ),
      textColor: _currentViewName == viewName ? Color(0xffFE570F) : Colors.black,
      sceneController: widget.sceneController,
    );
  }
}
