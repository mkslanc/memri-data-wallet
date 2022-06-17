import 'package:flutter/material.dart';
import 'package:memri/constants/cvu/cvu_color.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/widgets/account_scaffold.dart';

import '../../widgets/empty.dart';

class OnboardingError extends StatefulWidget {
  const OnboardingError() : super();

  @override
  State<OnboardingError> createState() => _OnboardingErrorState();
}

class _OnboardingErrorState extends State<OnboardingError> {
  AppController appController = AppController.shared;

  @override
  Widget build(BuildContext context) {
    return AccountScaffold(showSlider: false, child: showCurrentError());
  }

  Widget showCurrentError() {
    switch (appController.state.value) {
      case AppState.incompatibleDevice:
        return OnboardingIncompatibleDeviceError();
      case AppState.incompatibleBrowser:
        return OnboardingIncompatibleBrowserError();
      case AppState.maintenance:
        return OnboardingMaintenance();
      default:
        return Empty();
    }
  }
}

class OnboardingIncompatibleDeviceError extends StatelessWidget {
  const OnboardingIncompatibleDeviceError() : super();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 113,
        ),
        Text(
          "Device not supported.",
          style: CVUFont.headline1.copyWith(color: CVUColor.brandOrange),
        ),
        SizedBox(
          height: 40,
        ),
        Text(
          "We are sorry but your device is not supported yet. Please try again on your computer.",
          style: CVUFont.bodyText1,
        ),
      ],
    );
  }
}

class OnboardingIncompatibleBrowserError extends StatelessWidget {
  const OnboardingIncompatibleBrowserError() : super();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 113,
        ),
        Text(
          "Browser not supported.",
          style: CVUFont.headline1.copyWith(color: CVUColor.brandOrange),
        ),
        SizedBox(
          height: 40,
        ),
        Text(
          "We are sorry but your browser is not supported yet. List of supported browsers: ",
          style: CVUFont.bodyText1,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
          child: RichText(
              text: TextSpan(style: CVUFont.headline4, children: [
            TextSpan(text: "• Chrome\n"),
            TextSpan(text: "• Firefox (in non private mode)\n"),
            TextSpan(text: "• Edge\n"),
            TextSpan(text: "• Brave")
          ])),
        )
      ],
    );
  }
}

class OnboardingMaintenance extends StatelessWidget {
  const OnboardingMaintenance() : super();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 113,
        ),
        Text(
          "We need a moment!",
          style: CVUFont.headline1,
        ),
        SizedBox(
          height: 40,
        ),
        Text(
          "We’re updating the app. It should be ready to use again shortly.",
          style: CVUFont.bodyText1,
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          "Please try again later.",
          style: CVUFont.bodyText1,
        )
      ],
    );
  }
}
