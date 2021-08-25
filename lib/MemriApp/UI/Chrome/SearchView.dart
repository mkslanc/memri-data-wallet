//
// SearchView.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';

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
    return Column(
      children: [
        SizedBox(
          height: 80,
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: TextButton(
                    style:
                        TextButton.styleFrom(padding: EdgeInsets.all(27), primary: CVUColor.blue),
                    child: Icon(Icons.arrow_back),
                    onPressed: () {
                      widget.isActive.value = false;
                      widget.viewContext.searchString = null;
                    }),
              ),
              Expanded(
                child: TextFormField(
                  onChanged: (value) =>
                      setState(() => widget.viewContext.searchString = value.nullIfBlank),
                  initialValue: widget.viewContext.searchString,
                  decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: "Search",
                      contentPadding: EdgeInsets.all(5)),
                ),
              ),
              SizedBox(
                  width: 80,
                  child: Icon(
                    Icons.search,
                    color: CVUColor.blue,
                    size: 24,
                  )),
            ],
          ),
        ),
        Divider(
          height: 1,
        ),
      ],
    );
  }
}
