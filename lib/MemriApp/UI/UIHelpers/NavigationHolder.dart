import 'package:flutter/material.dart';

class NavigationHolder extends StatelessWidget {
  MemriUINavigationController controller;

  NavigationHolder(this.controller);

  @override
  Widget build(BuildContext context) {
    return controller;
  }

/*func makeUIViewController(context: Context) -> MemriUINavigationController { TODO
        return controller
    }
    
    func updateUIViewController(_ navController: MemriUINavigationController, context: Context) {

    }*/
}

class MemriUINavigationController extends StatefulWidget {
  setViewControllers(List<Page> newPages) {
    print("My pages ${newPages.toString()}");
    // state.pages = newPages;
  }

  @override
  _MemriUINavigationControllerState createState() => _MemriUINavigationControllerState();
}

class _MemriUINavigationControllerState extends State<MemriUINavigationController> {
  List<Page> pages = [];

  setViewControllers(List<Page> newPages) {
    pages = newPages;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text("MemriUINavigationController");
  }
}
