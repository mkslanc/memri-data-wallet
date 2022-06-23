import 'package:flutter/material.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/core/services/mixpanel_analytics_service.dart';
import 'package:memri/models/pod_setup.dart';
import 'package:memri/utils/app_helper.dart';
import 'package:memri/utils/responsive_helper.dart';
import 'package:memri/widgets/components/error_message.dart';
import 'package:memri/widgets/empty.dart';
import 'package:memri/widgets/scaffold/account_scaffold.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen() : super();

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  AppController appController = AppController.shared;

  @override
  void initState() {
    appController.model.setupAsNewPod = true;
    appController.model.podURL = app.settings.defaultPodURL;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: appController.state,
      builder: (BuildContext context, AppState value, Widget? child) {
        switch (value) {
          case AppState.authentication:
          case AppState.setup:
            return _buildBody();
          case AppState.keySaving:
            WidgetsBinding.instance!.addPostFrameCallback(
                (_) => RouteNavigator.navigateToRoute(context: context, route: Routes.saveKeys));
            return Empty();
          case AppState.authenticated:
            WidgetsBinding.instance!.addPostFrameCallback(
                (_) => RouteNavigator.navigateToRoute(context: context, route: Routes.workspace));
            return Empty();
          case AppState.incompatibleDevice:
          case AppState.incompatibleBrowser:
          case AppState.maintenance:
            WidgetsBinding.instance!.addPostFrameCallback((_) =>
                RouteNavigator.navigateToRoute(context: context, route: Routes.accountError));
            return Empty();
        }
      },
    );
  }

  Widget _buildDeveloperButton() {
    if (!app.settings.showDeveloperButton) {
      return Empty();
    }
    return InkWell(
      onTap: () async {
        WidgetsBinding.instance!.addPostFrameCallback(
            (_) => RouteNavigator.navigateToRoute(context: context, route: Routes.loginDev));
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "Switch to ",
              style: CVUFont.buttonLabel.copyWith(color: Color(0xff989898)),
            ),
            TextSpan(
              text: "developers mode",
              style: CVUFont.buttonLabel.copyWith(color: Color(0xffFE570F)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return AccountScaffold(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 112),
              Text(
                "Hi there!",
                style: CVUFont.headline1,
              ),
              SizedBox(height: 62),
              Text(
                "Welcome to Memri!",
                style: CVUFont.bodyText1,
              ),
              SizedBox(height: 15),
              Text(
                "Please create a new POD account or log into your existing account.",
                style: CVUFont.bodyText1,
              ),
              SizedBox(height: 45),
              Wrap(
                children: [
                  TextButton(
                    onPressed: handleSetup,
                    style: primaryButtonStyle,
                    child: Text("Create account"),
                  ),
                  SizedBox(width: 30),
                  TextButton(
                    onPressed: () => WidgetsBinding.instance!.addPostFrameCallback((_) =>
                        RouteNavigator.navigateToRoute(context: context, route: Routes.login)),
                    child: Text(
                      "Log in",
                      style: CVUFont.buttonLabel.copyWith(color: Color(0xff333333)),
                    ),
                    style: TextButton.styleFrom(backgroundColor: null),
                  ),
                ],
              ),
              SizedBox(height: 30),
              if (appController.model.state == PodSetupState.error)
                ErrorMessage(appController.model.errorString!),
              if (!ResponsiveHelper(context).isLargeScreen)
                Padding(
                  padding: EdgeInsets.only(top: 60, bottom: 40),
                  child: _buildDeveloperButton(),
                ),
            ],
          ),
          if (ResponsiveHelper(context).isLargeScreen)
            Positioned(
              bottom: 61,
              child: _buildDeveloperButton(),
            ),
        ],
      ),
    );
  }

  void handleSetup() {
    MixpanelAnalyticsService().logSignUpTime();
    setState(() => appController.model.state = PodSetupState.loading);
    appController.setupApp();
  }
}
