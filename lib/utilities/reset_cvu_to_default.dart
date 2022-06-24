import 'package:flutter/material.dart';
import 'package:memri/core/controllers/app_controller.dart';
import 'package:memri/core/controllers/page_controller.dart' as memri;
import 'package:memri/core/cvu/cvu_action.dart';
import 'package:memri/core/cvu/resolving/cvu_context.dart';
import 'package:memri/core/models/cvu/cvu_parsed_definition.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

resetCVUToDefault(BuildContext context, memri.PageController pageController,
    {CVUContext? cvuContext,
    List<CVUParsedDefinition>? definitions,
    CVUAction? action}) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Reset CVU to default'),
      content: const Text(
          'Are you sure you want to reset CVU? All CVU changes will be lost'),
      actions: <Widget>[
        PointerInterceptor(
          child: TextButton(
            onPressed: () async {
              if (action != null) {
                await action.execute(pageController, cvuContext!);
              } else {
                await AppController.shared.cvuController
                    .resetToDefault(definitions);
              }
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
