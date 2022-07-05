import 'package:memri/core/apis/base_api.dart';
import 'package:memri/utilities/helpers/app_helper.dart';

class StorageAPI extends BaseAPI {
  StorageAPI() : super('/${app.settings.podVersion}');
}
