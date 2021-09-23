import 'package:flutter/material.dart';
import 'package:memri/MemriApp/UI/CVUComponents/types/CVUFont.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  PrimaryButton({required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(1),
      child: TextButton(
          onPressed: onPressed,
          child: child,
          style: TextButton.styleFrom(
            backgroundColor: Color(0xff333333),
            primary: Color(0xffF5F5F5),
            textStyle: CVUFont.buttonLabel,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.all(10),
          )),
    );
  }
}
