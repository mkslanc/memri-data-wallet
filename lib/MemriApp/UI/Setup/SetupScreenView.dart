//
// SetupWizard.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/AppController.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import 'SetupScreenModel.dart';

/// This screen is displayed on the very first launch of the app. It allows the user to configure a connection to a pod (or a local demo)

class SetupScreenView extends StatefulWidget {
  @override
  _SetupScreenViewState createState() => _SetupScreenViewState();
}

class _SetupScreenViewState extends State<SetupScreenView> {
  AppController appController = AppController.shared;
  SetupScreenModel model = SetupScreenModel();

  _SetupScreenViewState();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints geom) => MaterialApp(
              home: Scaffold(
                resizeToAvoidBottomInset: false,
                body: Stack(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Expanded(
                            child: MaterialApp(
                              darkTheme: ThemeData(
                                  brightness: Brightness.dark, primarySwatch: Colors.green),
                              themeMode: ThemeMode.dark,
                              home: FutureBuilder(
                                  initialData: true,
                                  builder: (BuildContext context, snapshot) => Scaffold(
                                          body: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: space(10, [
                                          Wrap(
                                            direction: Axis.vertical,
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            spacing: -10,
                                            children: [
                                              Text("Welcome to",
                                                  style: TextStyle(
                                                      fontFamily: "system",
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.w100)),
                                              Text("memri",
                                                  style: TextStyle(
                                                      fontSize: 60,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.purple))
                                            ],
                                          ),
                                          Text("A place where your data belongs to you.",
                                              textAlign: TextAlign.center),
                                          SizedBox(height: 30),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: space(
                                                  6,
                                                  [
                                                    Text("Have a memri pod?"),
                                                    ElevatedButton(
                                                        onPressed: () => Navigator.of(context).push(
                                                                MaterialPageRoute(
                                                                    builder: (context) {
                                                              return Scaffold(
                                                                resizeToAvoidBottomInset: false,
                                                                appBar: AppBar(
                                                                  title: Text('Pod setup'),
                                                                ),
                                                                body: podSetup,
                                                              );
                                                            })),
                                                        style: ElevatedButton.styleFrom(
                                                          minimumSize: Size.fromHeight(50),
                                                          primary: Colors.green,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(10)),
                                                        ),
                                                        child: Text(
                                                          "Connect to pod",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        )),
                                                  ],
                                                  Axis.vertical),
                                            ),
                                          ),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(top: 10, left: 5.0, right: 5.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: space(
                                                    6,
                                                    [
                                                      Text("Just want to try the app?"),
                                                      ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                              minimumSize: Size.fromHeight(50),
                                                              primary: Colors.grey.shade800,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(10))),
                                                          onPressed: onLocalDemoPressed,
                                                          child: Text(
                                                              "Let me try the app without a pod"))
                                                    ],
                                                    Axis.vertical),
                                              ))
                                        ]),
                                      ))),
                            ),
                          )
                        ],
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
                ),
              ),
            ));
  }

  TextStyle get captionFont {
    //TODO
    return TextStyle(fontWeight: FontWeight.bold, fontFamily: "caption"); //TODO
  }

  Widget get podSetup => Form(
          child: SingleChildScrollView(
        child: Column(
          children: [
            CupertinoFormSection(
                header: Text(
                  "Connection Details",
                  textAlign: TextAlign.left,
                ),
                children: [
                  TextFormField(
                    controller: TextEditingController(text: model.podURL),
                    onChanged: (value) => setState(() => model.podURL = value),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Pod URL",
                      labelStyle: captionFont,
                      hintText: model.defaultPodURL,
                    ),
                  ),
                ]),
            CupertinoFormSection(
              header: Text(
                "Pod setup",
                textAlign: TextAlign.left,
              ),
              footer: model.setupAsNewPod ? connectButton : null,
              children: [
                Switch(
                  value: model.setupAsNewPod,
                  onChanged: (bool isOn) {
                    setState(() {
                      model.setupAsNewPod = isOn;
                    });
                  },
                ),
                Text(
                  "If enabled this will create new authentication keys and install the demo data.",
                  style: captionFont,
                )
              ],
            ),
            if (!model.setupAsNewPod)
              CupertinoFormSection(
                header: Text(
                  "Authentication",
                ),
                footer: !model.setupAsNewPod ? connectButton : null,
                children: [
                  TextFormField(
                    controller: TextEditingController(text: model.podPublicKey),
                    onChanged: (value) => setState(() => model.podPublicKey = value),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Public Key",
                      labelStyle: captionFont,
                      hintText: "publickey",
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: TextEditingController(text: model.podPrivateKey),
                    onChanged: (value) => setState(() => model.podPrivateKey = value),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Private Key",
                      labelStyle: captionFont,
                      hintText: "privatekey",
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: TextEditingController(text: model.podDatabaseKey),
                    onChanged: (value) => setState(() => model.podDatabaseKey = value),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Database Key",
                      labelStyle: captionFont,
                      hintText: "databasekey",
                    ),
                  ),
                ],
              ),
          ],
        ),
      ));

  Widget get connectButton {
    return Padding(
      padding: EdgeInsets.only(top: 10 /*TODO*/),
      child: Column(
        children: space(10, [
          if (model.state == PodSetupState.error)
            Text(
              "Error connecting to pod: ${model.errorString}",
              style: TextStyle(color: Colors.red),
            ),
          if (!model.isValidToProceedToConnect)
            Text(
              "You must provide the public, private, and database key to connect to an existing pod.",
              style: TextStyle(color: Colors.red),
            ),
          Center(
            child: ElevatedButton(
                onPressed: model.isValidToProceedToConnect ? onConnectPressed : null,
                child: Text("Connect to pod"),
                style: ElevatedButton.styleFrom(enableFeedback: model.isValidToProceedToConnect)),
          )
        ]),
      ),
    );
  }

  void onConnectPressed() async {
    if (model.setupAsNewPod) {
      setState(newPodWarning);
    } else {
      await handleSetup(false);
    }
  }

  void onLocalDemoPressed() async {
    await handleSetup(true);
  }

  Future<void> onAcknowledgedNewPodWarning() async {
    await handleSetup(false);
  }

  handleSetup(bool localOnly) async {
    setState(() => model.state = PodSetupState.loading);

    void handleCompletion(Exception? error) {
      if (error != null) {
        setState(() {
          model.state = PodSetupState.error;
          model.errorString = "$error";
        });
      } else {
        setState(() => model.state = PodSetupState.idle);
      }
    }

    var config = model.getSetupConfig(localOnly);

    if (config == null) {
      handleCompletion(null);
      return;
    }
    await appController.setupApp(config, handleCompletion);
  }

  void newPodWarning() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set up new pod'),
          content: Text("Are you sure you want to install demo data to your pod?"),
          actions: <Widget>[
            TextButton(
              child: Text('Set up as new pod'),
              onPressed: () async {
                Navigator.of(context).pop();
                await onAcknowledgedNewPodWarning();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
