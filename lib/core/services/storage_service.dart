import 'package:memri/core/apis/storage_api.dart';
import 'package:memri/core/services/api_service.dart';

class StorageService extends ApiService<StorageAPI> {
  StorageService() : super(api: StorageAPI());
}
