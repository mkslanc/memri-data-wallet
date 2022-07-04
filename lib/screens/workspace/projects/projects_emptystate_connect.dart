import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/screens/workspace/projects/projects_progress_steps.dart';
import 'package:memri/utilities/helpers/app_helper.dart';

class ProjectsEmptyStateScreen extends StatefulWidget {
  const ProjectsEmptyStateScreen({Key? key}) : super(key: key);

  @override
  State<ProjectsEmptyStateScreen> createState() =>
      _ProjectsEmptyStateScreenState();
}

class _ProjectsEmptyStateScreenState extends State<ProjectsEmptyStateScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: app.colors.white,
        padding: EdgeInsets.all(32),
        margin: EdgeInsets.only(left: 32, bottom: 4, right: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 64),
            Text(
              "Start building your first data app",
              style: CVUFont.headline1,
            ),
            SizedBox(height: 32),
            Text(
              "Memri allows to build, deploy and share ML apps on personal data. \nTo build a data app, you’ll need to create a new project.",
              style: CVUFont.bodyText1,
            ),
            SizedBox(height: 32),
            ProjectProgressSteps(step: 1),
            SizedBox(height: 32),
            TextButton(
                onPressed: () => RouteNavigator.navigateToRoute(
                    context: context,
                    route: Routes.projectsCreate)
                    ,
                style: primaryButtonStyle,
                child: Text("Create your project"))
          ],
        ));
  }

  List<String> contents = [
    "Collect your data",
    "Create new project",
    'Label your data',
    "Train and deploy a ML model",
    "Deploy yur data app",
    "Add a UI"
  ];
}
