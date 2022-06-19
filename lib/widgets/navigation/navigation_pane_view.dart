import 'package:flutter/material.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/controllers/scene_controller.dart';
import 'package:memri/core/services/mixpanel_analytics_service.dart';
import 'package:memri/utils/app_helper.dart';
import 'package:memri/widgets/navigation/additional_navigation_view.dart';

/// This view is the main  NavigationPane. It lists NavigationItems and provides search functionality for this list.
class NavigationPaneView extends StatefulWidget {
  NavigationPaneView();

  @override
  _NavigationPaneViewState createState() => _NavigationPaneViewState();
}

class _NavigationPaneViewState extends State<NavigationPaneView> {
  bool showSettings = false;

  Widget build(BuildContext context) {
    SceneController.sceneController.setupObservations();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
            onPressed: () => AppController.shared.navigationIsVisible.value = false,
            child: app.icons.close()),
        SizedBox(
          height: 71,
        ),
        Expanded(child: AdditionalNavigationView())
      ],
    );
  }
}

abstract class NavigationElement {}

class NavigationElementItem extends NavigationElement {
  final Item value;

  NavigationElementItem(this.value);
}

class NavigationElementHeading extends NavigationElement {
  final String value;

  NavigationElementHeading(this.value);
}

class NavigationElementLine extends NavigationElement {}

class Item {
  String name;
  String? targetViewName;
  VoidCallback? callback;
  String? icon;

  Item({required this.name, this.targetViewName, this.callback, this.icon});
}

class NavigationItemView extends StatelessWidget {
  final Item item;
  final SceneController sceneController;
  final Color? textColor;

  NavigationItemView({required this.item, required this.sceneController, this.textColor});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        MixpanelAnalyticsService().logNavigationButton(item.name);
        if (item.callback != null) item.callback!();
        if (item.targetViewName != null) {
          sceneController.exitEditMode();
          sceneController.navigateToNewContext(
              clearStack: true,
              animated: false,
              viewName: item.targetViewName,
              clearPageControllers: true);
          AppController.shared.navigationIsVisible.value = false;
        }
      },
      child: Text(item.name, style: CVUFont.bodyText1.copyWith(color: textColor)),
    );
  }
}

class NavigationHeadingView extends StatelessWidget {
  final String? title;

  NavigationHeadingView({this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            child: Text(
              title?.toUpperCase() ?? "",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff8c73af)),
            )),
        Spacer()
      ],
    );
  }
}

class NavigationLineView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Divider(
            color: Color(0xffF0F0F0),
            height: 1,
          )
        ],
      ),
    );
  }
}
