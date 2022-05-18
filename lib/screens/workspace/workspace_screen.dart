import 'package:flutter/material.dart';
import 'package:memri/constants/app_images.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/widgets/navigation/navigation_appbar.dart';
import 'package:memri/widgets/scaffold/workspace_scaffold.dart';
import 'package:memri/widgets/sticker.dart';

class WorkspaceScreen extends StatefulWidget {
  final showMainNavigation;

  WorkspaceScreen({this.showMainNavigation = true});

  @override
  _WorkspaceScreenState createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  @override
  Widget build(BuildContext context) {
    return WorkspaceScaffold(
      currentItem: NavigationItem.workspace,
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: Color(0xfff6f6f6),
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 60),
            Text("One place for your data apps", style: CVUFont.headline1),
            SizedBox(height: 20),
            Text(
              "Connect and label your data, train ML models, and build, customise and deploy new machine learning apps. Get started here!",
              style: CVUFont.bodyText1.copyWith(color: Color(0xff999999)),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                Sticker(
                  icon: AppImages.memriSignFirst(height: 70),
                  title: "Connect and collect your data",
                  description:
                      "Import data from WhatsApp, Gmail or Instagram, create a custom importer, or upload data directly.",
                  buttonsTitle: ['Connect your services', 'Upload data'],
                  buttonsCallback: [() {}, () {}],
                ),
                Sticker(
                  icon: AppImages.memriSignSecond(height: 70),
                  title: "Build a machine learning app",
                  description:
                      "Select the datasource, label data, and build a ML model with just a few lines of code.",
                  buttonsTitle: ['Create a new dataset'],
                  buttonsCallback: [() {}],
                ),
                Sticker(
                  icon: AppImages.memriSignThird(height: 70),
                  title: "Add and edit UI live",
                  description:
                      "Add a user interface to your app using standard building blocks such as VStacks, HStacks, Text, and Buttons.",
                  buttonsTitle: ['Deploy your app'],
                  buttonsCallback: [() {}],
                ),
                Sticker(
                  icon: AppImages.memriSignFourth(height: 70),
                  title: "View documentation",
                  description:
                      "Learn everything you need to know about POD architecture, plugins, and imorters on our developer site. If you get stuck, join our community for help!",
                  buttonsTitle: ["Quick start guide", "Get support on Discord"],
                  buttonsCallback: [() {}, () {}],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
