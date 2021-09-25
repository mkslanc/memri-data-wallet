import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/Components/Button/ActionButton.dart';
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
              actions.map((action) => ActionButton(
                      action: action,
                      viewContext: widget.viewContext.getCVUContext(),
                      pageController: widget.viewContext.pageController)
                  ),
            )),
          )
        : Empty();
  }
}
