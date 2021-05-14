import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import '../CVUUINodeResolver.dart';
import 'CVUTextPropertiesModifier.dart';

/// A CVU element for displaying a button
/// - Use the `onPress` property to provide a CVU Action for the button
class CVUButton extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;
  final SceneController sceneController = SceneController.sceneController;

  final Future<TextProperties> textProperties;
  late final TextProperties resolvedTextProperties;

  CVUButton({required this.nodeResolver, required this.textProperties});

  onPress() {
    var actions = nodeResolver.propertyResolver.actions("onPress");
    if (actions == null) {
      return;
    }
    for (var action in actions) {
      action.execute(sceneController, nodeResolver.context);
    }
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
            return TextButton(
              onPressed: onPress,
              child: nodeResolver.childrenInForEachWithWrap(),
              style: ElevatedButton.styleFrom(textStyle: resolvedTextProperties.textStyle),
            );
          }
          return Text("");
        });
  }
}
