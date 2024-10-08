import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:memri/core/services/database/schema.dart';
import 'package:memri/core/services/gitlab_service.dart';
import 'package:memri/core/services/log_service.dart';
import 'package:memri/core/services/network_service.dart';
import 'package:memri/core/services/pod_service.dart';
import 'package:memri/core/services/search_service.dart';
import 'package:memri/core/services/storage_service.dart';
import 'package:memri/cvu/controllers/cvu_controller.dart';
import 'package:memri/providers/app_provider.dart';
import 'package:memri/providers/auth_provider.dart';
import 'package:memri/providers/connection_provider.dart';
import 'package:memri/providers/settings_provider.dart';
import 'package:memri/providers/ui_state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final locator = GetIt.instance;

Future<void> setup() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  SettingsProvider _settingsProvider = SettingsProvider(_prefs);
  final podService = await PodService.create(_settingsProvider);

  locator.registerLazySingleton<SharedPreferences>(() => _prefs);

  /// PROVIDERS
  locator.registerLazySingleton<AppProvider>(() => AppProvider(locator()));
  locator.registerLazySingleton<AuthProvider>(
      () => AuthProvider(locator(), locator()/*, locator()*/));
  locator.registerLazySingleton<ConnectionProvider>(() => ConnectionProvider());
  locator.registerLazySingleton<UIStateProvider>(() => UIStateProvider());
  locator.registerLazySingleton<SettingsProvider>(() => _settingsProvider);

  // CVU
  locator.registerLazySingleton<CVUController>(() => CVUController(locator()));
  locator.registerLazySingleton<Schema>(() => Schema(locator()));

  /// SERVICES
  locator.registerSingleton<PodService>(podService); // Register initialized instance
  locator.registerLazySingleton<GitlabService>(() => GitlabService());
  locator.registerLazySingleton<LogService>(() => LogService());
  locator.registerLazySingleton<SearchService>(() => SearchService());
  locator.registerLazySingleton<StorageService>(() => StorageService());
  locator.registerLazySingleton<NetworkService>(() => NetworkService());
  /*locator.registerLazySingleton<MixpanelAnalyticsService>(
      () => MixpanelAnalyticsService());*/

  /// CLIENTS
  locator.registerSingleton<Dio>(Dio());
  locator.registerLazySingleton<http.Client>(() => http.Client());


}
