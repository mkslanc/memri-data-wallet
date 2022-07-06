import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/cvu/constants/cvu_font.dart';
import 'package:memri/providers/app_provider.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/widgets/navigation/navigation_pane_view.dart';
import 'package:provider/provider.dart';

enum NavigationItem { workspace, data, projects, apps, cvu }

class NavigationAppBar extends StatelessWidget {
  const NavigationAppBar({Key? key, required this.currentItem})
      : super(key: key);

  final NavigationItem currentItem;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
        builder: (BuildContext context, provider, _) => Column(
              children: [
                if (!provider.navigationIsVisible)
                  Container(
                    color: Color(0xffF6F6F6),
                    padding: EdgeInsets.fromLTRB(30, 20, 30, 125),
                    child: Container(
                      height: 45,
                      child: Row(
                        children: [
                          TextButton(
                              onPressed: () => Provider.of<AppProvider>(context,
                                      listen: false)
                                  .navigationIsVisible = true,
                              child: app.icons.hamburger()),
                          SizedBox(width: 34),
                          /*SvgPicture.asset("assets/images/ico_search.svg"),*/
                          //TODO: uncomment this after search implemented
                          Spacer(),
                          TextButton(
                            onPressed: () => RouteNavigator.navigateTo(
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
                            onPressed: () => RouteNavigator.navigateTo(
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
                            onPressed: () => RouteNavigator.navigateTo(
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
                            onPressed: () => RouteNavigator.navigateTo(
                                context: context, route: Routes.apps),
                            child: Text(
                              "Apps",
                              style: CVUFont.bodyText1.copyWith(
                                  color: currentItem == NavigationItem.apps
                                      ? Color(0xffFE570F)
                                      : Color(0xff333333)),
                            ),
                          ),
                          SizedBox(width: 30),
                          TextButton(
                            onPressed: () => RouteNavigator.navigateTo(
                                context: context, route: Routes.cvu),
                            child: Text(
                              "CVU Test",
                              style: CVUFont.bodyText1.copyWith(
                                  color: currentItem == NavigationItem.cvu
                                      ? Color(0xffFE570F)
                                      : Color(0xff333333)),
                            ),
                          ),
                          Spacer(),
                          InkWell(
                              onTap: () => RouteNavigator.navigateTo(
                                  context: context,
                                  route: Routes.workspace,
                                  clearStack: true),
                              child: app.images.logo())
                        ],
                      ),
                    ),
                  ),
                if (provider.navigationIsVisible)
                  Container(
                      height: 368,
                      width: MediaQuery.of(context).size.width,
                      color: Color(0xff4F56FE),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
                        child: NavigationPaneView(),
                      ))
              ],
            ));
  }
}
