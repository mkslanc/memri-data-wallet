//
// BottomBar.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Divider(),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: ColoredBox(
              color: CVUColor.system("secondarySystemBackground"),
              child: ValueListenableBuilder(
                  valueListenable: viewContext.searchStringNotifier,
                  builder: (BuildContext context, String? filter, Widget? child) => Row(
                          children: space(4, [
                        Row(
                            children: space(4, [
                          TextButton(
                            onPressed: onSearchPressed,
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                                child: ClipRect(
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 7),
                                        child: Icon(Icons.search),
                                      ),
                                      if (filter != null) Text(filter)
                                      //TODO style
                                    ],
                                  ),
                                )),
                          ),
                          if (filter != null)
                            TextButton(
                                onPressed: () => viewContext.searchString = null,
                                child: Icon(Icons.clear))
                          //TODO style
                        ])),
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: ClipRect(
                            child: TextButton(
                              onPressed: onFilterButtonPressed,
                              child: Icon(Icons.filter_list),
                            ),
                          ),
                        )
                      ])))))
    ]);
  }
}
