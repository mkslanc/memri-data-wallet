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
  var model = ValueNotifier<SetupScreenModel>(SetupScreenModel());
  var _showingNewPodWarning = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.green),
      themeMode: ThemeMode.dark,
      home: Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: Wrap(
            spacing: 10,
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Wrap(
                direction: Axis.vertical,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: -10,
                children: [
                  Text("Welcome to",
                      style: TextStyle(
                          fontFamily: "system", fontSize: 20, fontWeight: FontWeight.w100)),
                  Text("memri",
                      style: TextStyle(
                          fontSize: 60, fontWeight: FontWeight.bold, color: Colors.purple))
                ],
              ),
              Text("A place where your data belongs to you.", textAlign: TextAlign.center),
              SizedBox(height: 30),
              Wrap(
                direction: Axis.vertical,
                spacing: 6,
                children: [
                  Text("Have a memri pod?"),
                  ElevatedButton(
                      onPressed: () =>
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return Scaffold(
                                appBar: AppBar(
                                  title: Text('Pod setup'),
                                ),
                                body: Text("Pod setup(TODO)"));
                          })),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
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
                              shape:
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          onPressed: () => null,
                          child: Container(
                              width: MediaQuery.of(context).size.width - 40,
                              height: 50,
                              alignment: Alignment.center,
                              child: Text("Let me try the app without a pod")))
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  TextStyle get captionFont {
    //TODO
    return TextStyle(fontWeight: FontWeight.bold, fontFamily: "caption"); //TODO
  }

  Widget get podSetup => Form(
          child: Column(
        children: [
          CupertinoFormSection(header: Text("Connection Details"), children: [
            Wrap(
              direction: Axis.vertical,
              spacing: 2,
              children: [
                Text("Pod URL", style: captionFont), //TODO
                TextField()
              ],
            )
          ])
        ],
      ));
}
