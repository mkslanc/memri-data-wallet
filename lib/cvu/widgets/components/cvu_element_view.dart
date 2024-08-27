//  Created by T Brennan on 7/1/21.

import 'package:flutter/material.dart';
import 'package:memri/cvu/models/cvu_ui_element_family.dart';
import 'package:memri/cvu/widgets/components/cvu_ui_node_resolver.dart';
import 'package:memri/cvu/widgets/components/elements/cvu_appearance_modifier.dart';
import 'package:memri/cvu/widgets/components/elements/cvu_button.dart';
import 'package:memri/cvu/widgets/components/elements/cvu_drop_zone.dart';
import 'package:memri/cvu/widgets/components/elements/cvu_dropdown.dart';
import 'package:memri/cvu/widgets/components/elements/cvu_flow_stack.dart';
import 'package:memri/cvu/widgets/components/elements/cvu_for_each.dart';
import 'package:memri/cvu/widgets/components/elements/cvu_grid.dart';
import 'package:memri/cvu/widgets/components/elements/cvu_html_view.dart';
import 'package:memri/cvu/widgets/components/elements/cvu_image.dart';
import 'package:memri/cvu/widgets/components/elements/cvu_loading_indicator.dart';
import 'package:memri/cvu/widgets/components/elements/cvu_shape.dart';
import 'package:memri/cvu/widgets/components/elements/cvu_stacks.dart';
import 'package:memri/cvu/widgets/components/elements/cvu_sub_view.dart';
import 'package:memri/cvu/widgets/components/elements/cvu_text.dart';
import 'package:memri/widgets/empty.dart';

import 'elements/cvu_timeline_item.dart';

/// This view is used to display CVU elements (and is used in a nested fashion to display their children)
class CVUElementView extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;
  final Map<String, dynamic>? additionalParams; //TODO not best solution

  CVUElementView({required this.nodeResolver, this.additionalParams, Key? key})
      : super(key: key);

  @override
  _CVUElementViewState createState() => _CVUElementViewState();
}

class _CVUElementViewState extends State<CVUElementView> {
  bool? showNode;

  @override
  initState() {
    super.initState();
    showNode = widget.nodeResolver.propertyResolver.showNode;
  }

  Widget resolvedComponent() {
    switch (widget.nodeResolver.node.type) {
      case CVUUIElementFamily.ForEach:
        return CVUForEach(
            nodeResolver: widget.nodeResolver,
            getWidget: widget.additionalParams!["getWidget"]);
      case CVUUIElementFamily.HStack:
        return CVUHStack(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.VStack:
        return CVUVStack(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.ZStack:
        return CVUZStack(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.Wrap:
        return CVUWrap(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.Text:
        return CVUText(
          nodeResolver: widget.nodeResolver,
        );
      case CVUUIElementFamily.Image:
        return CVUImage(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.SmartText:
        return CVUSmartText(
          nodeResolver: widget.nodeResolver,
        );
      case CVUUIElementFamily.Button:
        return CVUButton(
          nodeResolver: widget.nodeResolver,
        );
      case CVUUIElementFamily.Divider:
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
      case CVUUIElementFamily.SubView:
        return CVUSubView(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.DropZone:
        return CVUDropZone(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.Dropdown:
        return CVUDropdown(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.RichText:
        return CVURichText(nodeResolver: widget.nodeResolver);
      case CVUUIElementFamily.LoadingIndicator:
        return CVULoadingIndicator(nodeResolver: widget.nodeResolver);
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
    setState(() {
      showNode = widget.nodeResolver.propertyResolver.showNode;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showNode == true) {
      return needsModifier
          ? CVUAppearanceModifier(
              nodeResolver: widget.nodeResolver, child: resolvedComponent())
          : resolvedComponent();
    }
    return Empty();
  }
}
