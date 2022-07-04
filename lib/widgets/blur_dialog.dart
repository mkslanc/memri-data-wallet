import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:memri/utilities/helpers/app_helper.dart';

class BlurDialog extends StatelessWidget {
  const BlurDialog({Key? key, required this.child}) : super(key: key);

  final Widget child;
  final double blurValue = 25;
  final double borderRadius = 20.0;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
      child: Align(
        alignment: Alignment.center,
        child: SimpleDialog(
          backgroundColor: app.colors.white.withOpacity(0.6),
          elevation: 0,
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius)),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(padding: EdgeInsets.all(24), child: child),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
