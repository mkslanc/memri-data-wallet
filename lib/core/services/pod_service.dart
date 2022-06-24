import 'package:memri/core/apis/pod_api.dart';
import 'package:memri/core/services/api_service.dart';

class PodService extends ApiService<PodAPI> {
  PodService() : super(api: PodAPI());
}
