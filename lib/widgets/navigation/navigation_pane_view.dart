import 'package:flutter/material.dart';
import 'package:memri/screens/cvu_screen.dart';
import 'package:provider/provider.dart';

import '../../core/models/item.dart';
import '../../cvu/controllers/view_context_controller.dart';
import '../../providers/app_provider.dart';
import '../../screens/all_item_types_screen.dart';
import '../settings_pane.dart';
import '../space.dart';

/// This view is the main  NavigationPane. It lists NavigationItems and provides search functionality for this list.
class NavigationPaneView extends StatefulWidget {
  NavigationPaneView();

  @override
  _NavigationPaneViewState createState() => _NavigationPaneViewState();
}

class _NavigationPaneViewState extends State<NavigationPaneView> {
  bool showSettings = false;

  Widget build(BuildContext context) {
    return ColoredBox(
      color: Color(0xff543184),
      child: Column(
        children: [
          ColoredBox(
            color: Color(0xff532a84),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: SizedBox(
                height: 95,
                child: Row(
                      children: space(20, [
                    IconButton(
                      onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        useRootNavigator: true,
                        isScrollControlled: true,
                        builder: (BuildContext context) => SettingsPane(),
                      ),
                      icon: Icon(
                        Icons.settings,
                        size: 22,
                        color: Color(0xffd9d2e9),
                            )),
                    Flexible(
                      child: TextFormField(
                        style: TextStyle(color: Color(0xff8a66bc)),
                            onChanged: (text) =>
                                {} /*setState(() => sceneController.navigationFilterText = text)*/,
                            //initialValue: sceneController.navigationFilterText,
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 0.4)),
                          fillColor: Color.fromRGBO(0, 0, 0, 0.4),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      ),
                        )
                      ]),
            ),
                  ))),
          FutureBuilder(
            future: Provider.of<AppProvider>(context, listen: false)
                .podService
                .getNavigationItems(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error.toString());
                return Text(
                  "Error occurred",
                  style: TextStyle(color: Colors.red),
                );
              }
              if (snapshot.hasData) {
                List<Widget> widgets = [];
                List<Item> items = snapshot.data;
                widgets.add(NavigationItemView(title: "All item types", targetViewName:"", isCore: true,));
                items.forEach((navItem) {
                  var itemType = navItem.get("itemType");
                  switch (itemType) {
                    case "heading":
                      widgets.add(
                          NavigationHeadingView(title: navItem.get("title")));
                      break;
                    case "line":
                      widgets.add(NavigationLineView());
                      break;
                    default:
                      widgets.add(NavigationItemView(
                        title: navItem.get("title"),
                        targetViewName: navItem.get("sessionName"),
                        itemType: itemType,
                      ));
                  }
                });
                return Flexible(
                    child: ListView(
                        padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                        children: widgets));
              }
              return Padding(
                padding: EdgeInsets.all(20),
                child: SizedBox(
                  child: CircularProgressIndicator(),
                  width: 60,
                  height: 60,
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

abstract class NavigationElement {}

class NavigationElementItem extends NavigationElement {
  final NavigationItem value;

  NavigationElementItem(this.value);
}

class NavigationElementHeading extends NavigationElement {
  final String value;

  NavigationElementHeading(this.value);
}

class NavigationElementLine extends NavigationElement {}

class NavigationItem {
  String name;
  String targetViewName;

  NavigationItem(this.name, this.targetViewName);
}

class NavigationItemView extends StatelessWidget {
  final String title;
  final String targetViewName;
  final String? itemType;

  final bool isCore;

  NavigationItemView(
      {required this.title,
      required this.targetViewName,
      this.isCore = false,
      this.itemType});

  @override
  Widget build(BuildContext context) {

    return TextButton(
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
          builder: (context) => isCore ? AllItemTypesScreen(
            viewContextController: ViewContextController.fromParams(viewName: "messageChannelView"),
          ) : CVUScreen(
            viewContextController: ViewContextController.fromParams(
              viewName: targetViewName,
              itemType: itemType
            ),
          ),
        ),(Route<dynamic> route) => false);
        Provider.of<AppProvider>(context, listen: false).toggleDrawer();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 35),
        child: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: Colors.white70),
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) return Colors.white12;
            return Colors.transparent;
          },
        ),
          alignment: Alignment.topLeft),
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
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          Divider(
            color: Colors.black,
            height: 1,
          )
        ],
      ),
    );
  }
}
