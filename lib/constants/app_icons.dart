import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  AppIcons._();

  static const basePath = 'assets/images';

  static Widget copyToClipboard({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/ico_log_out_rotated.svg',
          width: width, height: height, color: color);
}
