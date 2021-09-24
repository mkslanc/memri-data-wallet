//
// BottomBar.swift
// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/PageController.dart' as memri;
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUFont.dart';
import 'package:memri/MemriApp/UI/FilterPanel/SimpleFilterPanel.dart';

import '../ViewContextController.dart';
import 'SearchView.dart';

/// This view provides the 'Navigation Bar' for the app interface
class TopBarView extends StatefulWidget {
  final memri.PageController pageController;

  TopBarView({required this.pageController});

  @override
  _TopBarViewState createState() => _TopBarViewState();
}

class _TopBarViewState extends State<TopBarView> {
  late ViewContextController? viewContext;
  late Future<String?> title;

  Future<String?> get _title async {
    return await widget.pageController.topMostContext?.viewDefinitionPropertyResolver
            .string("title") ??
        (viewContext?.focusedItem != null
            ? await viewContext!.itemPropertyResolver?.string("title")
            : "");
  }

  @override
  initState() {
    super.initState();
    title = _title;
    widget.pageController.addListener(updateState);
  }

  @override
  void dispose() {
    super.dispose();
    widget.pageController.removeListener(updateState);
  }

  void updateState() {
    setState(() {
      title = _title;
    });
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    title = _title;
  }

  @override
  Widget build(BuildContext context) {
    viewContext = widget.pageController.topMostContext;
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 60, 30, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
              future: title,
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data!,
                    style: CVUFont.headline2,
                  );
                } else {
                  return Text("");
                }
              }),
          SizedBox(
            height: 22,
          ),
          if (viewContext != null) ...[
            SizedBox(height: 78, child: SearchView(viewContext: viewContext!)),
            SimpleFilterPanel(viewContext: viewContext!)
          ]
        ],
      ),
    );
  }
}
