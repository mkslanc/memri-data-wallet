import 'package:flutter/cupertino.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:memri/widgets/components/shapes/clipper.dart';

import '../../cvu/constants/cvu_font.dart';

class ErrorMessage extends StatelessWidget {
  final String errorMessage;

  ErrorMessage(this.errorMessage);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: ClipPath(
            clipper: TriangleClipper(),
            child: Container(
              color: Color(0x33E9500F),
              height: 14,
              width: 16,
            ),
          ),
        ),
        Container(
          width: 632,
          color: Color(0x33E9500F),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Text(
            errorMessage,
            style: CVUFont.bodyText1.copyWith(color: app.colors.brandOrange),
          ),
        ),
      ],
    );
  }
}
