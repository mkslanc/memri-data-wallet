import 'package:flutter/material.dart';
import 'package:memri/constants/cvu/cvu_font.dart';
import 'package:memri/utils/app_helper.dart';

import '../../controllers/app_controller.dart';

class MemriNotification extends StatelessWidget {
  final AppController appController;

  MemriNotification(this.appController);

  @override
  Widget build(BuildContext context) {
    var lastError = appController.lastError.value!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
          padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
          color: Color(0x33E9500F),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lastError.errorString,
                style: TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 14, color: app.colors.brandOrange),
              ),
              Spacer(),
              if (lastError.showDismiss)
                InkWell(
                  onTap: () => appController.hideError(lastError),
                  child:
                      Text("Dismiss", style: CVUFont.link.copyWith(color: app.colors.brandOrange)),
                ),
              if (lastError.showRetry)
                InkWell(
                  onTap: () {
                    appController.hideError(lastError);
                    Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                  },
                  child: Text("Try again",
                      style: CVUFont.link.copyWith(color: app.colors.brandOrange)),
                )
            ],
          )),
    );
  }
}
