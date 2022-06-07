import 'package:flutter/material.dart';
import 'package:memri/constants/cvu/cvu_color.dart';
import 'package:memri/constants/cvu/cvu_font.dart';

import '../../controllers/app_controller.dart';

class MemriNotification extends StatefulWidget {
  final AppController appController;

  MemriNotification(this.appController);

  @override
  _MemriNotificationState createState() => _MemriNotificationState();
}

class _MemriNotificationState extends State<MemriNotification> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
          padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
          color: Color(0x33E9500F),
          child: Row(
            children: [
              Text(
                widget.appController.lastError,
                style: TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 14, color: CVUColor.brandOrange),
              ),
              Spacer(),
              InkWell(
                onTap: () => widget.appController.hideError(),
                child: Text("Dismiss", style: CVUFont.link.copyWith(color: CVUColor.brandOrange)),
              )
            ],
          )),
    );
  }
}
