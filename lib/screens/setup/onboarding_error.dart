import 'package:flutter/material.dart';
import 'package:memri/constants/cvu/cvu_color.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/widgets/account_scaffold.dart';

class OnboardingError extends StatefulWidget {
  const OnboardingError() : super();

  @override
  State<OnboardingError> createState() => _OnboardingErrorState();
}

class _OnboardingErrorState extends State<OnboardingError> {
  AppController appController = AppController.shared;

  @override
  Widget build(BuildContext context) {
    print(appController.state);
    return AccountScaffold(
      showSlider: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 113,
          ),
          Text(
            appController.state.value == AppState.incompatibleDevice
                ? "Device not supported."
                : "Browser not supported",
            style: CVUFont.headline1.copyWith(color: CVUColor.brandOrange),
          ),
          SizedBox(
            height: 40,
          ),
          Text(
            appController.state.value == AppState.incompatibleDevice
                ? "We are sorry but your device is not supported yet. Please try again on your computer."
                : "We are sorry but your browser is not supported yet. List of supported browsers: ",
            style: CVUFont.bodyText1,
          ),
          if (appController.state.value == AppState.incompatibleBrowser)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
              child: RichText(
                  text: TextSpan(style: CVUFont.headline4, children: [
                TextSpan(text: "• Chrome\n"),
                TextSpan(text: "• Firefox (in non private mode)\n"),
                TextSpan(text: "• Edge")
              ])),
            )
        ],
      ),
    );
  }
}
