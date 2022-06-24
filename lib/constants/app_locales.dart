import 'dart:ui';

class AppLocales {
  static final AppLocales _locales = AppLocales._internal();

  factory AppLocales() => _locales;

  AppLocales._internal();

  final Locale enUS = Locale('en', 'US');
  final Locale nlNL = Locale('nl', 'NL');

  final String fontEnUS = 'Karla';
  final String fontNlNL = 'Karla';

  VoidCallback? onChangeLanguage;
  Locale? customAppLocale;
  Locale? systemAppLocale;

  bool get useCustomLocale => customAppLocale != null;

  String get locale =>
      appLocale.languageCode + '_' + appLocale.countryCode!.toUpperCase();

  Locale get appLocale => customAppLocale ?? (systemAppLocale ?? enUS);

  /// TODO replace with condition to support fonts for different language
  String? get fontFamily =>
      appLocale.languageCode == enUS.languageCode ? fontEnUS : fontNlNL;
}
