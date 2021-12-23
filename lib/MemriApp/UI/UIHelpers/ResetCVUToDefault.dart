import 'package:flutter/material.dart';
import 'package:memri/MemriApp/CVU/definitions/CVUParsedDefinition.dart';
import 'package:memri/MemriApp/Controllers/AppController.dart';
import 'package:memri/MemriApp/Controllers/PageController.dart' as memri;
import 'package:pointer_interceptor/pointer_interceptor.dart';

resetCVUToDefault(BuildContext context, memri.PageController pageController,
    [List<CVUParsedDefinition>? definitions]) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Reset CVU to default'),
      content: const Text('Are you sure you want to reset CVU? All CVU changes will be lost'),
      actions: <Widget>[
        PointerInterceptor(
          child: TextButton(
            onPressed: () async {
              await AppController.shared.cvuController.resetToDefault(definitions);
              Navigator.pop(context);
              pageController.sceneController.scheduleUIUpdate();
            },
            child: const Text('OK'),
          ),
        ),
        PointerInterceptor(
          child: TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
        ),
      ],
    ),
  );
}
