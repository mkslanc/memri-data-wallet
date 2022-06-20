import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  static final AppIcons _icons = AppIcons._internal();

  factory AppIcons() => _icons;

  AppIcons._internal();

  final basePath = 'assets/icons';

  Widget copyToClipboard({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/ico_copy_to_clipboard.svg',
          width: width, height: height, color: color);

  Widget arrowRight({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/ico_arrow_right.svg', width: width, height: height, color: color);

  Widget arrowDown({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/ico_arrow_down.svg', width: width, height: height, color: color);

  Widget key({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/ico_key.svg', width: width, height: height, color: color);

  Widget logOut({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/ico_log_out.svg', width: width, height: height, color: color);

  Widget breadCrumbsLine({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/ico_brcmb_line.svg', width: width, height: height, color: color);

  Widget loader({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/ico_loader.svg', width: width, height: height, color: color);

  Widget hamburger({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/ico_hamburger.svg', width: width, height: height, color: color);

  Widget close({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/ico_close.svg', width: width, height: height, color: color);

  Widget rotateCCW({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/ico_rotate_ccw.svg', width: width, height: height, color: color);

  Widget ignore({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/ico_ignore.svg', width: width, height: height, color: color);

  Widget check({double? width, double? height, Color? color}) =>
      SvgPicture.asset('$basePath/ico_check.svg', width: width, height: height, color: color);
}
