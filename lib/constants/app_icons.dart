import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  AppIcons._();

  static const basePath = 'assets/icons';

  static Widget copyToClipboard(
          {double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/ico_copy_to_clipboard.svg',
          width: width, height: height, color: color);

  static Widget arrowRight({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/ico_arrow_right.svg',
          width: width, height: height, color: color);
}
