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
    return Column(
      children: [
        Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => sceneController.navigationIsVisible.value = true,
                  icon: Icon(Icons.dehaze),
                ),
                if (sceneController.canNavigateBack)
                  IconButton(
                    onPressed: () => sceneController.navigateBack(),
                    icon: Icon(Icons.arrow_back),
                  )
              ],
            ),
            FutureBuilder(
                future:
                    sceneController.topMostContext?.viewDefinitionPropertyResolver.string("title"),
                builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data!);
                  } else {
                    return SizedBox.shrink(); //TODO Spacer?
                  }
                })
          ],
        ),
        Divider()
      ],
    );
  }
}
