import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/constants/app_settings.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/controllers/scene_controller.dart';
import 'package:moor/moor_web.dart';

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
      if (AppSettings.maintenanceInProgress) {
        appController.state = AppState.maintenance;
      } else if (isMobile) {
        appController.state = AppState.incompatibleDevice;
      } else if (!await isSupportedBrowser) {
        appController.state = AppState.incompatibleBrowser;
      } else {
        await AppController.shared.init();
        await AppController.shared.updateState();
        // if (widget.predefinedKey != null)
        //   await AppController.shared.setupApp(predefinedKey: widget.predefinedKey);
      }

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
        case AppState.incompatibleDevice:
        case AppState.incompatibleBrowser:
        case AppState.maintenance:
        route = Routes.accountError;
        break;
      }
      RouteNavigator.navigateToRoute(context: context, route: route, clearStack: true);
    } on Exception catch (e) {
      authError = e;
      appController.state = AppState.authentication;
    }
  }

  bool get isMobile {
    final isNonDesktop = kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
    final data = MediaQueryData.fromWindow(WidgetsBinding.instance!.window);
    return isNonDesktop || data.size.shortestSide < 600;
  }

  Future<bool> get isSupportedBrowser async {
    var deviceInfo = DeviceInfoPlugin();
    var webBrowserInfo = await deviceInfo.webBrowserInfo;
    var supportedBrowser = webBrowserInfo.browserName == BrowserName.chrome ||
        webBrowserInfo.browserName == BrowserName.firefox ||
        webBrowserInfo.browserName == BrowserName.edge;
    return await MoorWebStorage.supportsIndexedDb() && supportedBrowser;
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
