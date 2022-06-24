import 'package:flutter/material.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/core/controllers/app_controller.dart';
import 'package:memri/core/models/pod_setup.dart';
import 'package:memri/core/services/mixpanel_analytics_service.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/utilities/helpers/responsive_helper.dart';
import 'package:memri/widgets/scaffold/account_scaffold.dart';

class LoginScreen extends StatefulWidget {
  final bool isDevelopersMode;

  LoginScreen({this.isDevelopersMode = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AppController appController = AppController.shared;
  final podPublicKeyController = TextEditingController();
  final podDatabaseKeyController = TextEditingController();

  @override
  void initState() {
    podPublicKeyController.addListener(_setPodPublicKey);
    podDatabaseKeyController.addListener(_setPodDatabaseKey);
    appController.model.setupAsNewPod = false;
    appController.model.podURL = app.settings.defaultPodURL;
    appController.model.state = PodSetupState.idle;
    appController.model.errorString = null;
    super.initState();
  }

  @override
  void dispose() {
    podPublicKeyController.dispose();
    podDatabaseKeyController.dispose();
    super.dispose();
  }

  void _setPodPublicKey() {
    setState(
        () => appController.model.podPublicKey = podPublicKeyController.text);
  }

  void _setPodDatabaseKey() {
    setState(() =>
        appController.model.podDatabaseKey = podDatabaseKeyController.text);
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
                        style: CVUFont.smallCaps
                            .copyWith(color: Color(0xff828282))),
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
                        style: CVUFont.smallCaps
                            .copyWith(color: Color(0xff828282))),
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
              SizedBox(height: 20),
              if (appController.model.state == PodSetupState.error)
                ErrorMessage(appController.model.errorString!),
              SizedBox(height: 20),
              TextButton(
                onPressed: handleSetup,
                style: primaryButtonStyle,
                child: Text("Log in"),
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
        ],
      ),
    );
  }

  Widget _buildNewAccountButton() {
    return InkWell(
      onTap: () {
        appController.model.setupAsNewPod = true;
        appController.model.state = PodSetupState.idle;
        appController.model.errorString = null;
        Navigator.of(context).pop();
      },
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
    appController.setupApp(
        onPodConnected: () => Navigator.of(context).pop(),
        onError: () {
          setState(() {});
        });
  }
}
