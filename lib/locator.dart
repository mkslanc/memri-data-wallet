import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:memri/core/services/mixpanel_analytics_service.dart';
import 'package:memri/providers/app_provider.dart';
import 'package:memri/providers/auth_provider.dart';
import 'package:memri/providers/importer_provider.dart';
import 'package:memri/providers/project_provider.dart';
import 'package:memri/providers/workspace_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();

  /// PROVIDERS
  locator.registerLazySingleton<AppProvider>(() => AppProvider());
  locator.registerLazySingleton<AuthProvider>(() => AuthProvider());
  locator.registerLazySingleton<WorkspaceProvider>(() => WorkspaceProvider());
  locator.registerLazySingleton<ImporterProvider>(() => ImporterProvider());
  locator.registerLazySingleton<ProjectProvider>(() => ProjectProvider());

  /// SERVICES
  locator.registerLazySingleton<MixpanelAnalyticsService>(
      () => MixpanelAnalyticsService());

  /// CLIENTS
  locator.registerLazySingleton<http.Client>(() => http.Client());

  /// PLUGINS
  locator.registerLazySingleton<SharedPreferences>(() => _prefs);
}
