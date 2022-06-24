import 'package:flutter/material.dart';
import 'package:memri/utilities/binding.dart';
import 'package:memri/utilities/execute_actions.dart';
import 'package:memri/utilities/extensions/string.dart';
import 'package:memri/widgets/components/cvu/cvu_ui_node_resolver.dart';
import 'package:memri/widgets/components/text_field/memri_text_field.dart';

import '../../../../core/cvu/cvu_action.dart';

/// A CVU element for displaying an editable textfield
/// - Set the `value` property to an expression representing the item property to be edited
/// - Set the `hint` property to change the text displayed when the field is empty
/// - Set the `secure` to `true` to obscure content (eg. password field)
/// - Set the `color` property to change text color
class CVUTextField extends StatefulWidget {
  final CVUUINodeResolver nodeResolver;

  CVUTextField({required this.nodeResolver});

  @override
  _CVUTextFieldState createState() => _CVUTextFieldState();
}

class _CVUTextFieldState extends State<CVUTextField> {
  bool? secureMode;
  bool? isCollapsed;
  late bool autoFocus;

  String? hint;
  Color? color;

  FutureBinding<String>? contentBinding;

  late List<CVUAction> actions;

  late Future _init;
  ValueNotifier<bool> isDisabled = ValueNotifier(false);

  @override
  initState() {
    super.initState();
    _init = init();
  }

  init() async {
    // Secure mode hides the input (eg. for passwords)
    secureMode =
        await widget.nodeResolver.propertyResolver.boolean("secure", false);
    hint = (await widget.nodeResolver.propertyResolver.string("hint"))
        ?.nullIfBlank;
    contentBinding = await widget.nodeResolver.propertyResolver
        .binding<String>("value", null);
    color = await widget.nodeResolver.propertyResolver.color();
    isCollapsed = await widget.nodeResolver.propertyResolver
        .boolean("isCollapsed", false);
    autoFocus = (await widget.nodeResolver.propertyResolver
        .boolean("autoFocus", false))!;
    actions = widget.nodeResolver.propertyResolver.actions("onSubmit") ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext builder, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return MemriTextField.async(
                isDisabled: isDisabled,
                futureBinding: contentBinding,
                style: TextStyle(
                  color: color,
                ),
                hint: hint,
                secureMode: secureMode!,
                isCollapsed: isCollapsed!,
                autoFocus: autoFocus,
                onSubmit: actions.isNotEmpty
                    ? () => executeActionsOnSubmit(widget.nodeResolver, this,
                        isDisabled: isDisabled, actions: actions)
                    : null,
              );
            default:
              return SizedBox(
                child: CircularProgressIndicator(),
                width: 60,
                height: 60,
              );
          }
        });
  }
}
