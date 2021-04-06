import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/SceneController.dart';

import '../CVUUINodeResolver.dart';

/// A CVU element for displaying a button
/// - Use the `onPress` property to provide a CVU Action for the button
class CVUButton extends StatelessWidget {
  final CVUUINodeResolver nodeResolver;
  //final SceneController sceneController;

  CVUButton({required this.nodeResolver});

  onPress() {
    var action = nodeResolver.propertyResolver.action("onPress");
    if (action == null) {
      return;
    }
    //action.execute(sceneController, nodeResolver.context); TODO: need sceneController
  }

  @override
  Widget build(BuildContext context) {
    //TODO: buttonStyle
    return ElevatedButton(onPressed: onPress, child: nodeResolver.childrenInForEachWithWrap());
  }
}
