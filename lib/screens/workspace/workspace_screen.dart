import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/cvu/constants/cvu_font.dart';
import 'package:memri/localization/generated/l10n.dart';
import 'package:memri/providers/workspace_provider.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';
import 'package:memri/widgets/sticker.dart';
import 'package:provider/provider.dart';

class WorkspaceScreen extends StatefulWidget {
  final showMainNavigation;

  WorkspaceScreen({this.showMainNavigation = true});

  @override
  _WorkspaceScreenState createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  late final _workspaceProvider =
      Provider.of<WorkspaceProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return WorkspaceScaffold(
      currentItem: NavigationItem.workspace,
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Color(0xfff6f6f6),
          padding: EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60),
              Text(S.current.workspace_title, style: CVUFont.headline1),
              SizedBox(height: 20),
              Text(
                S.current.workspace_description,
                style: CVUFont.bodyText1.copyWith(color: Color(0xff999999)),
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  Sticker(
                    icon: app.images.signFirst(height: 70),
                    title: S.current.workspace_sticker_1_title,
                    description: S.current.workspace_sticker_1_description,
                    buttonsTitle: [
                      S.current.workspace_sticker_1_button_1_label,
                      S.current.workspace_sticker_1_button_2_label,
                    ],
                    buttonsCallback: [
                      () => RouteNavigator.navigateTo(
                          route: Routes.data, context: context),
                      () => RouteNavigator.navigateTo(
                          route: Routes.importerCreate, context: context),
                    ],
                  ),
                  Sticker(
                    icon: app.images.signSecond(height: 70),
                    title: S.current.workspace_sticker_2_title,
                    description: S.current.workspace_sticker_2_description,
                    buttonsTitle: [
                      S.current.workspace_sticker_2_button_1_label
                    ],
                    buttonsCallback: [
                      () => RouteNavigator.navigateTo(
                          route: Routes.projectsCreate, context: context)
                    ],
                  ),
                  Sticker(
                    icon: app.images.signThird(height: 70),
                    title: S.current.workspace_sticker_3_title,
                    description: S.current.workspace_sticker_3_description,
                    buttonsTitle: [
                      S.current.workspace_sticker_3_button_1_label
                    ],
                    buttonsCallback: [
                      /// TODO: make it more accurate
                      () => RouteNavigator.navigateTo(
                          route: Routes.apps, context: context)
                    ],
                  ),
                  Sticker(
                    icon: app.images.signFourth(height: 70),
                    title: S.current.workspace_sticker_4_title,
                    description: S.current.workspace_sticker_4_description,
                    buttonsTitle: [
                      S.current.workspace_sticker_4_button_1_label,
                      S.current.workspace_sticker_4_button_2_label,
                    ],
                    buttonsCallback: [
                      _workspaceProvider.handleGuideButton,
                      _workspaceProvider.handleDiscordButton,
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
