import 'package:memri/core/apis/log_api.dart';
import 'package:memri/core/services/api_service.dart';

class LogService extends ApiService<LogAPI> {
  LogService() : super(api: LogAPI());
}
