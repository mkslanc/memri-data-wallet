import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/AppController.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUFont.dart';
import 'package:memri/MemriApp/UI/Components/Button/PrimaryButton.dart';
import 'package:memri/MemriApp/UI/Setup/OnboardingDeveloper.dart';
import 'package:memri/MemriApp/UI/Setup/OnboardingLogin.dart';

import 'SetupScreenModel.dart';

class OnboardingStart extends StatefulWidget {
  const OnboardingStart() : super();

  @override
  State<OnboardingStart> createState() => _OnboardingStartState();
}

class _OnboardingStartState extends State<OnboardingStart> {
  AppController appController = AppController.shared;
  SetupScreenModel model = SetupScreenModel();
  final podUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints geom) => MaterialApp(
            color: Color(0xffE5E5E5),
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
                                "Hello, you.",
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
                              SizedBox(
                                height: 45,
                              ),
                              Row(
                                children: [
                                  PrimaryButton(
                                    onPressed: () async {
                                      await onAcknowledgedNewPodWarning();
                                    },
                                    child: Text("Create new account"),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(builder: (context) {
                                        return OnboardingLogin(
                                          model: model,
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
                                    onPressed: () async {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(builder: (context) {
                                        return OnboardingDeveloper(
                                          model: model,
                                        );
                                      }));
                                    },
                                    child: Text(
                                      "Switch to developers mode",
                                      style: CVUFont.buttonLabel.copyWith(color: Color(0xff989898)),
                                    ),
                                    style: TextButton.styleFrom(backgroundColor: null),
                                  ),
                                ],
                              ),
                              if (model.state == PodSetupState.error)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: Text(
                                    "Error: ${model.errorString}",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (model.state == PodSetupState.loading) ...[
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

  Future<void> onAcknowledgedNewPodWarning() async {
    await handleSetup(false);
  }

  void handleCompletion(Exception? error) {
    if (error != null) {
      setState(() {
        model.state = PodSetupState.error;
        model.errorString = "${error.toString()}";
      });
    } else {
      setState(() => model.state = PodSetupState.idle);
    }
  }

  handleSetup(bool localOnly) async {
    setState(() => model.state = PodSetupState.loading);
    var config = model.getSetupConfig(localOnly);

    if (config == null) {
      handleCompletion(null);
      return;
    }
    await appController.setupApp(
        config: config, useDemoData: model.useDemoData, onCompletion: handleCompletion);
  }
}
