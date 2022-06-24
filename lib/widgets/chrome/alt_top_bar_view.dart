// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/material.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/core/controllers/page_controller.dart' as memri;
import 'package:memri/core/controllers/view_context_controller.dart';
import 'package:memri/core/cvu/cvu_action.dart';
import 'package:memri/core/models/cvu/cvu_value.dart';
import 'package:memri/core/models/cvu/cvu_value_constant.dart';
import 'package:memri/widgets/components/button/action_button.dart';

/// This view provides the 'navigation Bar' for the app interface
class AltTopBarView extends StatefulWidget {
  final memri.PageController pageController;

  AltTopBarView({required this.pageController});

  @override
  _TopBarViewState createState() => _TopBarViewState();
}

class _TopBarViewState extends State<AltTopBarView> {
  ViewContextController? viewContext;

  late Future<String?> title;

  Future<String?> get _title async {
    return await widget
            .pageController.topMostContext?.viewDefinitionPropertyResolver
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
    viewContext?.removeListener(updateState);
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
    viewContext?.removeListener(updateState);
    viewContext = widget.pageController.topMostContext;
    viewContext?.addListener(updateState);
    var actions =
        viewContext?.viewDefinitionPropertyResolver.actions("actionButton") ??
            [];
    actions.insert(
        0,
        CVUActionOpenCVUEditor(
            vars: {"title": CVUValueConstant(CVUConstantString("Script"))}));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 54,
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            if (actions.isNotEmpty && viewContext != null)
              ...actions.map((action) => ActionButton(
                    action: action,
                    viewContext: viewContext!
                        .getCVUContext(item: viewContext!.focusedItem),
                    pageController: widget.pageController,
                  )),
            TextButton(
              onPressed: () {
                widget.pageController.navigateBack();
              },
              child: Icon(
                Icons.close,
                color: Color(0xffDFDEDE),
              ),
            )
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: FutureBuilder(
              future: title,
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.hasData && snapshot.data != "") {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        snapshot.data!,
                        style: CVUFont.headline2,
                      ),
                      SizedBox(
                        height: 27,
                      ),
                    ],
                  );
                } else {
                  return Text("");
                }
              }),
        ),
      ],
    );
  }
}
