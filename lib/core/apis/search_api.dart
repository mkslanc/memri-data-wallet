import 'package:memri/core/apis/base_api.dart';
import 'package:memri/utilities/helpers/app_helper.dart';

class SearchAPI extends BaseAPI {
  SearchAPI() : super('/${app.settings.podVersion}');
}
