import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/AppController.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUFont.dart';
import 'package:memri/MemriApp/UI/style/light.dart';
import 'package:memri/constants/app_settings.dart';

import 'OnboardingLogin.dart';
import 'SetupScreenModel.dart';

class OnboardingDeveloper extends StatefulWidget {
  final SetupScreenModel model;

  OnboardingDeveloper({required this.model});

  @override
  State<OnboardingDeveloper> createState() => _OnboardingDeveloperState();
}

class _OnboardingDeveloperState extends State<OnboardingDeveloper> {
  AppController appController = AppController.shared;
  final podUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    podUrlController.addListener(_setPodUrl);
    podUrlController.text = AppSettings.defaultDevPodURL;
  }

  @override
  void dispose() {
    super.dispose();
    podUrlController.removeListener(_setPodUrl);
  }

  void _setPodUrl() {
    setState(() => widget.model.podURL = podUrlController.text);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints geom) => MaterialApp(
            color: Color(0xffE5E5E5),
            theme: lightTheme,
            home: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Stack(
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
                                "Hello, dev.",
                                style: CVUFont.headline1,
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Text(
                                "This is a test version of memri pod.",
                                style: CVUFont.bodyText2,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "Unexpected errors, expected reactions, unknown turns taken, known karma striking back.",
                                style: CVUFont.bodyText2,
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                width: 428,
                                child: ColoredBox(
                                  color: Color(0xffF0F0F0),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Pod URL".toUpperCase(),
                                            style: CVUFont.smallCaps
                                                .copyWith(color: Color(0xff828282))),
                                        SizedBox(height: 3),
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
                                ),
                              ),
                              Row(
                                children: [
                                  Switch(
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: Color(0xffDFDEDE),
                                      activeTrackColor: Color(0xff333333),
                                      activeColor: Colors.white,
                                      value: widget.model.useDemoData,
                                      onChanged: (value) => setState(() {
                                            widget.model.useDemoData = value;
                                          })),
                                  Text(
                                    "Use demo database",
                                    style: TextStyle(color: Color(0xff989898)),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 45,
                              ),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      await onAcknowledgedNewPodWarning();
                                    },
                                    style: primaryButtonStyle,
                                    child: Text("Create new account"),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context)
                                          .pushReplacement(MaterialPageRoute(builder: (context) {
                                        return OnboardingLogin(
                                          model: widget.model,
                                          isDevelopersMode: true,
                                        );
                                      }));
                                    },
                                    child: Text(
                                      "Log into your pod",
                                      style: CVUFont.buttonLabel.copyWith(color: Color(0xff333333)),
                                    ),
                                    style: TextButton.styleFrom(backgroundColor: null),
                                  ),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      "Switch back regular mode",
                                      style: CVUFont.buttonLabel.copyWith(color: Color(0xff989898)),
                                    ),
                                    style: TextButton.styleFrom(backgroundColor: null),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                                child: Text("OR"),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: onLocalDemoPressed,
                                    child: Text(
                                      "Try without POD",
                                      style: CVUFont.buttonLabel.copyWith(color: Color(0xff989898)),
                                    ),
                                    style: TextButton.styleFrom(
                                        backgroundColor: null, minimumSize: Size(77, 36)),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                              if (widget.model.state == PodSetupState.error)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: Text(
                                    "Error: ${widget.model.errorString}",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (widget.model.state == PodSetupState.loading) ...[
                      SizedBox(
                          width: geom.maxWidth,
                          height: geom.maxHeight,
                          child: ColoredBox(
                            color: Color.fromRGBO(0, 0, 0, 0.7),
                          )),
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
                ))));
  }

  void onLocalDemoPressed() async {
    await handleSetup(true);
  }

  Future<void> onAcknowledgedNewPodWarning() async {
    await handleSetup(false);
  }

  void handleCompletion(Exception? error) {
    if (error != null) {
      setState(() {
        widget.model.state = PodSetupState.error;
        widget.model.errorString = "${error.toString()}";
      });
    } else {
      setState(() => widget.model.state = PodSetupState.idle);
      Navigator.pop(context);
    }
  }

  handleSetup(bool localOnly) async {
    setState(() => widget.model.state = PodSetupState.loading);
    var config = widget.model.getSetupConfig(localOnly);

    if (config == null) {
      handleCompletion(null);
      return;
    }
    appController.isDevelopersMode = true;
    await appController.setupApp(
        config: config, useDemoData: widget.model.useDemoData, onCompletion: handleCompletion);
  }
}
