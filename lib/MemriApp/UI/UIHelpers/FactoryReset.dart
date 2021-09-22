import 'package:flutter/material.dart';
import 'package:memri/MemriApp/Controllers/AppController.dart';

factoryReset(context) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Factory reset'),
      content: const Text('Are you sure you want to wipe all data?'),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            await AppController.shared.resetApp();
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          child: const Text('OK'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}
