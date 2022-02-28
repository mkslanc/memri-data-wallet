import 'package:flutter/material.dart';
import 'package:memri/constants/app_settings.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/models/ui/setup_model.dart';
import 'package:memri/screens/setup/onboarding_developer.dart';
import 'package:memri/screens/setup/onboarding_login.dart';

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
    appController.initApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints geom) => Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(0, 22, 0, 0),
                  child: Container(
                    width: geom.maxWidth / 2,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 56, 30, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello, you.",
                            style: CVUFont.headline1,
                          ),
                          SizedBox(height: 30),
                          Text(
                            "This is a test version of memri pod.",
                            style: CVUFont.bodyText2,
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Unexpected errors, expected reactions, unknown turns taken, known karma striking back.",
                            style: CVUFont.bodyText2,
                          ),
                          SizedBox(height: 45),
                          Row(
                            children: [
                              TextButton(
                                onPressed: handleSetup,
                                style: primaryButtonStyle,
                                child: Text("Create new account"),
                              ),
                              SizedBox(width: 10),
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                    return OnboardingLogin();
                                  }));
                                },
                                child: Text(
                                  "Log into your pod",
                                  style: CVUFont.buttonLabel.copyWith(color: Color(0xff333333)),
                                ),
                                style: TextButton.styleFrom(backgroundColor: null),
                              ),
                              SizedBox(width: 30),
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => OnboardingDeveloper()));
                                },
                                child: Text(
                                  "Switch to developers mode",
                                  style: CVUFont.buttonLabel.copyWith(color: Color(0xff989898)),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: null,
                                ),
                              ),
                            ],
                          ),
                          if (appController.model.state == PodSetupState.error)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Text(
                                "Error: ${appController.model.errorString}",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (appController.model.state == PodSetupState.loading) ...[
                  SizedBox(
                      width: geom.maxWidth,
                      height: geom.maxHeight,
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
              ],
            ));
  }

  void handleSetup() {
    setState(() {
      appController.model.state = PodSetupState.loading;
      appController.model.podURL = AppSettings.defaultPodURL;
    });
    appController.setupApp();
  }
}
