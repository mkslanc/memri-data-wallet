import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:memri/configs/routes/route_navigator.dart';
import 'package:memri/constants/app_themes.dart';
import 'package:memri/localization/generated/l10n.dart';
import 'package:memri/locator.dart';
import 'package:memri/providers/app_provider.dart';
import 'package:memri/providers/pod_provider.dart';
import 'package:memri/screens/not_found_screen.dart';
import 'package:memri/utilities/helpers/app_helper.dart';
import 'package:provider/provider.dart';

class Memri extends StatefulWidget {
  const Memri({Key? key}) : super(key: key);

  @override
  _MemriState createState() => _MemriState();
}

class _MemriState extends State<Memri> {
  final List<Locale> _deviceLocales = WidgetsBinding.instance.window.locales;
  Locale _locale = app.locales.enUS;

  @override
  void initState() {
    final router = FluroRouter();
    Routes.configureRoutes(router);
    RouteNavigator.router = router;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => locator<AppProvider>()..initialize()),
        ChangeNotifierProvider(create: (_) => locator<PodProvider>()),
        // ChangeNotifierProvider(create: (_) => locator<ImporterProvider>()),
      ],
      child: MaterialApp(
        title: "Memri",
        theme: lightTheme,
        onGenerateRoute: RouteNavigator.router.generator,
        onUnknownRoute: (_) =>
            MaterialPageRoute(builder: (_) => NotFoundScreen()),
        locale: _locale,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate, //provides localised strings
          GlobalWidgetsLocalizations.delegate, //provides RTL support
          GlobalCupertinoLocalizations.delegate,
        ],
        localeListResolutionCallback: (_, supportedLocales) {
          if (app.locales.useCustomLocale) {
            return app.locales.appLocale;
          }

          Locale? locale;
          if (_deviceLocales.isNotEmpty) {
            var intersection = _deviceLocales
                .where((deviceLocale) => supportedLocales
                    .map((supportedLocale) => supportedLocale.languageCode)
                    .toList()
                    .contains(deviceLocale.languageCode))
                .toList();
            if (intersection.isNotEmpty) {
              locale = intersection.first;
            }
          }
          locale ??= supportedLocales.first;

          if (app.locales.systemAppLocale?.languageCode !=
              locale.languageCode) {
            WidgetsBinding.instance.addPostFrameCallback(
                (_) => app.locales.systemAppLocale = locale!);
          }

          return locale;
        },
        // Tells the system which are the supported languages
        supportedLocales: S.delegate.supportedLocales,
      ),
    );
  }
}
