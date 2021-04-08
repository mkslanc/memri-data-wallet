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
    Navigator.pushReplacement(
        _context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            body: widget,
          ),
        ));
    ;
  }

  late BuildContext _context;

  @override
  Widget build(BuildContext context) {
    _context = context;

    return Scaffold(
      body: Text("Welcome to Memri"), //TODO
    );
  }
}
