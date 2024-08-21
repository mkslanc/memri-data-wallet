import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import '../../../cvu/constants/cvu_color.dart';
import '../../../utilities/extensions/icon_data.dart';
import '../../space.dart';
import '../shapes/circle.dart';
import 'memri_text_editor.dart';
import 'memri_text_editor_model.dart';

class MemriTextEditorToolbar extends StatefulWidget {
  final ToolbarState toolbarState;
  final void Function(String, [Map<String, dynamic>?]) executeEditorCommand;

  final ValueNotifier<Map<String, dynamic>> currentFormatting;

  MemriTextEditorToolbar(
      {required this.toolbarState,
      required this.executeEditorCommand,
      required this.currentFormatting});

  @override
  _MemriTextEditorToolbarState createState() => _MemriTextEditorToolbarState();
}

class _MemriTextEditorToolbarState extends State<MemriTextEditorToolbar> {
  late ToolbarState toolbarState;
  late final void Function(String, [Map<String, dynamic>?]) executeEditorCommand;
  Map<String, dynamic> _currentFormatting = {};
  late final ValueNotifier<Map<String, dynamic>> currentFormatting;

  @override
  void initState() {
    super.initState();
    toolbarState = widget.toolbarState;
    executeEditorCommand = widget.executeEditorCommand;
    currentFormatting = widget.currentFormatting;
  }

  final TextStyle toolbarIconFont = TextStyle(fontSize: 17, fontWeight: FontWeight.bold);

  List<ToolbarItem> getToolbarItems() {
    var currentColorVar =
        _currentFormatting["text_color"] is String ? _currentFormatting["text_color"] : null;
    MemriTextEditorColor? matchingColor = MemriTextEditorColor.values
        .firstWhereOrNull((element) => element.cssVar == currentColorVar);
    switch (toolbarState) {
      case ToolbarState.main:
        var isHeading =
            (_currentFormatting["heading"] is int && _currentFormatting["heading"] != 0);
        var toolbarItems = <ToolbarItem>[
          ToolbarItemButton(
              label: "Bold",
              isActive: _currentFormatting["bold"] is bool ? _currentFormatting["bold"] : false,
              icon: Icon(MemriIcon.getByName("bold")),
              onPress: () => executeEditorCommand("bold")),
          ToolbarItemButton(
              label: "Italic",
              icon: Icon(MemriIcon.getByName("italic")),
              isActive: _currentFormatting["italic"] is bool ? _currentFormatting["italic"] : false,
              onPress: () => executeEditorCommand("italic")),
          ToolbarItemButton(
              label: "Underline",
              icon: Icon(MemriIcon.getByName("underline")),
              isActive:
                  _currentFormatting["underline"] is bool ? _currentFormatting["underline"] : false,
              onPress: () => executeEditorCommand("underline")),
          ToolbarItemButton(
              label: "Strike",
              icon: Icon(MemriIcon.getByName("strikethrough")),
              isActive: _currentFormatting["strike"] is bool ? _currentFormatting["strike"] : false,
              onPress: () => executeEditorCommand("strike")),
          ToolbarItemButton(
              label: "Color",
              icon: SizedBox(
                width: 30,
                height: 30,
                child: Column(
                  children: [
                    Icon(MemriIcon.getByName("paintpalette")),
                    if (matchingColor != null)
                      Container(
                        constraints: BoxConstraints(maxHeight: 4),
                        decoration: BoxDecoration(color: matchingColor.dartColor),
                      )
                  ],
                ),
              ),
              isActive: false,
              onPress: () => setState(() {
                    toolbarState = toolbarState.toggleColor();
                  })),
          ToolbarItemButton(
              label: "Highlighter",
              icon: Icon(MemriIcon.getByName("highlighter")),
              isActive: _currentFormatting["highlight_color"] != null,
              onPress: () =>
                  executeEditorCommand("highlight_color", {"backColor": "var(--text-highlight)"})),
          ToolbarItemDivider(),
          ToolbarItemButton(
              label: "Heading",
              icon: Text(
                "H",
                style: toolbarIconFont,
              ),
              isActive: isHeading,
              onPress: () => setState(() {
                    toolbarState = toolbarState.toggleHeading();
                  })),
          ToolbarItemButton(
              label: "Take photo",
              icon: Icon(MemriIcon.getByName("camera")),
              isActive: false,
              onPress: () => null /*attemptToSelectPhoto(true)*/), //TODO:
          ToolbarItemButton(
              label: "Image",
              icon: Icon(MemriIcon.getByName("photo")),
              isActive: false,
              onPress: () => null /*attemptToSelectPhoto(false)*/), //TODO:
        ];
        if (!isHeading) {
          toolbarItems.addAll([
            ToolbarItemButton(
                label: "Todo List",
                icon: Icon(MemriIcon.getByName("checkmark.square")),
                isActive: _currentFormatting["todo_list"] is bool
                    ? _currentFormatting["todo_list"]
                    : false,
                onPress: () => executeEditorCommand("todo_list")),
            ToolbarItemButton(
                label: "Unordered List",
                icon: Icon(MemriIcon.getByName("list.bullet")),
                isActive: _currentFormatting["bullet_list"] is bool
                    ? _currentFormatting["bullet_list"]
                    : false,
                onPress: () => executeEditorCommand("bullet_list")),
            ToolbarItemButton(
                label: "Ordered List",
                icon: Icon(MemriIcon.getByName("list.number")),
                isActive: _currentFormatting["ordered_list"] is bool
                    ? _currentFormatting["ordered_list"]
                    : false,
                onPress: () => executeEditorCommand("ordered_list")),
            ToolbarItemButton(
                label: "Outdent List",
                icon: Icon(MemriIcon.getByName("decrease.indent")),
                hideInactive: true,
                isActive: _currentFormatting["lift_list"] is bool
                    ? _currentFormatting["lift_list"]
                    : false,
                onPress: () => executeEditorCommand("lift_list")),
            ToolbarItemButton(
                label: "Indent List",
                icon: Icon(MemriIcon.getByName("increase.indent")),
                hideInactive: true,
                isActive: _currentFormatting["sink_list"] is bool
                    ? _currentFormatting["sink_list"]
                    : false,
                onPress: () => executeEditorCommand("sink_list")),
            ToolbarItemButton(
                label: "Code block",
                icon: Icon(MemriIcon.getByName("textbox")),
                hideInactive: true,
                isActive: _currentFormatting["code_block"] is bool
                    ? _currentFormatting["code_block"]
                    : false,
                onPress: () => executeEditorCommand("code_block")),
          ]);
        }
        return toolbarItems;
      case ToolbarState.color:
        return MemriTextEditorColor.values.map((color) {
          var isActiveColor = currentColorVar == color.cssVar;
          return ToolbarItemButton(
              label: "Set color",
              icon: SizedBox(
                  height: 30,
                  width: 30,
                  child: Circle(
                    color: color.dartColor ?? Colors.black,
                  )),
              isActive: isActiveColor,
              onPress: () =>
                  executeEditorCommand("text_color", {"color": color.cssVar, "override": true}));
        }).toList();
      case ToolbarState.heading:
        return [
          ToolbarItemButton(
              label: "Body",
              icon: Text(
                "Body",
                style: toolbarIconFont,
              ),
              isActive: _currentFormatting["heading"] is int && _currentFormatting["heading"] == 0,
              onPress: () => executeEditorCommand("heading", {"level": 0})),
          ToolbarItemButton(
              label: "H1",
              icon: Text(
                "H1",
                style: toolbarIconFont,
              ),
              isActive: _currentFormatting["heading"] is int && _currentFormatting["heading"] == 1,
              onPress: () => executeEditorCommand("heading", {"level": 1})),
          ToolbarItemButton(
              label: "H2",
              icon: Text(
                "H2",
                style: toolbarIconFont,
              ),
              isActive: _currentFormatting["heading"] is int && _currentFormatting["heading"] == 2,
              onPress: () => executeEditorCommand("heading", {"level": 2})),
          ToolbarItemButton(
              label: "H3",
              icon: Text(
                "H3",
                style: toolbarIconFont,
              ),
              isActive: _currentFormatting["heading"] is int && _currentFormatting["heading"] == 3,
              onPress: () => executeEditorCommand("heading", {"level": 3})),
          ToolbarItemButton(
              label: "H4",
              icon: Text(
                "H4",
                style: toolbarIconFont,
              ),
              isActive: _currentFormatting["heading"] is int && _currentFormatting["heading"] == 4,
              onPress: () => executeEditorCommand("heading", {"level": 4})),
        ];
      case ToolbarState.image:
        return [
          ToolbarItemLabel(Text(
            "Image selected",
            style: toolbarIconFont,
          )),
          ToolbarItemButton(
              label: "Delete",
              icon: Icon(
                MemriIcon.getByName("trash"),
                color: Colors.red,
              ),
              isActive: false,
              onPress: () => executeEditorCommand("deleteSelection")),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, dynamic>>(
      valueListenable: currentFormatting,
      builder: (context, value, child) {
        _currentFormatting = value;
        return ColoredBox(
          color: CVUColor.system("secondarySystemBackground"),
          child: Column(
            children: [
              Divider(
                height: 1,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: Row(
                      children: space(2, [
                        if (toolbarState.showBackButton)
                          Container(
                            constraints: BoxConstraints(maxWidth: 30, maxHeight: 36),
                            child: TextButton(
                              onPressed: () => setState(() {
                                toolbarState = toolbarState.onBack();
                              }),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size(30, 36),
                              ),
                              child: Icon(
                                MemriIcon.getByName("arrowshape.turn.up.left.circle"),
                                color: CVUColor.system("label"),
                              ),
                            ),
                          ),
                        if (toolbarState.showBackButton)
                          SizedBox(
                            height: 30,
                            child: VerticalDivider(
                              width: 1,
                            ),
                          ),
                        ...getToolbarItems()
                      ]),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  double get padding {
    /*if (sceneController.isBigScreen) {
      return 15;
    } else {*/
      return 4;
    //}
  }
}

abstract class ToolbarItem extends StatelessWidget {}

class ToolbarItemButton extends ToolbarItem {
  final String label;
  final Widget icon;
  final bool hideInactive;
  final bool isActive;
  final VoidCallback onPress;

  ToolbarItemButton(
      {required this.label,
      required this.icon,
      this.hideInactive = false,
      this.isActive = false,
      required this.onPress});

  @override
  Widget build(BuildContext context) {
    if (hideInactive && !isActive) {
      return SizedBox.shrink();
    } else {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          color: (isActive && !hideInactive) ? Colors.white : Colors.transparent,
        ),
        child: TextButton(
          onPressed: onPress,
          style: TextButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.zero,
            minimumSize: Size(30, 36),
          ),
          child: icon,
        ),
      );
    }
  }
}

class ToolbarItemLabel extends ToolbarItem {
  final Widget label;

  ToolbarItemLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return label;
  }
}

class ToolbarItemDivider extends ToolbarItem {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: VerticalDivider(
        indent: 8,
        width: 1,
      ),
    );
  }
}
