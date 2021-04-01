//
// SearchView.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../ViewContextController.dart';

/// This view is displayed when the user presses the search button
/// It moves itself to be above the keyboard automatically
class SearchView extends StatelessWidget {
  ViewContextController viewContext;
  final ValueNotifier<bool> isActive;

  SearchView({required this.viewContext, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Divider(),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.search),
                  TextField(),
                  IconButton(icon: Icon(Icons.close), onPressed: () => isActive.value = false)
                ],
              ))
        ],
      ),
    );
  }
}
