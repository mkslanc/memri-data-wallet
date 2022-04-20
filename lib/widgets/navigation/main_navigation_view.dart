import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:memri/controllers/scene_controller.dart';

import 'navigation_pane_view.dart';

class MainNavigationView extends StatelessWidget {
  final SceneController sceneController;
  final String? currentViewName;

  MainNavigationView({required this.sceneController, this.currentViewName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
            onPressed: () => sceneController.navigationIsVisible.value = true,
            child: SvgPicture.asset("assets/images/ico_hamburger.svg")),
        SizedBox(
          width: 34,
        ),
        /*SvgPicture.asset("assets/images/ico_search.svg"),*/
        //TODO: uncomment this after search implemented
        Spacer(),
        _buildNavigationItemView('Workspace', 'home'),
        SizedBox(width: 30),
        _buildNavigationItemView('Data', 'allData', alternativeViewNames: [
          'AccountLinkerPlugin',
          'WhatsappPlugin',
          'InstagramPlugin',
          'pluginRunWait'
        ]),
        SizedBox(width: 30),
        _buildNavigationItemView('Projects', 'allProjects'),
        SizedBox(width: 30),
        _buildNavigationItemView('Apps', 'apps-and-plugins'),
        Spacer(),
        InkWell(
            onTap: () => sceneController.navigateToNewContext(
                clearStack: true, animated: false, viewName: "home"),
            child: SvgPicture.asset("assets/images/logo.svg"))
      ],
    );
  }

  Widget _buildNavigationItemView(String name, String viewName,
      {List<String>? alternativeViewNames}) {
    bool isCurrentViewSelected = currentViewName == viewName;
    if (!isCurrentViewSelected) {
      for (int i = 0; i < (alternativeViewNames ?? []).length; i++) {
        if (currentViewName != null && currentViewName!.contains(alternativeViewNames![i])) {
          isCurrentViewSelected = true;
          break;
        }
      }
    }
    return NavigationItemView(
      item: Item(name: name, targetViewName: viewName),
      textColor: isCurrentViewSelected ? Color(0xffFE570F) : Colors.black,
      sceneController: sceneController,
    );
  }
}
