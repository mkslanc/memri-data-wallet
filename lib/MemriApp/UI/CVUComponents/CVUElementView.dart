//
//  CVUElementView.swift
//  MemriDatabase
//
//  Created by T Brennan on 7/1/21.
//

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUUIElementFamily.dart';
import 'package:memri/MemriApp/UI/CVUComponents/CVUElements/CVUAppearanceModifier.dart';
import 'package:memri/MemriApp/UI/CVUComponents/CVUElements/CVUGrid.dart';
import 'package:memri/MemriApp/UI/CVUComponents/CVUElements/CVUMessageComposer.dart';
import 'package:memri/MemriApp/UI/CVUComponents/CVUElements/CVUObserver.dart';
import 'package:memri/MemriApp/UI/CVUComponents/CVUElements/CVUSubView.dart';
import 'package:memri/MemriApp/UI/CVUComponents/CVUElements/CVUTextPropertiesModifier.dart';

import 'CVUElements/CVUActionButton.dart';
import 'CVUElements/CVUButton.dart';
import 'CVUElements/CVUDropZone.dart';
import 'CVUElements/CVUEditorRow.dart';
import 'CVUElements/CVUFlowStack.dart';
import 'CVUElements/CVUForEach.dart';
import 'CVUElements/CVUHTMLView.dart';
import 'CVUElements/CVUImage.dart';
import 'CVUElements/CVUMap.dart';
import 'CVUElements/CVUMemriButton.dart';
import 'CVUElements/CVUShape.dart';
import 'CVUElements/CVUStacks.dart';
import 'CVUElements/CVUText.dart';
import 'CVUElements/CVUTextField.dart';
import 'CVUElements/CVUTimelineItem.dart';
import 'CVUElements/CVUToggle.dart';
import 'CVUUINodeResolver.dart';
import 'package:memri/MemriApp/UI/UIHelpers/utilities.dart';

/// This view is used to display CVU elements (and is used in a nested fashion to display their children)
class CVUElementView extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;
  final Map<String, dynamic>? additionalParams; //TODO not best solution

  CVUElementView({required this.nodeResolver, this.additionalParams, Key? key}) : super(key: key);

  @override
  _CVUElementViewState createState() => _CVUElementViewState();
}

class _CVUElementViewState extends State<CVUElementView> {
  late Future<bool> _showNode;

  bool? showNode;

  @override
  initState() {
    super.initState();
    _showNode = widget.nodeResolver.propertyResolver.showNode;
  }

  Widget resolvedComponent([Future<TextProperties>? textProperties]) {
    switch (widget.nodeResolver.node.type) {
      case CVUUIElementFamily.ForEach:
        return CVUForEach(
            nodeResolver: widget.nodeResolver, getWidget: widget.additionalParams!["getWidget"]);
      case CVUUIElementFamily.HStack:
        return CVUHStack(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.VStack:
        return CVUVStack(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.ZStack:
        return CVUZStack(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.Text:
        return CVUText(
          nodeResolver: widget.nodeResolver,
          textProperties: textProperties!,
        );
      case CVUUIElementFamily.Image:
        return CVUImage(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.Map:
        return CVUMap(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.SmartText:
        return CVUSmartText(
          nodeResolver: widget.nodeResolver,
          textProperties: textProperties!,
        );
      case CVUUIElementFamily.Textfield:
        return CVUTextField(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.Toggle:
        return CVUToggle(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.Button:
        return CVUButton(
          nodeResolver: widget.nodeResolver,
          textProperties: textProperties!,
        );
      case CVUUIElementFamily.Divider:
        return Divider(
          height: 1,
        );
      case CVUUIElementFamily.HorizontalLine:
        return Divider(
          height: 1,
        );
      case CVUUIElementFamily.Circle:
        return CVUShapeCircle(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.Rectangle:
        return CVUShapeRectangle(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.HTMLView:
        return CVUHTMLView(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.TimelineItem:
        return CVUTimelineItem(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.Spacer:
        return Spacer();
      case CVUUIElementFamily.Empty:
        return Empty();
      case CVUUIElementFamily.FlowStack:
        return CVUFlowStack(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.Grid:
        return CVUGrid(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.EditorRow:
        return CVUEditorRow(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.SubView:
        return CVUSubView(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.MemriButton:
        return CVUMemriButton(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.ActionButton:
        return CVUActionButton(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.MessageComposer:
        return CVUMessageComposer(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.DropZone:
        return CVUDropZone(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.Observer:
        return CVUObserver(nodeResolver: widget.nodeResolver);
      default:
        return Text("${widget.nodeResolver.node.type} not implemented yet.");
    }
  }

  bool get needsModifier {
    switch (widget.nodeResolver.node.type) {
      case CVUUIElementFamily.Empty:
      case CVUUIElementFamily.ForEach:
      case CVUUIElementFamily.Spacer:
      case CVUUIElementFamily.Divider:
      case CVUUIElementFamily.FlowStack:
        return false;
      default:
        return true;
    }
  }

  @override
  void didUpdateWidget(covariant CVUElementView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _showNode = widget.nodeResolver.propertyResolver.showNode;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        initialData: showNode,
        future: _showNode,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            showNode = snapshot.data!;
          }
          if (showNode == true) {
            return needsModifier
                ? CVUAppearanceModifier(
                    nodeResolver: widget.nodeResolver,
                    child: resolvedComponent(
                        CVUTextPropertiesModifier(nodeResolver: widget.nodeResolver).init()))
                : resolvedComponent();
          }
          return Empty();
        });
  }
}
