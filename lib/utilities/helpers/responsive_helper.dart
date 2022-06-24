import 'package:flutter/material.dart';

class ResponsiveHelper {
  BuildContext context;

  factory ResponsiveHelper(BuildContext context) =>
      ResponsiveHelper._internal(context);

  ResponsiveHelper._internal(this.context);

  bool get isSmallScreen => MediaQuery.of(context).size.width < 760;

  bool get isLargeScreen => MediaQuery.of(context).size.width > 1200;

  bool get isMediumScreen =>
      MediaQuery.of(context).size.width >= 760 &&
      MediaQuery.of(context).size.width <= 1200;
}
