import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/constants/app_images.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';

class ProjectsSummaryScreen extends StatelessWidget {
  const ProjectsSummaryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WorkspaceScaffold(
      currentItem: NavigationItem.data,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your labelling summary",
              style: CVUFont.headline1,
            ),
            SizedBox(height: 16,),
            Container(
              constraints: BoxConstraints(maxWidth: 500),
              child: Text(
                "This is the summary of your labelled dataset. You can label more data or you can continue to the next step and use the labelled dataset to create a new machine learning model.",
                style: CVUFont.bodyText1,
              ),
            ),
            SizedBox(
              height: 32,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    "ITEMS",
                    style: CVUFont.smallCaps.copyWith(color: Color(0xff999999)),
                  ),
                  Row(
                    children: [
                      Text("Labeled",
                          style: CVUFont.ul.copyWith(color: Color(0xff999999))),
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
                  Row(
                    children: [
                      Text("Skipped",
                          style: CVUFont.ul.copyWith(color: Color(0xff999999))),
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
                  Row(
                    children: [
                      Text("Total",
                          style: CVUFont.ul.copyWith(color: Color(0xff999999))),
                      SizedBox(
                        width: 8,
                      ),
                      Text("500", style: CVUFont.ul),
                    ],
                  ),
                ]),
                SizedBox(
                  width: 128,
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    "LABELS",
                    style: CVUFont.smallCaps.copyWith(color: Color(0xff999999)),
                  ),
                  Row(
                    children: [
                      Text("Positive", style: CVUFont.ul),
                      SizedBox(
                        width: 8,
                      ),
                      Text("4223", style: CVUFont.ul),
                      SizedBox(
                        width: 8,
                      ),
                      Text("8%", style: CVUFont.ul),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Negative", style: CVUFont.ul),
                      SizedBox(
                        width: 8,
                      ),
                      Text("3245", style: CVUFont.ul),
                      SizedBox(
                        width: 8,
                      ),
                      Text("8%", style: CVUFont.ul),
                    ],
                  ),
                  Row(
                    children: [
                      Text("Completely toxic", style: CVUFont.ul),
                      SizedBox(
                        width: 8,
                      ),
                      Text("3245", style: CVUFont.ul),
                      SizedBox(
                        width: 8,
                      ),
                      Text("8%", style: CVUFont.ul),
                    ],
                  ),
                ])
              ],
            ),
            SizedBox(
              height: 64,
            ),
            Row(
              children: [
                TextButton(
                    onPressed: () => RouteNavigator.navigateTo(
                        context: context, route: Routes.projectsSummary),
                    style: primaryButtonStyle,
                    child: Row(
                      children: [Text("Next step"), AppImages().arrow()],
                    )),
                TextButton(
                    onPressed: () => RouteNavigator.navigateTo(
                        context: context, route: Routes.projectsLabelData),
                    style: secondaryButtonStyle,
                    child: Text("Back to labelling"))
              ],
            )
          ],
        ),
      ),
    );
  }
}
