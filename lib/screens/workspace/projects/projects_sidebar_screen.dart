import 'package:flutter/material.dart';
import 'package:memri/constants/app_images.dart';
import 'package:memri/utilities/helpers/app_helper.dart';

class ProjectSideBar extends StatelessWidget {
  const ProjectSideBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Container(
        padding: EdgeInsets.all(32),
        margin: EdgeInsets.only(right: 32),
        color: app.colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppImages().signFourth(),
              ],
            ),
            SizedBox(height: 64),
            Row(
              children: [
                Text(
                  "Support",
                  style: TextStyle(
                      color: app.colors.brandBlack, fontSize: 20),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Flexible(
                  child: Text(
                      "Need some help or have questions about setting up a project? Browse our step-by-step guides and documentation or chat with us.",
                      style: TextStyle(
                          color: app.colors.brandGreyText, fontSize: 14)),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text("Getting started",
                    style: TextStyle(
                        color: app.colors.brandOrange, fontSize: 14)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text("Chat with us on Discord",
                    style: TextStyle(
                        color: app.colors.brandOrange, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
