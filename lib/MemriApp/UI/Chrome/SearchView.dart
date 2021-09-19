//
// SearchView.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/material.dart';

import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';

import '../ViewContextController.dart';

/// This view is displayed when the user presses the search button
/// It moves itself to be above the keyboard automatically
class SearchView extends StatefulWidget {
  final ViewContextController viewContext;

  SearchView({required this.viewContext});

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.search,
          color: Color(0xffF0F0F0),
          size: 24,
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
                hintStyle: TextStyle(color: Color(0xff989898)),
                contentPadding: EdgeInsets.all(5)),
          ),
        ),
      ],
    );
  }
}
