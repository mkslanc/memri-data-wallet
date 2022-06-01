import 'package:flutter/material.dart';
import 'package:memri/constants/app_settings.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/core/services/mixpanel_analytics_service.dart';
import 'package:memri/models/pod_setup.dart';
import 'package:memri/utils/responsive_helper.dart';
import 'package:memri/widgets/account_scaffold.dart';

class OnboardingLogin extends StatefulWidget {
  final bool isDevelopersMode;

  OnboardingLogin({this.isDevelopersMode = false});

  @override
  State<OnboardingLogin> createState() => _OnboardingLoginState();
}

class _OnboardingLoginState extends State<OnboardingLogin> {
  AppController appController = AppController.shared;
  final podPublicKeyController = TextEditingController();
  final podDatabaseKeyController = TextEditingController();

  @override
  void initState() {
    podPublicKeyController.addListener(_setPodPublicKey);
    podDatabaseKeyController.addListener(_setPodDatabaseKey);
    appController.model.setupAsNewPod = false;
    appController.model.podURL = AppSettings.defaultPodURL;
    super.initState();
  }

  @override
  void dispose() {
    podPublicKeyController.dispose();
    podDatabaseKeyController.dispose();
    super.dispose();
  }

  void _setPodPublicKey() {
    setState(() => appController.model.podPublicKey = podPublicKeyController.text);
  }

  void _setPodDatabaseKey() {
    setState(() => appController.model.podDatabaseKey = podDatabaseKeyController.text);
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
                "Log in to your pod",
                style: CVUFont.headline1,
              ),
              SizedBox(height: 62),
              Text(
                "Use your crypto keys to log in.",
                style: CVUFont.bodyText1,
              ),
              SizedBox(height: 20),
              Container(
                width: 632,
                height: 51,
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                color: Color(0xffF0F0F0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("your login key".toUpperCase(),
                        style: CVUFont.smallCaps.copyWith(color: Color(0xff828282))),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: podPublicKeyController,
                      decoration: InputDecoration.collapsed(
                        border: InputBorder.none,
                        hintText: "",
                      ),
                      style: TextStyle(color: Color(0xffFE570F), fontSize: 14),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: 632,
                height: 51,
                color: Color(0xffF0F0F0),
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("your password key".toUpperCase(),
                        style: CVUFont.smallCaps.copyWith(color: Color(0xff828282))),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: podDatabaseKeyController,
                      decoration: InputDecoration.collapsed(
                        border: InputBorder.none,
                        hintText: "",
                      ),
                      style: TextStyle(color: Color(0xffFE570F), fontSize: 13),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              TextButton(
                onPressed: handleSetup,
                style: primaryButtonStyle,
                child: Text("Log in"),
              ),
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
                  child: _buildNewAccountButton(),
                ),
            ],
          ),
          if (ResponsiveHelper(context).isLargeScreen)
            Positioned(
              bottom: 61,
              child: _buildNewAccountButton(),
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
        ],
      ),
    );
  }

  Widget _buildNewAccountButton() {
    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "Don’t have an account yet? ",
              style: CVUFont.buttonLabel.copyWith(color: Color(0xff989898)),
            ),
            TextSpan(
              text: "Create a new one!",
              style: CVUFont.buttonLabel.copyWith(color: Color(0xffFE570F)),
            ),
          ],
        ),
      ),
    );
  }

  void handleSetup() {
    MixpanelAnalyticsService().logSignIn(podPublicKeyController.text);
    setState(() => appController.model.state = PodSetupState.loading);
    appController.setupApp(onPodConnected: () => Navigator.of(context).pop());
  }
}
