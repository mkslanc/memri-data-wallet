import 'package:flutter/material.dart';
import 'package:memri/constants/cvu/cvu_color.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/core/controllers/page_controller.dart' as memri;
import 'package:memri/core/controllers/view_context_controller.dart';
import 'package:memri/core/cvu/cvu_action.dart';
import 'package:memri/core/cvu/resolving/cvu_context.dart';
import 'package:memri/core/models/cvu/cvu_parsed_definition.dart';
import 'package:memri/core/models/cvu/cvu_value.dart';
import 'package:memri/utilities/extensions/icon_data.dart';
import 'package:memri/widgets/browser_view.dart';
import 'package:memri/widgets/empty.dart';

class ActionButton extends StatefulWidget {
  final CVUAction action;
  final CVUContext viewContext;
  final memri.PageController pageController;

  ActionButton(
      {required this.action,
      required this.viewContext,
      required this.pageController});

  @override
  _ActionButtonState createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  late Future<void> _init;

  String? title = "";
  Color color = Color(0xff333333);
  CVUDefinitionContent? actionButton;

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
    title = await widget.action.getString("title", widget.viewContext);
    if (title == null && widget.action.vars["title"] is CVUValueSubdefinition) {
      actionButton =
          (widget.action.vars["title"] as CVUValueSubdefinition).value;
    }
    var colorString =
        await widget.action.getString("color", widget.viewContext) ?? "black";
    color = CVUColor(color: colorString).value;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
          child: TextButton(
              child: title != null
                  ? Text(
                      title!,
                      style: CVUFont.tabList.copyWith(color: color),
                    )
                  : IntrinsicWidth(
                      child: (widget.pageController.topMostContext
                              ?.render(nodeDefinition: actionButton) ??
                          Empty()),
                    ),
              style: TextButton.styleFrom(
                  textStyle: CVUFont.buttonLabel,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.all(title == null ? 5 : 10)),
              onPressed: () async {
                await widget.action
                    .execute(widget.pageController, widget.viewContext);
                _init = init();
              }),
        );
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
        builder: (BuildContext context) =>
            FutureBuilder<ViewContextController?>(
          future: action.getViewContext(
              CVUContext(
                  viewName: action.viewName, rendererName: action.renderer),
              widget.pageController),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Empty();
              default:
                if (snapshot.hasData) {
                  return BrowserView(viewContext: snapshot.data!);
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
