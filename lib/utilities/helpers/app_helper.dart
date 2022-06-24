import 'package:memri/constants/app_colors.dart';
import 'package:memri/constants/app_icons.dart';
import 'package:memri/constants/app_images.dart';
import 'package:memri/constants/app_locales.dart';
import 'package:memri/constants/app_settings.dart';

class ApplicationHelper {
  static final ApplicationHelper _application = ApplicationHelper._internal();

  factory ApplicationHelper() => _application;

  ApplicationHelper._internal();

  AppSettings get settings => AppSettings();

  AppColors get colors => AppColors();

  AppIcons get icons => AppIcons();

  AppImages get images => AppImages();

  AppLocales get locales => AppLocales();
}

ApplicationHelper get app => ApplicationHelper();
