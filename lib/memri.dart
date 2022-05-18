import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/constants/app_themes.dart';
import 'package:memri/screens/not_found_screen.dart';

class Memri extends StatefulWidget {
  const Memri({Key? key}) : super(key: key);

  @override
  _MemriState createState() => _MemriState();
}

class _MemriState extends State<Memri> {
  @override
  void initState() {
    final router = FluroRouter();
    Routes.configureRoutes(router);
    RouteNavigator.router = router;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Memri",
      theme: lightTheme,
      onGenerateRoute: RouteNavigator.router.generator,
      onUnknownRoute: (_) => MaterialPageRoute(builder: (_) => NotFoundScreen()),
    );
  }
}
