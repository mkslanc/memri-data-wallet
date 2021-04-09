//
// BottomBar.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

/// This view provides the 'Navigation Bar' for the app interface
class TopBarView extends StatelessWidget {
  final SceneController sceneController;

  TopBarView({required this.sceneController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        children: [
          ValueListenableBuilder(
            builder: (BuildContext context, bool value, Widget? child) {
              return ColoredBox(
                color: Color(0xfff2f2f7),
                child: Column(
                  children: [
                    SizedBox(
                      height: 60,
                      width: double.maxFinite,
                      child: Row(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: Wrap(
                                  children: [
                                    IconButton(
                                      onPressed: () =>
                                          sceneController.navigationIsVisible.value = true,
                                      icon: Icon(Icons.dehaze),
                                      padding: EdgeInsets.all(10),
                                    ),
                                    if (sceneController.canNavigateBack)
                                      IconButton(
                                        onPressed: () => sceneController.navigateBack(),
                                        icon: Icon(Icons.arrow_back),
                                      )
                                  ],
                                ),
                              )
                            ],
                          ),
                          FutureBuilder(
                              future: sceneController.topMostContext?.viewDefinitionPropertyResolver
                                  .string("title"),
                              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                                if (snapshot.hasData) {
                                  return Expanded(
                                      child: Center(
                                    child: Text(
                                      snapshot.data!,
                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                                    ),
                                  ));
                                } else {
                                  return SizedBox.shrink(); //TODO Spacer?
                                }
                              }),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: SizedBox(
                              width: 100,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
            valueListenable: sceneController.shouldUpdate,
          ),
          //Divider()
        ],
      ),
    );
  }
}
