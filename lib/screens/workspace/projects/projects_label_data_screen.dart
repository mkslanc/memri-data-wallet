import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/constants/app_images.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/core/apis/pod/item.dart';
import 'package:memri/cvu/constants/cvu_font.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';

class ProjectsLabelDataScreen extends StatefulWidget {
  const ProjectsLabelDataScreen({Key? key}) : super(key: key);

  @override
  State<ProjectsLabelDataScreen> createState() =>
      _ProjectsLabelDataScreenState();
}

class Label {
  bool selected = false;
  Item? item;

  Label(this.item, {this.selected = false}) {}
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
              Expanded(
                flex: 3,
                child: Column(children: [
                  if (showInfo)
                    Container(
                      padding: EdgeInsets.all(16),
                      width: double.infinity,
                      color: Color.fromARGB(10, 33, 192, 164),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            right: 0,
                            child: InkWell(
                              onTap: (() => toggleShowInfo()),
                              child: AppImages().x(
                                  color: app.colors.brandGreen,
                                  height: 20,
                                  width: 20),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                        Container(
                          padding: EdgeInsets.all(128),
                          child: Text(
                            items[currentItem].get("content"),
                            style: CVUFont.headline1,
                          ),
                        ),

                        // Wrap(
                        //   children: [
                        //     for (var i = 0; i < labels.length; i++)
                        //       Chip(
                        //         label: InkWell(
                        //           child: Text(labels[i]),
                        //           onTap: () {},
                        //         ),
                        //         deleteIcon: AppImages().x(),
                        //         onDeleted: () {},
                        //         backgroundColor: app.colors.brandWhite,
                        //       ),
                        //   ],
                        //   spacing: 8,
                        //   direction: Axis.vertical,
                        //   crossAxisAlignment: WrapCrossAlignment.center,
                        //   runSpacing: 8,
                        // ),
                        for (var i = 0; i < labels.length; i++)
                          FittedBox(
                            child: InkWell(
                              onTap: () => handleLabelClick(labels[i]),
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  margin: EdgeInsets.symmetric(vertical: 2),
                                  decoration: BoxDecoration(
                                      color: labels[i].selected
                                          ? app.colors.backgroundOrange
                                          : app.colors.brandWhite,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Row(
                                    children: [
                                      Text(
                                        labels[i].item?.get("labelName"),
                                        style: CVUFont.bodyText1.copyWith(
                                            color: labels[i].selected
                                                ? app.colors.brandOrange
                                                : app.colors.brandBlack),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        i.toString(),
                                        style: CVUFont.smallCaps,
                                      ),
                                    ],
                                  )),
                            ),
                          ),
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
                      Text("ITEMS",
                          style: CVUFont.smallCaps
                              .copyWith(color: Color(0xff999999))),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text("Labeled",
                              style: CVUFont.ul
                                  .copyWith(color: Color(0xff999999))),
                          SizedBox(
                            width: 8,
                          ),
                          Text("234", style: CVUFont.ul),
                          SizedBox(
                            width: 8,
                          ),
                          Text("80%", style: CVUFont.ul),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text("Skipped",
                              style: CVUFont.ul
                                  .copyWith(color: Color(0xff999999))),
                          SizedBox(
                            width: 8,
                          ),
                          Text("23", style: CVUFont.ul),
                          SizedBox(
                            width: 8,
                          ),
                          Text("8%", style: CVUFont.ul),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text("Total dataset",
                              style: CVUFont.ul
                                  .copyWith(color: Color(0xff999999))),
                          SizedBox(
                            width: 8,
                          ),
                          Text("500", style: CVUFont.ul),
                        ],
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      Text("LABELS",
                          style: CVUFont.smallCaps
                              .copyWith(color: Color(0xff999999))),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text("Positive", style: CVUFont.ul),
                          SizedBox(
                            width: 8,
                          ),
                          Text("23", style: CVUFont.ul),
                          SizedBox(
                            width: 8,
                          ),
                          Text("8%", style: CVUFont.ul),
                        ],
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      Text("HISTORY",
                          style: CVUFont.smallCaps
                              .copyWith(color: Color(0xff999999))),
                      SizedBox(height: 4),
                      Text("lorum ipsum Dolor sit amet", style: CVUFont.ul),
                      SizedBox(height: 4),
                      Text("lorum ipsum Dolor sit amet", style: CVUFont.ul),
                      SizedBox(
                        height: 128,
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints.tightFor(width: 180),
                        child: TextButton(
                            onPressed: () => RouteNavigator.navigateTo(
                                context: context,
                                route: Routes.projectsSummary),
                            style: primaryButtonStyle,
                            child: Row(
                              children: [
                                Text("Quit Labeling"),
                                Spacer(),
                                AppImages().arrow()
                              ],
                            )),
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints.tightFor(width: 180),
                        child: TextButton(
                            onPressed: () => RouteNavigator.navigateTo(
                                context: context,
                                route: Routes.projectsSetupLabelEditor),
                            style: secondaryButtonStyle,
                            child: Text("Back to labeling setup")),
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
              )
            ],
          ),
        ));
  }

  resetLabels() {
    setState(() {
      for (var _label in labels) {
        _label.selected = false;
      }
    });
  }

  inheritCurrentLabel() {
    // TODO
  }

  handNext() {
    if (currentItem < items.length - 1) {
      setState(() {
        currentItem += 1;
        resetLabels();
      });
      // TODO: Store label here
    }
  }

  handlePrevious() {
    if (currentItem > 0) {
      setState(() {
        currentItem -= 1;
        resetLabels();
      });
      // TODO: Store label here
    }
  }

  handleSkip() {
    if (currentItem < items.length - 1) {
      setState(() {
        currentItem += 1;
        resetLabels();
      });
    }
  }

  List<Label> labels = [
    Label(Item.fromJson({"labelName": "positive"})),
    Label(Item.fromJson({"labelName": "negative"})),
    Label(Item.fromJson({"labelName": "completely toxic"}))
  ];

  List<Item> items = [
    Item.fromJson({
      "content":
          "Hey Davis,\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Eu scelerisque nisi et aliquam arcu enim.",
      "dateSent": 1234567
    }),
    Item.fromJson({"content": "Lorum ipsum 2", "dateSent": 123456})
  ];
  int currentItem = 0;
  bool showInfo = true;

  handleLabelClick(Label label) {
    setState(() {
      for (var _label in labels) {
        if (_label != label) {
          _label.selected = false;
        }
      }
      label.selected = !label.selected;
    });
  }

  toggleShowInfo() {
    setState(() {
      showInfo = false;
    });
  }
}
