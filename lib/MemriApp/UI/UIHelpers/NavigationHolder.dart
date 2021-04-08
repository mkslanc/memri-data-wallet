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

class MemriUINavigationController extends StatelessWidget {
  setViewControllers(Widget widget) {
    Navigator.pushReplacement(_context, MaterialPageRoute(
      builder: (context) {
        _context = context;
        return Scaffold(
          body: widget,
        );
      },
    ));
    ;
  }

  late BuildContext _context; //TODO this doesn't seem nice, should review

  @override
  Widget build(BuildContext context) {
    _context = context;

    return Scaffold(
      body: Center(
        child: Text("Welcome to Memri"),
      ), //TODO
    );
  }
}
