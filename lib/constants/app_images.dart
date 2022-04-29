import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppImages {
  AppImages._();

  static Widget memriLogo({double? width, double? height, Color? color}) => SvgPicture.asset(
        'assets/images/logo.svg',
        width: width,
        height: height,
        color: color,
      );

  static Widget memriBackground({double? width, double? height}) =>
      Container(
        color: Colors.black,
        width: width,
        height: height,
      );
      // Image.network(
      //   'https://memri.io/assets/images/background-full.png?v=1f4cd39a0f',
      //   width: width,
      //   height: height,
      //   fit: BoxFit.cover,
      // );
}
