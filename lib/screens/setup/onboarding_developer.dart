import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memri/constants/app_settings.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/models/pod_setup.dart';
import 'package:memri/screens/setup/onboarding_login.dart';
import 'package:memri/utils/responsive_helper.dart';
import 'package:memri/widgets/account_scaffold.dart';

class OnboardingDeveloper extends StatefulWidget {
  OnboardingDeveloper();

  @override
  State<OnboardingDeveloper> createState() => _OnboardingDeveloperState();
}

class _OnboardingDeveloperState extends State<OnboardingDeveloper> {
  AppController appController = AppController.shared;
  final podUrlController = TextEditingController();

  @override
  void initState() {
    podUrlController.addListener(_setPodUrl);
    podUrlController.text = AppSettings.defaultDevPodURL;
    appController.isDevelopersMode = true;
    appController.model.setupAsNewPod = false;
    super.initState();
  }

  @override
  void dispose() {
    podUrlController.removeListener(_setPodUrl);
    super.dispose();
  }

  void _setPodUrl() {
    setState(() => appController.model.podURL = podUrlController.text);
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
                "Hello, dev!",
                style: CVUFont.headline1,
              ),
              SizedBox(height: 62),
              Text(
                "This is a test version of memri pod.",
                style: CVUFont.bodyText1,
              ),
              SizedBox(height: 15),
              Text(
                "Unexpected errors, expected reactions, unknown turns taken, known karma striking back.",
                style: CVUFont.bodyText1,
              ),
              SizedBox(height: 20),
              Container(
                width: 428,
                height: 46,
                color: Color(0xffF0F0F0),
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("pod address".toUpperCase(),
                        style: CVUFont.smallCaps.copyWith(color: Color(0xff828282))),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: podUrlController,
                      decoration: InputDecoration.collapsed(
                        border: InputBorder.none,
                        hintText: AppSettings.defaultPodURL,
                      ),
                      style: TextStyle(color: Color(0xffFE570F), fontSize: 13),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  CupertinoSwitch(
                      thumbColor: Colors.white,
                      trackColor: Color(0xffDFDEDE),
                      activeColor: Color(0xff333333),
                      value: appController.model.useDemoData,
                      onChanged: (value) =>
                          setState(() => appController.model.useDemoData = value)),
                  SizedBox(width: 10),
                  Text(
                    "Use demo database",
                    style: TextStyle(color: Color(0xff989898)),
                  ),
                ],
              ),
              SizedBox(height: 45),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 25,
                children: [
                  TextButton(
                    onPressed: () {
                      appController.model.setupAsNewPod = true;
                      handleSetup(false);
                    },
                    style: primaryButtonStyle,
                    child: Text("Create new account"),
                  ),
                  SizedBox(width: 30),
                  Wrap(
                    children: [
                      InkWell(
                        onTap: () async => Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => OnboardingLogin(isDevelopersMode: true))),
                        child: Text(
                          "Log into your Pod",
                          style: CVUFont.buttonLabel.copyWith(color: Color(0xff333333)),
                        ),
                      ),
                      SizedBox(width: 30),
                      Text("OR"),
                      SizedBox(width: 30),
                      InkWell(
                        onTap: () => handleSetup(true),
                        child: Text(
                          "Try without Pod",
                          style: CVUFont.buttonLabel.copyWith(color: Color(0xff989898)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30),
              if (appController.model.state == PodSetupState.error)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Text(
                    "Error: ${appController.model.errorString}",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              if (!ResponsiveHelper(context).isLargeScreen)
                Padding(
                  padding: EdgeInsets.only(top: 60, bottom: 40),
                  child: _buildSwitchModeButton(),
                ),
            ],
          ),
          if (appController.model.state == PodSetupState.loading) ...[
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: ColoredBox(color: Color.fromRGBO(0, 0, 0, 0.7))),
            Center(
              child: Column(
                children: [
                  Spacer(),
                  SizedBox(
                    child: CircularProgressIndicator(),
                    width: 60,
                    height: 60,
                  ),
                  Text(
                    "Setup in progress...",
                    style: TextStyle(color: Colors.white),
                  ),
                  Spacer()
                ],
              ),
            ),
          ],
          if (ResponsiveHelper(context).isLargeScreen)
            Positioned(
              bottom: 61,
              child: _buildSwitchModeButton(),
            ),
        ],
      ),
    );
  }

  Widget _buildSwitchModeButton() {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "Switch to ",
              style: CVUFont.buttonLabel.copyWith(color: Color(0xff989898)),
            ),
            TextSpan(
              text: "standard mode",
              style: CVUFont.buttonLabel.copyWith(color: Color(0xffFE570F)),
            ),
          ],
        ),
      ),
    );
  }

  void handleSetup(bool localOnly) {
    setState(() => appController.model.state = PodSetupState.loading);
    appController.setupApp(localOnly: localOnly, onPodConnected: () => Navigator.of(context).pop());
  }
}
