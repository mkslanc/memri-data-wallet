import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/constants/app_icons.dart';
import 'package:memri/constants/app_images.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/core/apis/pod/item.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/renderers/label_annotation_renderer.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';

class ProjectsLabelDataScreen extends StatefulWidget {
  const ProjectsLabelDataScreen({Key? key}) : super(key: key);

  @override
  State<ProjectsLabelDataScreen> createState() =>
      _ProjectsLabelDataScreenState();
}

class _ProjectsLabelDataScreenState extends State<ProjectsLabelDataScreen> {
  @override
  Widget build(BuildContext context) {
    var greenstyle = TextStyle(
        color: app.colors.brandGreen,
        fontSize: 14,
        fontWeight: FontWeight.w400);
    return WorkspaceScaffold(
        currentItem: NavigationItem.data,
        child: Container(
          child: Row(
            children: [
              // labeling panel
              Flexible(
                flex: 3,
                child: Column(children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    width: double.infinity,
                    color: Color.fromARGB(10, 33, 192, 164),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppImages().x(
                            color: app.colors.brandGreen,
                            height: 20,
                            width: 20),
                        Text(
                          "You don’t need to label entire dataset upfront, though accurately labeled data will increase your model’s accuracy.",
                          style: greenstyle,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                            "Once you feel you have labeled enough to train the model, quit labelling and move to next step.",
                            style: greenstyle),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        // Text(
                        //   "Hey Davis,\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Eu scelerisque nisi et aliquam arcu enim. ",
                        //   style: CVUFont.headline1,
                        // ),
                        Text(
                          items[currentItem].get("content"),
                          style: CVUFont.headline1,
                        ),

                        for (var i = 0; i < labels.length; i++)
                          Container(
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
                                  AppImages().x()
                                ],
                              )),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => handlePrevious(),
                              child: AppImages().arrowLeft(),
                              style: tertiaryButtonStyle,
                            ),
                            Spacer(),
                            TextButton(
                              onPressed: () => handleSkip(),
                              child: Text("Skip item"),
                              style: secondaryButtonStyle,
                            ),
                            Spacer(),
                            TextButton(
                              onPressed: () => handNext(),
                              child: AppImages().arrow(),
                              style: tertiaryButtonStyle,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ]),
              ),
              // sidebar
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 64),
                  child: Column(
                    children: [
                      Text(
                        "SUMMARY",
                        style: CVUFont.headline3,
                      ),
                      Text(
                        "Dataset 1.0",
                        style: CVUFont.headline1,
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      Text("ITEMS", style: CVUFont.headline4),
                      Row(
                        children: [
                          Text("Labeled", style: CVUFont.ul),
                          Text("234", style: CVUFont.ul),
                          Text("80%", style: CVUFont.ul),
                        ],
                      ),
                      Row(
                        children: [
                          Text("Skipped", style: CVUFont.ul),
                          Text("23", style: CVUFont.ul),
                          Text("8%", style: CVUFont.ul),
                        ],
                      ),
                      Row(
                        children: [
                          Text("Total dataset", style: CVUFont.ul),
                          Text("500", style: CVUFont.ul),
                        ],
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      Text("LABELS", style: CVUFont.headline4),
                      Row(
                        children: [
                          Text("Positive", style: CVUFont.ul),
                          Text("23", style: CVUFont.ul),
                          Text("8%", style: CVUFont.ul),
                        ],
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      Text("HISTORY", style: CVUFont.headline4),
                          Text("lorum ipsum dolrated", style: CVUFont.ul),
                      SizedBox(
                        height: 16,
                      ),
                      TextButton(
                          onPressed: () => RouteNavigator.navigateToRoute(
                              context: context,
                              route: Routes.projectsSetupData),
                          style: primaryButtonStyle,
                          child: Row(
                            children: [
                              Text("Quite Labeling"),
                              AppImages().arrow()
                            ],
                          )),
                      TextButton(
                          onPressed: () => RouteNavigator.navigateToRoute(
                              context: context,
                              route: Routes.projectsSetupData),
                          style: secondaryButtonStyle,
                          child: Text("Back to labeling setup"))
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
              )
            ],
          ),
        ));
  }

  handNext() {
    if (currentItem < items.length - 1) {
      setState(() {
        currentItem += 1;
      });
      // TODO: Store label here
    }
  }

  handlePrevious() {
    if (currentItem > 0) {
      setState(() {
        currentItem -= 1;
      });
      // TODO: Store label here
    }
  }

  handleSkip() {
    if (currentItem < items.length - 1) {
      setState(() {
        currentItem += 1;
      });
    }
  }

  List<String> labels = ["positive", "negative", "completely toxic"];
  List<Item> items = [
    Item.fromJson({
      "content":
          "Hey Davis,\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Eu scelerisque nisi et aliquam arcu enim.",
      "dateSent": 1234567
    }),
    Item.fromJson({"content": "Lorum ipsum 2", "dateSent": 123456})
  ];
  int currentItem = 0;
}
