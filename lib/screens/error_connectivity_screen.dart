import 'package:flutter/material.dart';

class ErrorConnectivityScreen extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorConnectivityScreen({
    Key? key,
    required this.errorMessage,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Connection Error',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry, // Use the passed-in onRetry callback
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
