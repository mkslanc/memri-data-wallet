import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/core/controllers/app_controller.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/widgets/navigation/navigation_pane_view.dart';

enum NavigationItem { workspace, data, projects, apps }

class NavigationAppBar extends StatelessWidget {
  const NavigationAppBar({Key? key, required this.currentItem})
      : super(key: key);

  final NavigationItem currentItem;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: AppController.shared.navigationIsVisible,
        builder: (BuildContext context, bool value, Widget? child) {
          return Column(
            children: [
              if (!value)
                Container(
                  color: Color(0xffF6F6F6),
                  padding: EdgeInsets.fromLTRB(30, 20, 30, 125),
                  child: Container(
                    height: 45,
                    child: Row(
                      children: [
                        TextButton(
                            onPressed: () => AppController
                                .shared.navigationIsVisible.value = true,
                            child: app.icons.hamburger()),
                        SizedBox(width: 34),
                        /*SvgPicture.asset("assets/images/ico_search.svg"),*/
                        //TODO: uncomment this after search implemented
                        Spacer(),
                        TextButton(
                          onPressed: () => RouteNavigator.navigateToRoute(
                              context: context,
                              route: Routes.workspace,
                              clearStack: true),
                          child: Text(
                            "Workspace",
                            style: CVUFont.bodyText1.copyWith(
                                color: currentItem == NavigationItem.workspace
                                    ? Color(0xffFE570F)
                                    : Color(0xff333333)),
                          ),
                        ),
                        SizedBox(width: 30),
                        TextButton(
                          onPressed: () => RouteNavigator.navigateToRoute(
                              context: context, route: Routes.data),
                          child: Text(
                            "Data",
                            style: CVUFont.bodyText1.copyWith(
                                color: currentItem == NavigationItem.data
                                    ? Color(0xffFE570F)
                                    : Color(0xff333333)),
                          ),
                        ),
                        SizedBox(width: 30),
                        TextButton(
                          onPressed: () => RouteNavigator.navigateToRoute(
                              context: context, route: Routes.projects),
                          child: Text(
                            "Projects",
                            style: CVUFont.bodyText1.copyWith(
                                color: currentItem == NavigationItem.projects
                                    ? Color(0xffFE570F)
                                    : Color(0xff333333)),
                          ),
                        ),
                        SizedBox(width: 30),
                        TextButton(
                          onPressed: () => RouteNavigator.navigateToRoute(
                              context: context, route: Routes.apps),
                          child: Text(
                            "Apps",
                            style: CVUFont.bodyText1.copyWith(
                                color: currentItem == NavigationItem.apps
                                    ? Color(0xffFE570F)
                                    : Color(0xff333333)),
                          ),
                        ),
                        Spacer(),
                        InkWell(
                            onTap: () => RouteNavigator.navigateToRoute(
                                context: context,
                                route: Routes.workspace,
                                clearStack: true),
                            child: app.images.logo())
                      ],
                    ),
                  ),
                ),
              if (value)
                Container(
                    height: 368,
                    width: MediaQuery.of(context).size.width,
                    color: Color(0xff4F56FE),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
                      child: NavigationPaneView(),
                    ))
            ],
          );
        });
  }
}
