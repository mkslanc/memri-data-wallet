import 'package:flutter/material.dart';

class NavigationHolder extends StatelessWidget {
  final MemriUINavigationController controller;

  NavigationHolder(this.controller);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: controller,
    ));
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
          body: widget,
        );
      },
    ));
  }

  BuildContext? _context; //TODO this doesn't seem nice, should review

  @override
  Widget build(BuildContext context) {
    _context = context;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: childWidget,
    );
  }
}
