import 'package:flutter/material.dart';

import '../../../cvu/services/cvu_action.dart';
import '../../../cvu/services/resolving/cvu_context.dart';
import '../../../utilities/extensions/icon_data.dart';

class ActionButton extends StatefulWidget {
  final CVUAction action;
  final CVUContext viewContext;

  ActionButton({required this.action, required this.viewContext});

  @override
  _ActionButtonState createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  String? _icon;

  String get icon => _icon ?? "";

  @override
  initState() {
    super.initState();
    initIcon();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    initIcon();
  }

  initIcon() {
    _icon = widget.action.getString("icon", widget.viewContext);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        child: Icon(MemriIcon.getByName(icon)),
        onPressed: () async {
          await widget.action.execute(widget.viewContext, context);
          setState(() => initIcon());
        });
  }
}
