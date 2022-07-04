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
import 'dart:html';

class ProjectsSetupLabelEditorScreen extends StatefulWidget {
  const ProjectsSetupLabelEditorScreen({Key? key}) : super(key: key);

  @override
  State<ProjectsSetupLabelEditorScreen> createState() =>
      _ProjectsSetupDataScreenState();
}

class _ProjectsSetupDataScreenState
    extends State<ProjectsSetupLabelEditorScreen> {
  @override
  Widget build(BuildContext context) {
    document.addEventListener('keydown', (dynamic event) {
      if (event.code == 'Tab') {
        event.preventDefault();
      }
    });
    return WorkspaceScaffold(
        currentItem: NavigationItem.data,
        child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Step 3", style: CVUFont.headline2),
                Text("Add labels you want to use in your app.",
                    style: CVUFont.headline1),
                SizedBox(
                  height: 32,
                ),
                Container(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Text(
                      "Add the labels you want to use on your data and in your app.  You may only use one label per data item. For example, if you are building a sentiment analysis app, add: positive, negative and neutral to label each message.",
                      style: CVUFont.bodyText1),
                ),
                Text(
                    "Use the index numbers for keyboard shortcuts to help you label at warp speed!",
                    style: CVUFont.bodyText1),
                SizedBox(
                  height: 16,
                ),
                Column(
                  children: [
                    for (var i = 0; i < labels.length; i++)
                      FittedBox(
                        child: Container(
                            padding: EdgeInsets.all(8),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                                color: app.colors.brandWhite,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Row(
                              children: [
                                Text(labels[i]),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(i.toString()),
                                InkWell(
                                  child: AppImages().x(),
                                  onTap: () => handleLabelCancel(i),
                                )
                              ],
                            )),
                      ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                          color: Color(0xffF5F5F5),
                          child: TextFormField(
                              onFieldSubmitted: (str) => handleNewLabel(),
                              controller: userInput,
                              decoration: InputDecoration(
                                  hintText: "e.g. positive",
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                  border: InputBorder.none,
                                  hintStyle: CVUFont.input))),
                    ),
                    Flexible(
                      flex: 2,
                      child: TextButton(
                        onPressed: () {
                          handleNewLabel();
                        },
                        child: Text("Add new label"),
                        style: tertiaryButtonStyle,
                      ),
                    )
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
                                route: Routes.projectsLabelData),
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
                                context: context,
                                route: Routes.projectsSetupData),
                            style: secondaryButtonStyle,
                            child: Text("Back to data setup")),
                      ],
                    )
                  ],
                )
              ],
            )));
  }

  List<String> labels = [];
  TextEditingController userInput = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void setSelected() {}

  void handleNewLabel() {
    setState(() {
      if (userInput.text != "") {
        labels.add(userInput.text);
        userInput.text = "";
      }
    });
  }

  handleLabelCancel(int labelIndex) {
    setState(() {
      labels.removeAt(labelIndex);
    });
  }
}
