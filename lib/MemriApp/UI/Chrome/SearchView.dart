//
// SearchView.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../ViewContextController.dart';

/// This view is displayed when the user presses the search button
/// It moves itself to be above the keyboard automatically
class SearchView extends StatefulWidget {
  final ViewContextController viewContext;
  final ValueNotifier<bool> isActive;

  SearchView({required this.viewContext, required this.isActive});

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
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
                  Expanded(
                    child: TextFormField(
                      controller: TextEditingController(text: widget.viewContext.searchString),
                      onChanged: (value) => setState(() => widget.viewContext.searchString = value),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Search",
                      ),
                    ),
                  ),
                  IconButton(
                      icon: Icon(Icons.close), onPressed: () => widget.isActive.value = false)
                ],
              ))
        ],
      ),
    );
  }
}
