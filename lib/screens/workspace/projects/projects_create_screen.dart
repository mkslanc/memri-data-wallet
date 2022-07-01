import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/constants/app_images.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/screens/workspace/projects/projects_progress_steps.dart';
import 'package:memri/utilities/binding.dart';
import 'package:memri/widgets/components/text_field/memri_text_field.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';
import 'package:memri/screens/workspace/data_screen.dart';

class ProjectsCreateScreen extends StatelessWidget {
  const ProjectsCreateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WorkspaceScaffold(
        currentItem: NavigationItem.data,
        child: Container(
          padding: EdgeInsets.all(32),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Create a new project", style: CVUFont.headline1),
            SizedBox(height: 16),
            Text(
                "Memri allows to build, deploy and share ML apps on personal data in 6 steps.",
                style: CVUFont.bodyText1),
            SizedBox(height: 32),
            ProjectProgressSteps(step: 1),
            SizedBox(height: 32),
            Text("Create your new project name", style: CVUFont.headline3),
            SizedBox(height: 8),
            Text(
                "Please choose a name for your new project, this will also be the name of your app.",
                style: CVUFont.bodyText1),
            SizedBox(height: 32),
            Container(
              color: Color(0xffF5F5F5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text("YOUR PROJECT NAME"),
              TextField(
                  decoration: InputDecoration(
                      hintText: "project 1",
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      border: InputBorder.none,
                      hintStyle: CVUFont.input)),

              ],),
            ),
            SizedBox(height: 32),
            Text("Select data source", style: CVUFont.headline3),
            SizedBox(height: 8),
            Text(
                "Select the data source for your new app. You may only select one.",
                style: CVUFont.bodyText1),
            SizedBox(height: 8),
            buildBox(
              title: 'Whatsapp',
              description: '2 feature variables',
              size: 'MB',
              status: 'ACTIVE',
              onTap: () {},
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Column(
                  children: [
                    TextButton(
                        onPressed: () => RouteNavigator.navigateToRoute(
                            context: context, route: Routes.projectsSetupData),
                        style: primaryButtonStyle,
                        child: Container(
                            child: Row(
                          children: [
                            Text("Next"),
                            SizedBox(
                              width: 8,
                            ),
                            AppImages().arrow(),
                          ],
                        ))),
                  ],
                ),
                SizedBox(width: 8),
                Column(
                  children: [
                    TextButton(
                        onPressed: () => RouteNavigator.navigateToRoute(
                            context: context, route: Routes.projects),
                        style: secondaryButtonStyle,
                        child: Text("Cancel")),
                  ],
                )
              ],
            )
          ]),
        ));
  }
}
