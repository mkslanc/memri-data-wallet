import 'package:flutter/material.dart';
import 'package:memri/controllers/view_context_controller.dart';
import 'package:memri/widgets/components/button/action_button.dart';
import 'package:memri/widgets/empty.dart';
import 'package:memri/widgets/space.dart';

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
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              height: 40,
              child: Row(
                  children: space(
                20,
                actions.map((action) => ActionButton(
                    action: action,
                    viewContext: widget.viewContext.getCVUContext(),
                    pageController: widget.viewContext.pageController)),
              )),
            ),
          )
        : Empty();
  }
}
