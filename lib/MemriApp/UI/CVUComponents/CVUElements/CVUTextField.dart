import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Helpers/Binding.dart';

import '../CVUUINodeResolver.dart';
import 'package:memri/MemriApp/Extensions/BaseTypes/String.dart';

/// A CVU element for displaying an editable textfield
/// - Set the `value` property to an expression representing the item property to be edited
/// - Set the `hint` property to change the text displayed when the field is empty
/// - Set the `secure` to `true` to obscure content (eg. password field)
/// - Set the `color` property to change text color
class CVUTextField extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;
  late final bool? secureMode;
  late final String? hint;
  late final Binding<String?> contentBinding;

  CVUTextField({required this.nodeResolver});

  //@EnvironmentObject var sceneController: SceneController

  init() async {
    // Secure mode hides the input (eg. for passwords)
    secureMode = await nodeResolver.propertyResolver.boolean("secure", false);
    hint = (await nodeResolver.propertyResolver.string("hint"))?.nullIfBlank;
    contentBinding = await nodeResolver.propertyResolver.binding("value", null)
        as Binding<String?>; /*?? .constant(nil) */
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init(),
        builder: (BuildContext builder, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return TextFormField(
                style: TextStyle(color: Color(0xff8a66bc)),
                onChanged: (text) => contentBinding.set(text),
                initialValue: contentBinding.get(),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.4)),
                  fillColor: Color.fromRGBO(0, 0, 0, 0.4),
                  filled: true,
                ),
              );
            /* TODO:
              textColor: nodeResolver.propertyResolver.color()?.uiColor,
            isEditing: $sceneController.isInEditMode,
            isSharedEditingBinding: true,
            secureMode: secureMode
               */
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
