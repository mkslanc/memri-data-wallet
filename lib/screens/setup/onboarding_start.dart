import 'package:flutter/material.dart';
import 'package:memri/constants/app_settings.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/models/pod_setup.dart';
import 'package:memri/screens/setup/onboarding_developer.dart';
import 'package:memri/screens/setup/onboarding_login.dart';
import 'package:memri/utils/responsive_helper.dart';
import 'package:memri/widgets/account_scaffold.dart';
import 'package:memri/widgets/empty.dart';

class OnboardingStart extends StatefulWidget {
  const OnboardingStart() : super();

  @override
  State<OnboardingStart> createState() => _OnboardingStartState();
}

class _OnboardingStartState extends State<OnboardingStart> {
  AppController appController = AppController.shared;
  final podUrlController = TextEditingController();

  @override
  void initState() {
    appController.model.setupAsNewPod = true;
    appController.model.podURL = AppSettings.defaultPodURL;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AccountScaffold(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 112),
              Text(
                "Hello, you.",
                style: CVUFont.headline1,
              ),
              SizedBox(height: 52),
              Text(
                "Welcome to Memri!",
                style: CVUFont.bodyText1,
              ),
              SizedBox(height: 20),
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
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => OnboardingLogin())),
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
                Text(
                  "Error: ${appController.model.errorString}",
                  style: TextStyle(color: Colors.red),
                ),
              if (!ResponsiveHelper(context).isLargeScreen)
                Padding(
                  padding: EdgeInsets.only(top: 90, bottom: 60),
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

  Widget _buildDeveloperButton() {
    return AppSettings.showDeveloperButton
        ? TextButton(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => OnboardingDeveloper())),
            child: Text(
              "Switch to developers mode",
              style: CVUFont.buttonLabel.copyWith(color: Color(0xff989898)),
            ),
            style: TextButton.styleFrom(
              backgroundColor: null,
              padding: EdgeInsets.all(0),
            ),
          )
        : Empty();
  }

  void handleSetup() {
    setState(() => appController.model.state = PodSetupState.loading);
    appController.setupApp();
  }
}
