//
// BottomBar.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../ViewContextController.dart';

/// This view contains the contents of the 'Bottom bar' which is shown below renderer content.
class BottomBarView extends StatelessWidget {
  final ViewContextController viewContext;

  final void Function() onSearchPressed;
  final void Function() onFilterButtonPressed;

  BottomBarView(
      {required this.viewContext,
      required this.onSearchPressed,
      required this.onFilterButtonPressed});

  String? get currentFilter => viewContext.searchString;

  @override
  Widget build(BuildContext context) {
    var filter = currentFilter;
    return Column(children: [
      Divider(),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Wrap(spacing: 4, children: [
            Wrap(spacing: 4, children: [
              ElevatedButton(
                onPressed: onFilterButtonPressed,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 7),
                        child: Icon(Icons.search),
                      ),
                      if (filter != null) Text(filter) //TODO style
                    ],
                  ),
                ),
              ),
              if (filter != null)
                ElevatedButton(
                    onPressed: () => viewContext.searchString = null,
                    child: Icon(Icons.clear)) //TODO style
            ]),
            Spacer(),
            ElevatedButton(
              onPressed: onFilterButtonPressed,
              child: Icon(Icons.menu),
            )
          ]))
    ]);
  }
}
