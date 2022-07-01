import 'package:flutter/material.dart';
import 'package:memri/constants/app_images.dart';
import 'package:memri/constants/cvu/cvu_font.dart';

class ProjectProgressSteps extends StatefulWidget {
  const ProjectProgressSteps({
    Key? key,
    required this.step,
  }) : super(key: key);
  final int step;

  @override
  State<ProjectProgressSteps> createState() => _ProjectProgressStepsState();
}

class _ProjectProgressStepsState extends State<ProjectProgressSteps> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < contents.length; i++)
          Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "0${i + 1}",
                  style: CVUFont.bodyText1,
                ),
                AppImages().arrowLong(),
                Text(
                  contents[i],
                  style: CVUFont.bodyText2,
                ),
              ],
            ),
          ),
      ],
    );
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

