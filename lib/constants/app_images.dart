import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppImages {
  static final AppImages _images = AppImages._internal();

  factory AppImages() => _images;

  AppImages._internal();

  final basePath = 'assets/images';

  Widget logo({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/logo.svg', width: width, height: height, color: color);

  Widget background({double? width, double? height}) =>
      Image.asset('$basePath/background.jpg', width: width, height: height, fit: BoxFit.cover);

  Widget signFirst({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/sign_first.svg', width: width, height: height, color: color);

  Widget signSecond({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/sign_second.svg', width: width, height: height, color: color);

  Widget signThird({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/sign_third.svg', width: width, height: height, color: color);

  Widget signFourth({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/sign_fourth.svg', width: width, height: height, color: color);
}
