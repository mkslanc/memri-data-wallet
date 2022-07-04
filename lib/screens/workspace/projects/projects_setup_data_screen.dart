import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/constants/app_images.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/core/models/database/database.dart';
import 'package:memri/screens/workspace/projects/projects_progress_steps.dart';
import 'package:memri/utilities/binding.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/widgets/components/text_field/memri_text_field.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';
import 'package:memri/screens/workspace/data_screen.dart';

class ProjectsSetupDataScreen extends StatefulWidget {
  const ProjectsSetupDataScreen({Key? key}) : super(key: key);

  @override
  State<ProjectsSetupDataScreen> createState() =>
      _ProjectsSetupDataScreenState();
}

class _ProjectsSetupDataScreenState extends State<ProjectsSetupDataScreen> {
  @override
  Widget build(BuildContext context) {
    return WorkspaceScaffold(
        currentItem: NavigationItem.data,
        child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Step 2", style: CVUFont.headline2),
                Text("Select feature variables", style: CVUFont.headline1),
                SizedBox(
                  height: 32,
                ),
                Container(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: Text(
                      "Feature variables represent different information available in your connected datasets. You may choose the most relevant variables based on what kind of predictions you wish your app to make. For example, if you want the app use the message body, choose ‘message text’.",
                      style: CVUFont.bodyText1),
                ),
                Text(
                    "Select which information from your dataset you wish to use in your app:",
                    style: CVUFont.bodyText1),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          selected[0] = !selected[0];
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(2),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: selected[0]
                                ? app.colors.backgroundOrange
                                : app.colors.brandWhite,
                            borderRadius: BorderRadius.all(Radius.circular(2))),
                        child: Row(children: [
                          Text("Message Text",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: selected[0]
                                      ? app.colors.brandOrange
                                      : app.colors.brandGreyText)),
                          AppImages().checkmark(
                              color: selected[0]
                                  ? app.colors.brandOrange
                                  : app.colors.brandGreyText)
                        ]),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          selected[1] = !selected[1];
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(2),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: selected[1]
                                ? Color.fromARGB(20, 254, 87, 15)
                                : app.colors.brandWhite,
                            borderRadius: BorderRadius.all(Radius.circular(2))),
                        child: Row(children: [
                          Text("Date Sent",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: selected[1]
                                      ? app.colors.brandOrange
                                      : app.colors.brandGreyText)),
                          AppImages().checkmark(
                              color: selected[1]
                                  ? app.colors.brandOrange
                                  : app.colors.brandGreyText)
                        ]),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        TextButton(
                            onPressed: () => RouteNavigator.navigateToRoute(
                                context: context,
                                route: Routes.projectsSetupLabelEditor),
                            style: primaryButtonStyle,
                            child: Container(
                                child: Row(
                              children: [
                                Text("Next"),
                                SizedBox(
                                  width: 16,
                                ),
                                AppImages().arrow(),
                              ],
                            ))),
                      ],
                    ),
                    SizedBox(width: 16),
                    Column(
                      children: [
                        TextButton(
                            onPressed: () => RouteNavigator.navigateToRoute(
                                context: context, route: Routes.projectsCreate),
                            style: secondaryButtonStyle,
                            child: Text("Back to project setup")),
                      ],
                    )
                  ],
                )
              ],
            )));
  }

  List<bool> selected = [false, false];
  List<String> properties = ["content", "dateSent"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void setSelected() {}
}
