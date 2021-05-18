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
import 'package:memri/MemriApp/UI/CVUComponents/CVUElements/CVUTextPropertiesModifier.dart';

import 'CVUElements/CVUActionButton.dart';
import 'CVUElements/CVUButton.dart';
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

/// This view is used to display CVU elements (and is used in a nested fashion to display their children)
class CVUElementView extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;
  final Map<String, dynamic>? additionalParams; //TODO not best solution

  CVUElementView({required this.nodeResolver, this.additionalParams});

  Widget resolvedComponent([Future<TextProperties>? textProperties]) {
    switch (nodeResolver.node.type) {
      case CVUUIElementFamily.ForEach:
        return CVUForEach(nodeResolver: nodeResolver, getWidget: additionalParams!["getWidget"]);
      case CVUUIElementFamily.HStack:
        return CVUHStack(nodeResolver: nodeResolver);
      case CVUUIElementFamily.VStack:
        return CVUVStack(nodeResolver: nodeResolver);
      case CVUUIElementFamily.ZStack:
        return CVUZStack(nodeResolver: nodeResolver);
      case CVUUIElementFamily.Text:
        return CVUText(
          nodeResolver: nodeResolver,
          textProperties: textProperties!,
        );
      case CVUUIElementFamily.Image:
        return CVUImage(nodeResolver: nodeResolver);
      case CVUUIElementFamily.Map:
        return CVUMap(nodeResolver: nodeResolver);
      case CVUUIElementFamily.SmartText:
        return CVUSmartText(
          nodeResolver: nodeResolver,
          textProperties: textProperties!,
        );
      case CVUUIElementFamily.Textfield:
        return CVUTextField(nodeResolver: nodeResolver);
      case CVUUIElementFamily.Toggle:
        return CVUToggle(nodeResolver: nodeResolver);
      case CVUUIElementFamily.Button:
        return CVUButton(
          nodeResolver: nodeResolver,
          textProperties: textProperties!,
        );
      case CVUUIElementFamily.Divider:
        return Divider(
          height: 1,
        );
      case CVUUIElementFamily.HorizontalLine:
        return Divider(
          height: 1,
        ); //TODO
      case CVUUIElementFamily.Circle:
        return CVUShapeCircle(nodeResolver: nodeResolver);
      case CVUUIElementFamily.Rectangle:
        return CVUShapeRectangle(nodeResolver: nodeResolver);
      case CVUUIElementFamily.HTMLView:
        return CVUHTMLView(nodeResolver: nodeResolver);
      case CVUUIElementFamily.TimelineItem:
        return CVUTimelineItem(nodeResolver: nodeResolver);
      /*case CVUUIElementFamily.FileThumbnail:
      // return CVU_FileThumbnail(nodeResolver: nodeResolver);*/
      case CVUUIElementFamily.Spacer:
        return Spacer();
      case CVUUIElementFamily.Empty:
        return SizedBox.shrink();
      case CVUUIElementFamily.FlowStack:
        return CVUFlowStack(nodeResolver: nodeResolver);
      case CVUUIElementFamily.Grid:
        return CVUGrid(nodeResolver: nodeResolver);
      case CVUUIElementFamily.EditorRow:
        return CVUEditorRow(nodeResolver: nodeResolver);
      case CVUUIElementFamily.SubView:
        return CVUEditorRow(nodeResolver: nodeResolver);
      case CVUUIElementFamily.MemriButton:
        return CVUMemriButton(nodeResolver: nodeResolver);
      case CVUUIElementFamily.ActionButton:
        return CVUActionButton(nodeResolver: nodeResolver);
//        case CVUUIElementFamily.Picker:
//            picker
//        case CVUUIElementFamily.EditorSection:
//            return CVU_EditorSection(nodeResolver: nodeResolver);
      default:
        return Text("${nodeResolver.node.type} not implemented yet.");
    }
  }

  bool get needsModifier {
    switch (nodeResolver.node.type) {
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
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: nodeResolver.propertyResolver.showNode,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            return needsModifier
                ? CVUAppearanceModifier(nodeResolver: nodeResolver).body(
                    resolvedComponent(CVUTextPropertiesModifier(nodeResolver: nodeResolver).init()))
                : resolvedComponent();
          }
          return SizedBox.shrink();
        });
  }
}
