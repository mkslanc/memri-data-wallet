import 'package:flutter/material.dart';

import '../CVUUINodeResolver.dart';
import 'CVUTextPropertiesMofifier.dart';

/// A CVU element for displaying a button
/// - Use the `onPress` property to provide a CVU Action for the button
class CVUButton extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;

  //final SceneController sceneController;
  final Future<TextProperties> textProperties;
  late final TextProperties resolvedTextProperties;

  CVUButton({required this.nodeResolver, required this.textProperties});

  onPress() {
    var action = nodeResolver.propertyResolver.action("onPress");
    if (action == null) {
      return;
    }
    //action.execute(sceneController, nodeResolver.context); TODO: need sceneController
  }

  init() async {
    resolvedTextProperties = await textProperties;
  }

  @override
  Widget build(BuildContext context) {
    //TODO: buttonStyle
    return FutureBuilder(
        future: init(),
        builder: (BuildContext builder, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ElevatedButton(
              onPressed: onPress,
              child: nodeResolver.childrenInForEachWithWrap(),
              style: ElevatedButton.styleFrom(textStyle: resolvedTextProperties.textStyle),
            );
          }
          return Text("");
        });
  }
}
