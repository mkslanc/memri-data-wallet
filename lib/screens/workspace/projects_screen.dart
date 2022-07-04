import 'package:flutter/material.dart';
import 'package:memri/screens/workspace/projects/projects_emptystate_connect.dart';
import 'package:memri/screens/workspace/projects/projects_sidebar_screen.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({Key? key}) : super(key: key);

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  Widget build(BuildContext context) {
    return WorkspaceScaffold(
        currentItem: NavigationItem.data,
        child: projects.length == 0
            ? ProjectsEmptyStateScreen()
            : Container(
                color: app.colors.greyBackGround,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        child: Column(
                          children: [
                            ListView.builder(
                                // controller: ScrollController(),
                                itemCount: projects.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return Container(
                                    color: app.colors.white,
                                    padding: EdgeInsets.all(32),
                                    margin: EdgeInsets.only(
                                        left: 32, bottom: 4, right: 4),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Project name",
                                              style: TextStyle(
                                                  color: app.colors.brandBlack,
                                                  fontSize: 20),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 32),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text("DATA SOURCE",
                                                        style: TextStyle(
                                                            color: app.colors
                                                                .brandGreyText,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700)),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text("Whatsapp",
                                                        style: TextStyle(
                                                          color: app.colors
                                                              .brandBlack,
                                                          fontSize: 14,
                                                        )),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text("Gmail",
                                                        style: TextStyle(
                                                            color: app.colors
                                                                .brandBlack,
                                                            fontSize: 14)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 64),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text("TEXT CLASSIFICATION",
                                                        style: TextStyle(
                                                            color: app.colors
                                                                .brandGreyText,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700)),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text("Whatsapp",
                                                        style: TextStyle(
                                                            color: app.colors
                                                                .brandGreyText,
                                                            fontSize: 14)),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text("Gmail",
                                                        style: TextStyle(
                                                            color: app.colors
                                                                .brandGreyText,
                                                            fontSize: 14)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 64),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text("MODEL",
                                                        style: TextStyle(
                                                            color: app.colors
                                                                .brandGreyText,
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700)),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text("Version",
                                                        style: TextStyle(
                                                            color: app.colors
                                                                .brandGreyText,
                                                            fontSize: 14)),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text("Accuracy",
                                                        style: TextStyle(
                                                            color: app.colors
                                                                .brandGreyText,
                                                            fontSize: 14)),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text("Dataset",
                                                        style: TextStyle(
                                                            color: app.colors
                                                                .brandGreyText,
                                                            fontSize: 14)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4)
                                      ],
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                    ),
                    ProjectSideBar()
                  ],
                ),
              ));
  }

  // List<String> projects = ["a", "b"];
  List<String> projects = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
}
