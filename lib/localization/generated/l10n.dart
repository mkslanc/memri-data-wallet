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

  /// `Login Key`
  String get login_key {
    return Intl.message(
      'Login Key',
      name: 'login_key',
      desc: '',
      args: [],
    );
  }

  /// `Your Login Key`
  String get your_login_key {
    return Intl.message(
      'Your Login Key',
      name: 'your_login_key',
      desc: '',
      args: [],
    );
  }

  /// `Password Key`
  String get password_key {
    return Intl.message(
      'Password Key',
      name: 'password_key',
      desc: '',
      args: [],
    );
  }

  /// `Your Password Key`
  String get your_password_key {
    return Intl.message(
      'Your Password Key',
      name: 'your_password_key',
      desc: '',
      args: [],
    );
  }

  /// `Your Pod Address`
  String get your_pod_address {
    return Intl.message(
      'Your Pod Address',
      name: 'your_pod_address',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message(
      'Copy',
      name: 'copy',
      desc: '',
      args: [],
    );
  }

  /// `Initializing`
  String get initializing {
    return Intl.message(
      'Initializing',
      name: 'initializing',
      desc: '',
      args: [],
    );
  }

  /// `Check Server Status`
  String get check_server_status {
    return Intl.message(
      'Check Server Status',
      name: 'check_server_status',
      desc: '',
      args: [],
    );
  }

  /// `Welcome`
  String get welcome {
    return Intl.message(
      'Welcome',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `Loading`
  String get loading {
    return Intl.message(
      'Loading',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `License`
  String get license {
    return Intl.message(
      'License',
      name: 'license',
      desc: '',
      args: [],
    );
  }

  /// `Authenticating`
  String get authenticating {
    return Intl.message(
      'Authenticating',
      name: 'authenticating',
      desc: '',
      args: [],
    );
  }

  /// `Create new account`
  String get create_new_account {
    return Intl.message(
      'Create new account',
      name: 'create_new_account',
      desc: '',
      args: [],
    );
  }

  /// `Log into your Pod`
  String get log_into_your_pod {
    return Intl.message(
      'Log into your Pod',
      name: 'log_into_your_pod',
      desc: '',
      args: [],
    );
  }

  /// `Copy keys to clipboard`
  String get copy_keys_to_clipboard {
    return Intl.message(
      'Copy keys to clipboard',
      name: 'copy_keys_to_clipboard',
      desc: '',
      args: [],
    );
  }

  /// `Please wait while your credentials are verified`
  String get authenticating_message {
    return Intl.message(
      'Please wait while your credentials are verified',
      name: 'authenticating_message',
      desc: '',
      args: [],
    );
  }

  /// `Please create a new POD account or log into your existing account.`
  String get account_onboarding_message {
    return Intl.message(
      'Please create a new POD account or log into your existing account.',
      name: 'account_onboarding_message',
      desc: '',
      args: [],
    );
  }

  /// `Create data apps with your own data`
  String get account_slider_1_title {
    return Intl.message(
      'Create data apps with your own data',
      name: 'account_slider_1_title',
      desc: '',
      args: [],
    );
  }

  /// `Import your data from services like WhatsApp, Gmail, Instagram and Twitter into your private Memri POD. Process and use your data to build machine learning apps all in one platform.`
  String get account_slider_1_message {
    return Intl.message(
      'Import your data from services like WhatsApp, Gmail, Instagram and Twitter into your private Memri POD. Process and use your data to build machine learning apps all in one platform.',
      name: 'account_slider_1_message',
      desc: '',
      args: [],
    );
  }

  /// `Easy deployment into apps you can use`
  String get account_slider_2_title {
    return Intl.message(
      'Easy deployment into apps you can use',
      name: 'account_slider_2_title',
      desc: '',
      args: [],
    );
  }

  /// `Add and edit a custom interface to your app and see changes live. Select from ready building blocks such as VStacks, HStacks, Text and buttons inside the embedded Ace editor without leaving the platform.`
  String get account_slider_2_message {
    return Intl.message(
      'Add and edit a custom interface to your app and see changes live. Select from ready building blocks such as VStacks, HStacks, Text and buttons inside the embedded Ace editor without leaving the platform.',
      name: 'account_slider_2_message',
      desc: '',
      args: [],
    );
  }

  /// `Share your apps in an instant`
  String get account_slider_3_title {
    return Intl.message(
      'Share your apps in an instant',
      name: 'account_slider_3_title',
      desc: '',
      args: [],
    );
  }

  /// `Push your code to your repo in the dev or prod branch using our plugin template, and you’re done.`
  String get account_slider_3_message {
    return Intl.message(
      'Push your code to your repo in the dev or prod branch using our plugin template, and you’re done.',
      name: 'account_slider_3_message',
      desc: '',
      args: [],
    );
  }

  /// `Save your crypto keys`
  String get account_save_keys_title {
    return Intl.message(
      'Save your crypto keys',
      name: 'account_save_keys_title',
      desc: '',
      args: [],
    );
  }

  /// `These are your personal Crypto Keys. Save them in a safe place.`
  String get account_save_keys_message {
    return Intl.message(
      'These are your personal Crypto Keys. Save them in a safe place.',
      name: 'account_save_keys_message',
      desc: '',
      args: [],
    );
  }

  /// `You will need your keys to log into your account. If you lose your keys, you will not be able to recover them and you will permanently lose access to your account and POD.`
  String get account_save_keys_message_highlight {
    return Intl.message(
      'You will need your keys to log into your account. If you lose your keys, you will not be able to recover them and you will permanently lose access to your account and POD.',
      name: 'account_save_keys_message_highlight',
      desc: '',
      args: [],
    );
  }

  /// `To use your keys locally in pymemri run:`
  String get account_save_keys_developer_hint {
    return Intl.message(
      'To use your keys locally in pymemri run:',
      name: 'account_save_keys_developer_hint',
      desc: '',
      args: [],
    );
  }

  /// `You need your login and password keys in the creating app process.`
  String get account_save_keys_copy_warning {
    return Intl.message(
      'You need your login and password keys in the creating app process.',
      name: 'account_save_keys_copy_warning',
      desc: '',
      args: [],
    );
  }

  /// `I’ve saved the keys`
  String get account_save_keys_saved_button {
    return Intl.message(
      'I’ve saved the keys',
      name: 'account_save_keys_saved_button',
      desc: '',
      args: [],
    );
  }

  /// `Log in to your pod`
  String get account_login_title {
    return Intl.message(
      'Log in to your pod',
      name: 'account_login_title',
      desc: '',
      args: [],
    );
  }

  /// `Use your crypto keys to log in.`
  String get account_login_message {
    return Intl.message(
      'Use your crypto keys to log in.',
      name: 'account_login_message',
      desc: '',
      args: [],
    );
  }

  /// `Don’t have an account yet?`
  String get account_login_create_account_button_question {
    return Intl.message(
      'Don’t have an account yet?',
      name: 'account_login_create_account_button_question',
      desc: '',
      args: [],
    );
  }

  /// `Create a new one!`
  String get account_login_create_account_button_answer {
    return Intl.message(
      'Create a new one!',
      name: 'account_login_create_account_button_answer',
      desc: '',
      args: [],
    );
  }

  /// `Login key is required`
  String get account_login_empty_owner_key_error {
    return Intl.message(
      'Login key is required',
      name: 'account_login_empty_owner_key_error',
      desc: '',
      args: [],
    );
  }

  /// `Password key is required`
  String get account_login_empty_database_key_error {
    return Intl.message(
      'Password key is required',
      name: 'account_login_empty_database_key_error',
      desc: '',
      args: [],
    );
  }

  /// `Password key is required`
  String get account_login_empty_pod_url_error {
    return Intl.message(
      'Password key is required',
      name: 'account_login_empty_pod_url_error',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong. Please try again.`
  String get account_login_general_error {
    return Intl.message(
      'Something went wrong. Please try again.',
      name: 'account_login_general_error',
      desc: '',
      args: [],
    );
  }

  /// `The username or password you have entered is invalid. Please try again.`
  String get account_login_invalid_keys_error {
    return Intl.message(
      'The username or password you have entered is invalid. Please try again.',
      name: 'account_login_invalid_keys_error',
      desc: '',
      args: [],
    );
  }

  /// `The Pod URL you have entered is invalid. Please try again.`
  String get account_login_invalid_pod_url_error {
    return Intl.message(
      'The Pod URL you have entered is invalid. Please try again.',
      name: 'account_login_invalid_pod_url_error',
      desc: '',
      args: [],
    );
  }

  /// `Key does not exist or already in use, please, try another one.`
  String get account_login_wrong_keys_error {
    return Intl.message(
      'Key does not exist or already in use, please, try another one.',
      name: 'account_login_wrong_keys_error',
      desc: '',
      args: [],
    );
  }

  /// `Hello, dev!`
  String get account_login_dev_title {
    return Intl.message(
      'Hello, dev!',
      name: 'account_login_dev_title',
      desc: '',
      args: [],
    );
  }

  /// `This is a test version of memri pod.`
  String get account_login_dev_message {
    return Intl.message(
      'This is a test version of memri pod.',
      name: 'account_login_dev_message',
      desc: '',
      args: [],
    );
  }

  /// `Unexpected errors, expected reactions, unknown turns taken, known karma striking back.`
  String get account_login_dev_description {
    return Intl.message(
      'Unexpected errors, expected reactions, unknown turns taken, known karma striking back.',
      name: 'account_login_dev_description',
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
