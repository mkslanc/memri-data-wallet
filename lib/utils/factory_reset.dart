import 'package:flutter/material.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

factoryReset(context) {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Factory reset'),
      content: const Text('Are you sure you want to wipe all data?'),
      actions: <Widget>[
        PointerInterceptor(
          child: TextButton(
            onPressed: () async => await AppController.shared.resetApp(),
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
