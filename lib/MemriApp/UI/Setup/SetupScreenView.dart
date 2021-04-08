//
// SetupWizard.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/AppController.dart';

import 'SetupScreenModel.dart';

/// This screen is displayed on the very first launch of the app. It allows the user to configure a connection to a pod (or a local demo)

class SetupScreenView extends StatefulWidget {
  @override
  _SetupScreenViewState createState() => _SetupScreenViewState();
}

class _SetupScreenViewState extends State<SetupScreenView> {
  AppController appController = AppController.shared;
  SetupScreenModel model = SetupScreenModel();
  var _showingNewPodWarning = false;

  _SetupScreenViewState();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints geom) => MaterialApp(
              home: Scaffold(
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
                                  //TODO hack to have another context, should be better way
                                  initialData: true,
                                  builder: (BuildContext context, snapshot) => Scaffold(
                                          body: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        // spacing: 10,
                                        // direction: Axis.vertical,
                                        // crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
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
                                          Wrap(
                                            direction: Axis.vertical,
                                            spacing: 6,
                                            children: [
                                              Text("Have a memri pod?"),
                                              ElevatedButton(
                                                  onPressed: () => Navigator.of(context).push(
                                                          MaterialPageRoute(builder: (context) {
                                                        return Scaffold(
                                                          appBar: AppBar(
                                                            title: Text('Pod setup'),
                                                          ),
                                                          body: podSetup,
                                                        );
                                                      })),
                                                  style: ElevatedButton.styleFrom(
                                                      primary: Colors.green,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10))),
                                                  child: Container(
                                                      width: MediaQuery.of(context).size.width - 40,
                                                      height: 50,
                                                      alignment: Alignment.center,
                                                      child: Text(
                                                        "Connect to pod",
                                                        style: TextStyle(
                                                          fontFamily: "headline",
                                                          color: Colors.white,
                                                        ),
                                                      ))),
                                            ],
                                          ),
                                          Padding(
                                              padding: EdgeInsets.only(top: 10),
                                              child: Wrap(
                                                direction: Axis.vertical,
                                                spacing: 6,
                                                children: [
                                                  Text("Just want to try the app?"),
                                                  ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                          primary: Colors.grey.shade800,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(10))),
                                                      onPressed: onLocalDemoPressed,
                                                      child: Container(
                                                          width: MediaQuery.of(context).size.width -
                                                              40,
                                                          height: 50,
                                                          alignment: Alignment.center,
                                                          child: Text(
                                                              "Let me try the app without a pod")))
                                                ],
                                              ))
                                        ],
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
        children: [
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
        ],
      ),
    );
  }

  void onConnectPressed() {
    if (model.setupAsNewPod) {
      setState(() {
        _showingNewPodWarning = true;
      });
    } else {
      handleSetup(false);
    }
  }

  void onLocalDemoPressed() {
    handleSetup(true);
  }

  void onAcknowledgedNewPodWarning() {
    handleSetup(false);
  }

  handleSetup(bool localOnly) {
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
    appController.setupApp(config, handleCompletion);
  }
}
