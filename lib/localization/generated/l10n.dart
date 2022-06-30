// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Memri`
  String get memri {
    return Intl.message(
      'Memri',
      name: 'memri',
      desc: '',
      args: [],
    );
  }

  /// `Memri - Machine learning tools designed to protect your privacy`
  String get memri_name {
    return Intl.message(
      'Memri - Machine learning tools designed to protect your privacy',
      name: 'memri_name',
      desc: '',
      args: [],
    );
  }

  /// `The easiest way to build, deploy and share ML apps on personal data`
  String get memri_description {
    return Intl.message(
      'The easiest way to build, deploy and share ML apps on personal data',
      name: 'memri_description',
      desc: '',
      args: [],
    );
  }

  /// `Hi there`
  String get hi_there {
    return Intl.message(
      'Hi there',
      name: 'hi_there',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to Memri`
  String get welcome_to_memri {
    return Intl.message(
      'Welcome to Memri',
      name: 'welcome_to_memri',
      desc: '',
      args: [],
    );
  }

  /// `Please create a new POD account or log into your existing account.`
  String get onboarding_message {
    return Intl.message(
      'Please create a new POD account or log into your existing account.',
      name: 'onboarding_message',
      desc: '',
      args: [],
    );
  }

  /// `Create account`
  String get create_account {
    return Intl.message(
      'Create account',
      name: 'create_account',
      desc: '',
      args: [],
    );
  }

  /// `Log in`
  String get log_in {
    return Intl.message(
      'Log in',
      name: 'log_in',
      desc: '',
      args: [],
    );
  }

  /// `Switch to`
  String get switch_to {
    return Intl.message(
      'Switch to',
      name: 'switch_to',
      desc: '',
      args: [],
    );
  }

  /// `developers mode`
  String get developers_mode {
    return Intl.message(
      'developers mode',
      name: 'developers_mode',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
      Locale.fromSubtags(languageCode: 'nl', countryCode: 'NL'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
