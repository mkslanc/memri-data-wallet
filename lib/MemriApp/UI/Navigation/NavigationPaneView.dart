import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

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
    return ColoredBox(
      color: Color(0xff543184),
      child: Column(
        children: [
          ColoredBox(
              color: Color(0xff532a84),
              child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
                  child: SizedBox(
                    height: 95,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () => setState(() => showSettings = true),
                            icon: Icon(
                              Icons.settings,
                              size: 22,
                              color: Color(0xffd9d2e9),
                            )),
                        SizedBox(
                          width: 20,
                        ),
                        Flexible(
                          child: TextFormField(
                            style: TextStyle(color: Color(0xff8a66bc)),
                            onChanged: (text) =>
                                setState(() => sceneController.navigationFilterText = text),
                            initialValue: sceneController.navigationFilterText,
                            decoration: InputDecoration(
                              hintText: "Search",
                              hintStyle: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.4)),
                              fillColor: Color.fromRGBO(0, 0, 0, 0.4),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ))),
          StreamBuilder(
            stream: sceneController.navigationItems,
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
                return Flexible(
                    child: ListView(padding: EdgeInsets.fromLTRB(0, 15, 0, 0), children: widgets));
              }
              return SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
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
  String targetViewName;

  Item(this.name, this.targetViewName);
}

class NavigationItemView extends StatelessWidget {
  final Item item;
  final SceneController sceneController;

  NavigationItemView({required this.item, required this.sceneController});

  @override
  Widget build(BuildContext context) {
    /*withAnimation { TODO:
          sceneController.navigationIsVisible = false
      }*/
    return ElevatedButton(
      onPressed: () => sceneController.navigateToNewContext(
          clearStack: true, animated: false, viewName: item.targetViewName),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 35),
        child: Text(
          item.name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: Colors.white70),
        ),
      ),
      style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) return Colors.white12;
          return Colors.white12; //TODO:
        },
      )),
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
          )
        ],
      ),
    );
  }
}
