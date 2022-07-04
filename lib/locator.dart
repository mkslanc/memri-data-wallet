import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:memri/core/services/gitlab_service.dart';
import 'package:memri/core/services/log_service.dart';
import 'package:memri/core/services/mixpanel_analytics_service.dart';
import 'package:memri/core/services/pod_service.dart';
import 'package:memri/core/services/search_service.dart';
import 'package:memri/core/services/storage_service.dart';
import 'package:memri/providers/app_provider.dart';
import 'package:memri/providers/importer_provider.dart';
import 'package:memri/providers/pod_provider.dart';
import 'package:memri/providers/project_provider.dart';
import 'package:memri/providers/workspace_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final locator = GetIt.instance;

Future<void> setup() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();

  /// PROVIDERS
  locator.registerLazySingleton<AppProvider>(() => AppProvider(locator()));
  locator.registerLazySingleton<PodProvider>(
      () => PodProvider(locator(), locator(), locator()));
  locator.registerLazySingleton<WorkspaceProvider>(() => WorkspaceProvider());
  locator.registerLazySingleton<ImporterProvider>(() => ImporterProvider());
  locator.registerLazySingleton<ProjectProvider>(() => ProjectProvider());

  /// SERVICES
  locator.registerLazySingleton<PodService>(() => PodService(locator()));
  locator.registerLazySingleton<GitlabService>(() => GitlabService());
  locator.registerLazySingleton<LogService>(() => LogService());
  locator.registerLazySingleton<SearchService>(() => SearchService());
  locator.registerLazySingleton<StorageService>(() => StorageService());
  locator.registerLazySingleton<MixpanelAnalyticsService>(
      () => MixpanelAnalyticsService());

  /// CLIENTS
  locator.registerSingleton<Dio>(Dio());
  locator.registerLazySingleton<http.Client>(() => http.Client());

  /// PLUGINS
  locator.registerLazySingleton<SharedPreferences>(() => _prefs);
}
