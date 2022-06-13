import 'package:memri/constants/app_settings.dart';
import 'package:memri/controllers/app_controller.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelAnalyticsService {
  static late Mixpanel mixpanel;

  Future<void> init() async {
    mixpanel = await Mixpanel.init(
      AppSettings.mixPanelToken,
      optOutTrackingDefault: false,
    );
  }

  void logSignUp(String userId) {
    mixpanel.identify(userId);
    mixpanel.track(AnalyticsEvents.signUp,
        properties: {_AnalyticsProperties.developersMode: AppController.shared.isDevelopersMode});
  }

  void logSignUpTime() => mixpanel.timeEvent(AnalyticsEvents.signUp);

  void logSignIn(String userId) {
    mixpanel.timeEvent(AnalyticsEvents.signIn);
    mixpanel.identify(userId);
    mixpanel.track(AnalyticsEvents.signIn,
        properties: {_AnalyticsProperties.developersMode: AppController.shared.isDevelopersMode});
  }

  void logNavigationButton(String buttonText) {
    mixpanel.timeEvent(AnalyticsEvents.navigationButton);
    mixpanel.track(AnalyticsEvents.navigationButton,
        properties: {_AnalyticsProperties.buttonLabel: buttonText});
  }

  void logBreadCrumbButton(String buttonText) {
    mixpanel.timeEvent(AnalyticsEvents.breadCrumbButton);
    mixpanel.track(AnalyticsEvents.breadCrumbButton,
        properties: {_AnalyticsProperties.buttonLabel: buttonText});
  }

  void logCvuButton(String buttonText) {
    mixpanel.timeEvent(AnalyticsEvents.cvuButton);
    mixpanel.track(AnalyticsEvents.cvuButton,
        properties: {_AnalyticsProperties.buttonLabel: buttonText});
  }

  void logDiscordButton() {
    mixpanel.timeEvent(AnalyticsEvents.discord);
    mixpanel.track(AnalyticsEvents.discord);
  }

  void logGitlabButton() {
    mixpanel.timeEvent(AnalyticsEvents.gitlab);
    mixpanel.track(AnalyticsEvents.gitlab);
  }

  void logImporterSelect(String importerName) {
    mixpanel.timeEvent(AnalyticsEvents.importerSelect);
    mixpanel.track(AnalyticsEvents.importerSelect,
        properties: {_AnalyticsProperties.importerName: importerName});
  }

  void logImporterConnect(String importerName) {
    mixpanel.timeEvent(AnalyticsEvents.importerConnect);
    mixpanel.track(AnalyticsEvents.importerConnect,
        properties: {_AnalyticsProperties.importerName: importerName});
  }

  void logImporterStatus(String importerStatus) {
    mixpanel.timeEvent(AnalyticsEvents.importerStatus);
    mixpanel.track(AnalyticsEvents.importerStatus,
        properties: {_AnalyticsProperties.importerStatus: importerStatus});
  }

  void logProjectCreate(String projectName, var projectDataSource) {
    mixpanel.timeEvent(AnalyticsEvents.projectCreate);
    mixpanel.track(
      AnalyticsEvents.projectCreate,
      properties: {
        _AnalyticsProperties.projectName: projectName,
        _AnalyticsProperties.projectDataSource: projectDataSource,
      },
    );
  }

  void logProjectDataSelect(var dataSources) {
    mixpanel.timeEvent(AnalyticsEvents.projectDataSelect);
    mixpanel.track(
      AnalyticsEvents.projectDataSelect,
      properties: {_AnalyticsProperties.projectDataSource: dataSources},
    );
  }

  void logProjectAddLabels(List<String> labels) {
    mixpanel.timeEvent(AnalyticsEvents.projectLabelsAdd);
    mixpanel.track(
      AnalyticsEvents.projectLabelsAdd,
      properties: {_AnalyticsProperties.projectDataLabels: labels},
    );
  }

  void logProjectLabelsOverview(String submitted, String skipped, String total) {
    mixpanel.timeEvent(AnalyticsEvents.projectLabelsOverview);
    mixpanel.track(
      AnalyticsEvents.projectLabelsOverview,
      properties: {
        _AnalyticsProperties.projectLabelsSubmitted: submitted,
        _AnalyticsProperties.projectLabelsSkipped: skipped,
        _AnalyticsProperties.projectLabelsTotal: total,
      },
    );
  }

  void logProjectLabelsSummary(List<String> labels) {
    mixpanel.timeEvent(AnalyticsEvents.projectLabelsSummary);
    mixpanel.track(
      AnalyticsEvents.projectLabelsSummary,
      properties: {_AnalyticsProperties.projectLabelsTotal: labels},
    );
  }
}

class AnalyticsEvents {
  AnalyticsEvents._();

  static const signUp = 'sign_up';
  static const signIn = 'sign_in';

  static const navigationButton = 'navigation_button';
  static const breadCrumbButton = 'bread_crumb_button';
  static const cvuButton = 'cvu_button';

  static const discord = 'discord';
  static const gitlab = 'gitlab';

  static const importerSelect = 'importer_select';
  static const importerConnect = 'importer_connect';
  static const importerStatus = 'importer_status';

  static const projectCreate = 'project_create';
  static const projectDataSelect = 'project_data_select';
  static const projectLabelsAdd = 'project_labels_add';
  static const projectLabelsOverview = 'project_labels_overview';
  static const projectLabelsSummary = 'project_labels_summary';
}

class _AnalyticsProperties {
  _AnalyticsProperties._();

  static const buttonLabel = 'button_label';
  static const developersMode = 'developers_mode';

  static const importerName = 'importer_name';
  static const importerStatus = 'importer_status';

  static const projectName = 'project_name';
  static const projectDataSource = 'project_date_source';
  static const projectDataLabels = 'project_date_labels';
  static const projectLabelsSubmitted = 'project_labels_submitted';
  static const projectLabelsSkipped = 'project_labels_skipped';
  static const projectLabelsTotal = 'project_labels_total';
}
