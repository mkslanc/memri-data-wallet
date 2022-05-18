import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppImages {
  AppImages._();

  static const basePath = 'assets/images';

  static Widget memriLogo({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/logo.svg', width: width, height: height, color: color);

  static Widget memriBackground({double? width, double? height}) =>
      Image.asset('$basePath/background.jpg', width: width, height: height, fit: BoxFit.cover);

  static Widget memriSignFirst({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/sign_first.svg', width: width, height: height, color: color);

  static Widget memriSignSecond({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/sign_second.svg', width: width, height: height, color: color);

  static Widget memriSignThird({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/sign_third.svg', width: width, height: height, color: color);

  static Widget memriSignFourth({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/sign_fourth.svg', width: width, height: height, color: color);
}
