import 'package:flutter/material.dart';
import 'package:memri/utilities/helpers/app_helper.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key, this.message = ''}) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          app.images.logo(height: 100),
          SizedBox(height: 32),
          SizedBox(
            child: LinearProgressIndicator(color: Color(0xffFE570F)),
            width: 150,
          ),
          if (message.isNotEmpty) SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
