import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/controllers/scene_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AppController appController = AppController.shared;
  Exception? authError;

  @override
  void initState() {
    SceneController.sceneController = SceneController();
    init();
    super.initState();
  }

  Future<void> init() async {
    try {
      await AppController.shared.init();
      SceneController.sceneController = SceneController();
      await AppController.shared.updateState();
      String route;
      switch (appController.state.value) {
        case AppState.authentication:
        case AppState.setup:
          route = Routes.onboarding;
          break;
        case AppState.keySaving:
          route = Routes.saveKeys;
          break;
        case AppState.authenticated:
          route = Routes.workspace;
          break;
      }
      RouteNavigator.navigateToRoute(context: context, route: route, clearStack: true);
    } on Exception catch (e) {
      authError = e;
      appController.state = AppState.authentication;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset("assets/images/logo.svg", height: 100),
          SizedBox(height: 30),
          SizedBox(
            child: LinearProgressIndicator(color: Color(0xffFE570F)),
            width: 150,
          ),
        ],
      ),
    );
  }
}
