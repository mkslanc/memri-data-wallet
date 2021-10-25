import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';
import 'package:memri/MemriApp/UI/style/light.dart';

class NavigationHolder extends StatelessWidget {
  final MemriUINavigationController controller;

  NavigationHolder(this.controller);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      debugShowCheckedModeBanner: false,
      home: controller,
    );
  }
}

// ignore: must_be_immutable
class MemriUINavigationController extends StatelessWidget {
  //TODO must_be_immutable
  Widget? childWidget;

  setViewControllers(Widget widget) {
    if (_context == null) {
      childWidget = widget;
      return;
    }
    Navigator.maybeOf(_context!)?.pushReplacement(MaterialPageRoute(
      builder: (context) {
        _context = context;
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: widget,
        );
      },
    ));
  }

  BuildContext? _context; //TODO this doesn't seem nice, should review

  @override
  Widget build(BuildContext context) {
    _context = context;

    return childWidget != null
        ? Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            body: childWidget,
          )
        : Empty();
  }
}
