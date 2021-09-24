import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUFont.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import '../ViewContextController.dart';

class SimpleFilterPanel extends StatefulWidget {
  final ViewContextController viewContext;

  SimpleFilterPanel({required this.viewContext});

  @override
  _SimpleFilterPanelState createState() => _SimpleFilterPanelState();
}

class _SimpleFilterPanelState extends State<SimpleFilterPanel> {
  @override
  Widget build(BuildContext context) {
    var actions = widget.viewContext.viewDefinitionPropertyResolver.actions("filterButtons");
    return actions != null
        ? SizedBox(
            height: 34,
            child: Row(
                children: space(
              10,
              actions.map(
                (action) => TextButton(
                    onPressed: () => action.execute(
                        widget.viewContext.pageController, widget.viewContext.getCVUContext()),
                    child: Text(
                      action.getString("title", widget.viewContext.getCVUContext()) ?? "Undefined",
                      style: CVUFont.tabList.copyWith(color: Color(0xff333333)),
                    )),
              ),
            )),
          )
        : Empty();
  }
}
