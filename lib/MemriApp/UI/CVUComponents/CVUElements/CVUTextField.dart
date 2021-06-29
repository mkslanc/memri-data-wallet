import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';
import 'package:memri/MemriApp/UI/Components/Text/TextField/MemriTextfield.dart';

import '../CVUUINodeResolver.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';

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

  String? hint;
  Color? color;

  FutureBinding<String?>? contentBinding;

  SceneController sceneController = SceneController.sceneController;

  late Future _init;

  @override
  initState() {
    super.initState();
    _init = init();
  }

  init() async {
    // Secure mode hides the input (eg. for passwords)
    secureMode = await widget.nodeResolver.propertyResolver.boolean("secure", false);
    hint = (await widget.nodeResolver.propertyResolver.string("hint"))?.nullIfBlank;
    contentBinding = await widget.nodeResolver.propertyResolver.binding<String>("value", null);
    color = await widget.nodeResolver.propertyResolver.color();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _init,
        builder: (BuildContext builder, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return MemriTextField.async(
                  futureBinding: contentBinding,
                  style: TextStyle(
                    color: color,
                  ),
                  hint: hint,
                  secureMode: secureMode!);
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
