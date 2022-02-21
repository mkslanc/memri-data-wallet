// Copyright © 2020 memri. All rights reserved.

import 'package:flutter/material.dart';
import 'package:memri/controllers/page_controller.dart' as memri;
import 'package:memri/controllers/view_context_controller.dart';
import 'package:memri/core/cvu/cvu_action.dart';
import 'package:memri/models/cvu/cvu_value.dart';
import 'package:memri/models/cvu/cvu_value_constant.dart';
import 'package:memri/widgets/chrome/bread_crumbs.dart';
import 'package:memri/widgets/components/button/action_button.dart';
import 'package:memri/widgets/filter_panel/simple_filter_panel.dart';

/// This view provides the 'navigation Bar' for the app interface
class TopBarView extends StatefulWidget {
  final memri.PageController pageController;

  TopBarView({required this.pageController});

  @override
  _TopBarViewState createState() => _TopBarViewState();
}

class _TopBarViewState extends State<TopBarView> {
  ViewContextController? viewContext;
  late Future<void> _init;

  Color? backgroundColor = Color(0xffF4F4F4);
  bool showEditCode = false;

  @override
  initState() {
    super.initState();
    _init = init();
    widget.pageController.addListener(updateState);
  }

  @override
  void dispose() {
    super.dispose();
    widget.pageController.removeListener(updateState);
  }

  void updateState() {
    _init = init();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init = init();
  }

  Future<void> init() async {
    viewContext = widget.pageController.topMostContext;

    backgroundColor =
        await viewContext?.viewDefinitionPropertyResolver.color("topBarColor") ?? Color(0xffF4F4F4);
    showEditCode =
        await viewContext?.viewDefinitionPropertyResolver.boolean("showEditCode") ?? true;
  }

  @override
  Widget build(BuildContext context) {
    var actions = viewContext?.viewDefinitionPropertyResolver.actions("actionButton") ?? [];

    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) => Container(
        height: 40,
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (viewContext != null) ...[
                SimpleFilterPanel(viewContext: viewContext!),
                BreadCrumbs(viewContext: viewContext!, pageController: widget.pageController),
                Spacer(),
                ...actions.map((action) => ActionButton(
                      action: action,
                      viewContext: viewContext!.getCVUContext(item: viewContext!.focusedItem),
                      pageController: widget.pageController,
                    )),
                if (showEditCode) ...[
                  ActionButton(
                    action: CVUActionOpenCVUEditor(
                        vars: {"title": CVUValueConstant(CVUConstantString("Code  >_"))}),
                    viewContext: viewContext!.getCVUContext(item: viewContext!.focusedItem),
                    pageController: widget.pageController,
                  )
                ]
              ]
            ],
          ),
        ),
      ),
    );
  }
}
