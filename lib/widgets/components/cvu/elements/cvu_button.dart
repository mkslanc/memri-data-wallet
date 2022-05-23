import 'package:flutter/material.dart';
import 'package:memri/core/cvu/resolving/cvu_property_resolver.dart';
import 'package:memri/utils/execute_actions.dart';

import '../cvu_ui_node_resolver.dart';
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

  late Future _init;

  @override
  initState() {
    _isDisabled = ValueNotifier(false);
    super.initState();
    _init = init();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init = init();
  }

  init() async {
    resolvedTextProperties =
        await CVUTextPropertiesModifier(propertyResolver: widget.nodeResolver.propertyResolver)
            .init();
    isLink = (await widget.nodeResolver.propertyResolver.boolean("isLink", false))!;
    style = await widget.nodeResolver.propertyResolver.style<ButtonStyle>(type: StyleType.button);
    backgroundColor = (await widget.nodeResolver.propertyResolver.backgroundColor) ?? null;
  }

  onPress() async {
    executeActionsOnSubmit(widget.nodeResolver, this,
        isDisabled: _isDisabled, actionsKey: "onPress");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext builder, snapshot) {
          return ValueListenableBuilder(
            valueListenable: _isDisabled,
            builder: (BuildContext context, bool isDisabled, Widget? child) => isLink
                ? InkWell(
                    onTap: isDisabled ? null : onPress,
                    child: widget.nodeResolver.childrenInForEachWithWrap(centered: true),
                  )
                : TextButton(
                    onPressed: isDisabled ? null : onPress,
                    child: widget.nodeResolver.childrenInForEachWithWrap(centered: true),
                    style: TextButton.styleFrom(
                            textStyle: resolvedTextProperties?.textStyle ?? TextStyle(),
                            backgroundColor: backgroundColor)
                        .merge(style),
                  ),
          );
        });
  }
}
