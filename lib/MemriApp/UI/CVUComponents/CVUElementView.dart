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

import 'CVUElements/CVUButton.dart';
import 'CVUElements/CVUForEach.dart';
import 'CVUElements/CVUHTMLView.dart';
import 'CVUElements/CVUImage.dart';
import 'CVUElements/CVUShape.dart';
import 'CVUElements/CVUStacks.dart';
import 'CVUElements/CVUText.dart';
import 'CVUElements/CVUTextField.dart';
import 'CVUUINodeResolver.dart';

/// This view is used to display CVU elements (and is used in a nested fashion to display their children)
class CVUElementView extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;

  CVUElementView({required this.nodeResolver});

  Widget resolvedComponent() {
    switch (nodeResolver.node.type) {
      case CVUUIElementFamily.ForEach:
        return CVUForEach(nodeResolver: nodeResolver);
      case CVUUIElementFamily.HStack:
        return CVUHStack(nodeResolver: nodeResolver);
      case CVUUIElementFamily.VStack:
        return CVUVStack(nodeResolver: nodeResolver);
      case CVUUIElementFamily.ZStack:
        return CVUZStack(nodeResolver: nodeResolver);
      case CVUUIElementFamily.Text:
        return CVUText(nodeResolver: nodeResolver);
      case CVUUIElementFamily.Image:
        return CVUImage(nodeResolver: nodeResolver);
      /*case CVUUIElementFamily.Map:
      // return CVU_Map(nodeResolver: nodeResolver);
      case CVUUIElementFamily.SmartText:
        return CVUSmartText(nodeResolver: nodeResolver);*/
      case CVUUIElementFamily.Textfield:
        return CVUTextField(nodeResolver: nodeResolver);
      /*case CVUUIElementFamily.Toggle:
      // return CVU_Toggle(nodeResolver: nodeResolver);*/
      case CVUUIElementFamily.Button:
        return CVUButton(nodeResolver: nodeResolver);
      case CVUUIElementFamily.Divider:
        return Divider();
      case CVUUIElementFamily.HorizontalLine:
        return Divider(); //TODO
      case CVUUIElementFamily.Circle:
        return CVUShapeCircle(nodeResolver: nodeResolver);
      case CVUUIElementFamily.Rectangle:
        return CVUShapeRectangle(nodeResolver: nodeResolver);
      case CVUUIElementFamily.HTMLView:
        return CVUHTMLView(nodeResolver: nodeResolver);
      /* case CVUUIElementFamily.TimelineItem:
      // return CVU_TimelineItem(nodeResolver: nodeResolver);
      case CVUUIElementFamily.FileThumbnail:
      // return CVU_FileThumbnail(nodeResolver: nodeResolver);*/
      case CVUUIElementFamily.Spacer:
        return Spacer();
      case CVUUIElementFamily.Empty:
        return SizedBox.shrink();
//        case CVUUIElementFamily.FlowStack:
//            flowstack
//        case CVUUIElementFamily.Picker:
//            picker
//        case CVUUIElementFamily.EditorSection:
//            return CVU_EditorSection(nodeResolver: nodeResolver);
//        case CVUUIElementFamily.EditorRow:
//            return CVU_EditorRow(nodeResolver: nodeResolver);
//        case CVUUIElementFamily.MemriButton:
//            return CVU_MemriButton(nodeResolver: nodeResolver);
//        case CVUUIElementFamily.ActionButton:
//            ActionButton(
//                action: nodeResolver.propertyResolver.resolve("press") ?? Action(context, "noop"),
//                item: nodeResolver.propertyResolver.item
//            )
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
                ? CVUAppearanceModifier(nodeResolver: nodeResolver).body(resolvedComponent())
                : resolvedComponent();
          }
          return SizedBox.shrink();
        });
  }
}
