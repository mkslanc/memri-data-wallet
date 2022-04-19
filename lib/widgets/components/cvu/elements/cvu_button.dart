import 'package:flutter/material.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/core/cvu/cvu_action.dart';
import 'package:memri/core/cvu/resolving/cvu_property_resolver.dart';
import 'package:memri/utils/extensions/collection.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

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

  onPress() async {
    var actions = widget.nodeResolver.propertyResolver.actions("onPress");
    if (actions == null) {
      return;
    }
    isDisabled = true;

    var isBlocked = widget.nodeResolver.pageController.appController.storage["isBlocked"];
    if (isBlocked is ValueNotifier && isBlocked.value == true) {
      executeActionsWhenUnblocked() async {
        if (isBlocked.value == false) {
          isBlocked.removeListener(executeActionsWhenUnblocked);
          await executeActions(actions);
        }
      }

      isBlocked.addListener(executeActionsWhenUnblocked);
    } else {
      await executeActions(actions);
    }
  }

  executeActions(actions) async {
    try {
      for (var action in actions) {
        if (action is CVUActionOpenPopup) {
          var settings = await action.setPopupSettings(
              widget.nodeResolver.pageController, widget.nodeResolver.context);
          if (settings != null) {
            openPopup(settings);
          }
        } else {
          await action.execute(widget.nodeResolver.pageController, widget.nodeResolver.context);
        }
      }
    } catch (e) {
      if (e is String) {
        openErrorPopup(e);
      } else {
        isDisabled = false;
        throw e;
      }
    }
    isDisabled = false;
  }

  openPopup(Map<String, dynamic> settings) {
    List<CVUAction>? actions = settings['actions'];
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
          title: Text(settings['title']),
          content: Text(settings['text']),
          actions: actions?.compactMap(
            (action) {
              var title = action.vars["title"]?.value?.value;
              if (title != null) {
                return PointerInterceptor(
                    child: TextButton(
                  onPressed: () async {
                    await action.execute(
                        widget.nodeResolver.pageController, widget.nodeResolver.context);
                    Navigator.pop(context, action.vars["title"]!.value.value);
                  },
                  child: Text(action.vars["title"]!.value.value),
                ));
              } else {
                return null;
              }
            },
          ).toList()),
    );
  }

  openErrorPopup(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        text,
        style: CVUFont.bodyBold.copyWith(color: Color(0xFFE9500F)),
      ),
      backgroundColor: Color(0x33E9500F),
      elevation: 0,
      duration: Duration(seconds: 2),
    ));
    return;
  }

  init() async {
    resolvedTextProperties =
        await CVUTextPropertiesModifier(propertyResolver: widget.nodeResolver.propertyResolver)
            .init();
    isLink = (await widget.nodeResolver.propertyResolver.boolean("isLink", false))!;
    style = await widget.nodeResolver.propertyResolver.style<ButtonStyle>(type: StyleType.button);
  }

  @override
  Widget build(BuildContext context) {
    //TODO: buttonStyle
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
                            textStyle: resolvedTextProperties?.textStyle ?? TextStyle())
                        .merge(style),
                  ),
          );
        });
  }
}
