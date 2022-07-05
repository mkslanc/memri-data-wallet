import 'package:flutter/material.dart';
import 'package:memri/cvu/models/cvu_view_arguments.dart';
import 'package:memri/core/services/mixpanel_analytics_service.dart';
import 'package:memri/cvu/models/cvu_value.dart';
import 'package:memri/cvu/models/cvu_value_constant.dart';
import 'package:memri/utilities/execute_actions.dart';
import 'package:memri/cvu/widgets/components/cvu_ui_node_resolver.dart';

import '../../../services/resolving/cvu_property_resolver.dart';
import 'cvu_text_properties_modifier.dart';

/// A CVU element for displaying a button
/// - Use the `onPress` property to provide a CVU Action for the button
class CVUButton extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUButton({required this.nodeResolver});

  @override
  _CVUButtonState createState() => _CVUButtonState();
}

class _CVUButtonState extends State<CVUButton> {
  TextProperties? resolvedTextProperties;
  bool isLink = false;
  ButtonStyle? style;
  Color? backgroundColor;

  late ValueNotifier<bool> _isDisabled;

  set isDisabled(bool isDisabled) => _isDisabled.value = isDisabled;

  String? id;

  @override
  initState() {
    super.initState();
    init();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() => init());
  }

  void init() {
    resolvedTextProperties = CVUTextPropertiesModifier(
            propertyResolver: widget.nodeResolver.propertyResolver)
        .init();
    isLink = (widget.nodeResolver.propertyResolver.boolean("isLink", false))!;
    style = widget.nodeResolver.propertyResolver
        .style<ButtonStyle>(type: StyleType.button);
    backgroundColor = widget.nodeResolver.propertyResolver.backgroundColor;
    id = widget.nodeResolver.propertyResolver.string("id");
    var isDisabled =
        (widget.nodeResolver.propertyResolver.boolean("isDisabled", false))!;
    _isDisabled = ValueNotifier(isDisabled);
  }

  onPress() async {
    await logAnalyticsEvent();
    executeActionsOnSubmit(widget.nodeResolver, this,
        isDisabled: _isDisabled, actionsKey: "onPress");
  }

  logAnalyticsEvent() async {
    var textNode = widget.nodeResolver.firstTextNode();
    var buttonText = "Unknown";
    if (textNode != null) {
      var resolver = widget.nodeResolver.copyForNode(textNode);
      buttonText = resolver.propertyResolver.string("text") ?? "Unknown";
    }

    MixpanelAnalyticsService().logCvuButton(buttonText);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isDisabled,
      builder: (BuildContext context, bool isDisabled, Widget? child) => isLink
          ? InkWell(
              onTap: isDisabled ? null : onPress,
              child:
                  widget.nodeResolver.childrenInForEachWithWrap(centered: true),
              onHover: id != null
                  ? (bool isHovered) {
                      setState(() {
                        widget.nodeResolver.context.viewArguments ??=
                            CVUViewArguments();
                        widget.nodeResolver.context.viewArguments!
                                .args["isHovered$id"] =
                            CVUValueConstant(CVUConstantBool(isHovered));
                      });
                    }
                  : null)
          : TextButton(
              onPressed: isDisabled ? null : onPress,
              child:
                  widget.nodeResolver.childrenInForEachWithWrap(centered: true),
              style: TextButton.styleFrom(
                      textStyle:
                          resolvedTextProperties?.textStyle ?? TextStyle(),
                      backgroundColor: backgroundColor)
                  .merge(style),
            ),
    );
  }
}
