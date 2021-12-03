import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/actions/CVUAction.dart';
import 'package:memri/MemriApp/CVU/resolving/CVUContext.dart';
import 'package:memri/MemriApp/Controllers/PageController.dart' as memri;
import 'package:memri/MemriApp/Extensions/BaseTypes/IconData.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUColor.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUFont.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

import '../../BrowserView.dart';
import '../../ViewContextController.dart';

class ActionButton extends StatefulWidget {
  final CVUAction action;
  final CVUContext viewContext;
  final memri.PageController pageController;

  ActionButton({required this.action, required this.viewContext, required this.pageController});

  @override
  _ActionButtonState createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  late Future<void> _init;

  String title = "";
  Color color = Color(0xff333333);

  @override
  initState() {
    super.initState();
    _init = init();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init = init();
  }

  init() async {
    title = await widget.action.getString("title", widget.viewContext) ?? "";
    var colorString = await widget.action.getString("color", widget.viewContext) ?? "black";
    color = CVUColor(color: colorString).value;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) {
        return TextButton(
            child: Text(
              title,
              style: CVUFont.link.copyWith(color: color),
            ),
            onPressed: () async {
              await widget.action.execute(widget.pageController, widget.viewContext);
              _init = init();
            });
      },
    );
  }
}

class ActionPopupButton extends StatefulWidget {
  final CVUActionOpenViewByName action;
  final memri.PageController pageController;

  ActionPopupButton(this.action, this.pageController);

  @override
  _ActionPopupButtonState createState() => _ActionPopupButtonState();
}

class _ActionPopupButtonState extends State<ActionPopupButton> {
  @override
  Widget build(BuildContext context) {
    var action = widget.action;
    return TextButton(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Icon(MemriIcon.getByName("plus")),
      ),
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (BuildContext context) => FutureBuilder<ViewContextController?>(
          future: action.getViewContext(
              CVUContext(viewName: action.viewName, rendererName: action.renderer),
              widget.pageController),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Empty();
              default:
                if (snapshot.hasData) {
                  return BrowserView(
                    viewContext: snapshot.data!,
                  );
                } else {
                  return Text("TODO: ActionPopupButton");
                }
            }
          },
        ),
      ),
    );
  }
}
