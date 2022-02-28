import 'package:flutter/material.dart';
import 'package:memri/constants/app_styles.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:memri/models/ui/setup_model.dart';

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
    super.initState();
    podPublicKeyController.addListener(_setPodPublicKey);
    podDatabaseKeyController.addListener(_setPodDatabaseKey);
  }

  @override
  void dispose() {
    super.dispose();
    podPublicKeyController.dispose();
    podDatabaseKeyController.dispose();
  }

  void _setPodPublicKey() {
    setState(() => appController.model.podPublicKey = podPublicKeyController.text);
  }

  void _setPodDatabaseKey() {
    setState(() => appController.model.podDatabaseKey = podDatabaseKeyController.text);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints geom) => Material(
              child: Stack(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.fromLTRB(0, 22, 0, 0),
                    child: Container(
                      width: geom.maxWidth / 2,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(30, 56, 150, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Oh, you’re back! What a surprise!",
                              style: CVUFont.headline2,
                            ),
                            SizedBox(height: 30),
                            Text(
                              "To log in please provide these long random numbers no human would ever use that we asked you to save in a safe space when you created the account.",
                              style: CVUFont.bodyText2,
                            ),
                            SizedBox(height: 45),
                            SizedBox(
                              width: 428,
                              child: ColoredBox(
                                color: Color(0xffF0F0F0),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("your login key".toUpperCase(),
                                          style:
                                              CVUFont.smallCaps.copyWith(color: Color(0xff828282))),
                                      SizedBox(height: 3),
                                      TextFormField(
                                        controller: podPublicKeyController,
                                        decoration: InputDecoration.collapsed(
                                          border: InputBorder.none,
                                          hintText: "",
                                        ),
                                        style: TextStyle(color: Color(0xffFE570F), fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              width: 428,
                              child: ColoredBox(
                                color: Color(0xffF0F0F0),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("your password key".toUpperCase(),
                                          style:
                                              CVUFont.smallCaps.copyWith(color: Color(0xff828282))),
                                      SizedBox(height: 3),
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
                              ),
                            ),
                            SizedBox(height: 45),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => handleSetup(),
                                  style: primaryButtonStyle,
                                  child: Text("Engage!"),
                                ),
                                SizedBox(width: 10),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    "Cancel",
                                    style: CVUFont.buttonLabel.copyWith(color: Color(0xff333333)),
                                  ),
                                  style: TextButton.styleFrom(backgroundColor: null),
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
              ),
            ));
  }

  void handleSetup() {
    setState(() {
      appController.model.setupAsNewPod = false;
      appController.model.state = PodSetupState.loading;
    });
    appController.setupApp();
  }
}
