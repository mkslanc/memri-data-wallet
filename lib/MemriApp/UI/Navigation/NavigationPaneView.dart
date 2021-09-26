import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUValue_Constant.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUViewArguments.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';
import 'package:memri/MemriApp/UI/UIHelpers/FactoryReset.dart';

/// This view is the main  NavigationPane. It lists NavigationItems and provides search functionality for this list.
class NavigationPaneView extends StatefulWidget {
  final SceneController sceneController;

  NavigationPaneView({required this.sceneController});

  @override
  _NavigationPaneViewState createState() => _NavigationPaneViewState(sceneController);
}

class _NavigationPaneViewState extends State<NavigationPaneView> {
  SceneController sceneController;

  _NavigationPaneViewState(this.sceneController);

  //@ObservedObject var keyboardResponder = KeyboardResponder.shared

  bool showSettings = false;

  Widget build(BuildContext context) {
    sceneController.setupObservations();
    return ColoredBox(
      color: Colors.white,
      child: Column(
        children: [
          FutureBuilder(
            future: sceneController.navigationItems,
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
                var items = snapshot.data;
                items.forEach((navItem) {
                  if (navItem is NavigationElementItem) {
                    var item = navItem.value;
                    widgets.add(NavigationItemView(item: item, sceneController: sceneController));
                  } else if (navItem is NavigationElementHeading) {
                    var title = navItem.value;
                    widgets.add(NavigationHeadingView(title: title));
                  } else {
                    widgets.add(NavigationLineView());
                  }
                });
                return Expanded(
                  child: Column(
                    children: [
                      NavigationItemView(
                        item: Item(name: "Add items", targetViewName: "adding", icon: "plus"),
                        sceneController: sceneController,
                        textColor: Colors.black,
                      ),
                      NavigationLineView(),
                      Expanded(child: Column(children: widgets)),
                      NavigationLineView(),
                      NavigationItemView(
                          item: Item(
                              name: "Apps and Plugins", targetViewName: "allPlugins", icon: "zap"),
                          sceneController: sceneController),
                      /* NavigationItemView(
                          item:
                              Item(name: "Settings", targetViewName: "settings", icon: "settings"),
                          sceneController: sceneController),*/ //TODO: we don't have settings right now
                      NavigationLineView(),
                      NavigationItemView(
                          item: Item(
                              name: "Logout",
                              callback: () => factoryReset(context),
                              icon: "log-out"),
                          sceneController: sceneController),
                    ],
                  ),
                );
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
      onPressed: item.targetViewName != null
          ? () {
              sceneController.navigateToNewContext(
                  clearStack: true, animated: false, viewName: item.targetViewName);
              if (item.targetViewName == "home") {
                //TODO: hardcoded part, due to uncertainty of ruling two different pages on the same time
                sceneController.navigateToNewContext(
                    clearStack: true,
                    animated: false,
                    viewName: "updates",
                    viewArguments: CVUViewArguments(
                        args: {"mainView": CVUValueConstant(CVUConstantBool(false))}));
              }
              sceneController.navigationIsVisible.value = false;
            }
          : item.callback,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 17, horizontal: 34),
        child: Center(
          child: item.icon != null
              ? SvgPicture.asset(
                  "assets/images/" + item.icon! + ".svg",
                  color: textColor != null ? textColor : Color(0xff989898),
                  semanticsLabel: item.name,
                )
              : Text(
                  item.name.capitalizingFirst(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: textColor),
                ),
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
